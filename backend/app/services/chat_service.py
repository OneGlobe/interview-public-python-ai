import asyncio
import json
import logging
from collections.abc import AsyncGenerator

from langchain_core.language_models import BaseChatModel
from langchain_core.messages import AIMessage, HumanMessage
from sqlalchemy.orm import Session

from app.models import Conversation, Message, MessageRole

logger = logging.getLogger(__name__)


class ChatService:
    def __init__(self, llm: BaseChatModel):
        self.llm = llm

    def get_or_create_conversation(self, db: Session, conversation_id: int | None = None) -> Conversation:
        if conversation_id:
            conversation = db.query(Conversation).filter(Conversation.id == conversation_id).first()
            if conversation:
                return conversation

        conversation = Conversation(title="New Conversation")
        db.add(conversation)
        db.commit()
        db.refresh(conversation)
        return conversation

    def get_conversation_history(self, db: Session, conversation_id: int):
        messages = (
            db.query(Message).filter(Message.conversation_id == conversation_id).order_by(Message.created_at).all()
        )

        langchain_messages = []
        for msg in messages:
            if msg.role == MessageRole.USER:  # type: ignore
                langchain_messages.append(HumanMessage(content=str(msg.content)))
            elif msg.role == MessageRole.ASSISTANT:  # type: ignore
                langchain_messages.append(AIMessage(content=str(msg.content)))

        return langchain_messages

    async def process_chat_stream(
        self, db: Session, user_message: str, conversation_id: int | None = None
    ) -> AsyncGenerator[str, None]:
        try:
            conversation = self.get_or_create_conversation(db, conversation_id)

            user_msg = Message(conversation_id=conversation.id, role=MessageRole.USER, content=user_message)
            db.add(user_msg)
            db.commit()
            db.refresh(user_msg)

            yield f"data: {json.dumps({'type': 'conversation_id', 'data': conversation.id})}\n\n"
            yield f"data: {json.dumps({'type': 'user_message', 'data': user_message})}\n\n"

            history = self.get_conversation_history(db, conversation.id)  # type: ignore

            try:
                assistant_content = ""
                async for chunk in self.llm.astream(history):
                    if chunk.content:
                        assistant_content += str(chunk.content)
                        yield f"data: {json.dumps({'type': 'assistant_chunk', 'data': chunk.content})}\n\n"
            except Exception as e:
                logger.error(
                    f"LLM connection failed for conversation {conversation.id}: {type(e).__name__}: {str(e)}",
                    exc_info=True,
                )
                assistant_content = (
                    f"Echo: {user_message}\n\n"
                    f"(Note: Unable to connect to LLM. Make sure LLM is running and available. Error: {str(e)})"
                )
                for word in assistant_content.split():
                    yield f"data: {json.dumps({'type': 'assistant_chunk', 'data': word + ' '})}\n\n"
                    await asyncio.sleep(0.1)  # Simulate streaming delay

            assistant_msg = Message(
                conversation_id=conversation.id, role=MessageRole.ASSISTANT, content=assistant_content
            )
            db.add(assistant_msg)
            db.commit()
            db.refresh(assistant_msg)

            if str(conversation.title) == "New Conversation" and len(user_message) > 0:
                title = user_message[:50] + "..." if len(user_message) > 50 else user_message
                conversation.title = title  # type: ignore
                db.commit()
                db.refresh(conversation)

            yield f"data: {json.dumps({'type': 'complete', 'data': assistant_msg.id})}\n\n"

        except Exception as e:
            yield f"data: {json.dumps({'type': 'error', 'data': str(e)})}\n\n"
