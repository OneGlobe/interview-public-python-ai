from functools import lru_cache

from langchain_core.language_models import BaseChatModel

from app import config
from app.llm_factory import LLMFactory
from app.services.chat_service import ChatService


@lru_cache
def get_llm() -> BaseChatModel:
    """
    Get or create a singleton LLM instance based on configuration.

    Returns:
        BaseChatModel: The configured LLM instance
    """
    if config.LLM_PROVIDER == "ollama":
        return LLMFactory.create_llm(
            provider="ollama",
            model=config.OLLAMA_MODEL,
            base_url=config.OLLAMA_BASE_URL,
        )
    elif config.LLM_PROVIDER == "azure":
        return LLMFactory.create_llm(
            provider="azure",
            endpoint=config.AZURE_OPENAI_ENDPOINT,
            api_key=config.AZURE_OPENAI_API_KEY,
            deployment_name=config.AZURE_OPENAI_DEPLOYMENT_NAME,
            model=config.AZURE_OPENAI_MODEL_NAME,
        )
    else:
        raise ValueError(f"Unsupported LLM_PROVIDER: {config.LLM_PROVIDER}")


@lru_cache
def get_chat_service() -> ChatService:
    """
    Get or create a singleton ChatService instance with the configured LLM.

    Returns:
        ChatService: The chat service instance
    """
    llm = get_llm()
    return ChatService(llm=llm)
