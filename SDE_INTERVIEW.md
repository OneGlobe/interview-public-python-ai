# Software Engineer Interview

## Interview Guidelines

- :white_check_mark: Google / Internet Search
- :white_check_mark: AI questions w/o copy-paste (eg. Claude, ChatGPT, Perplexity)
- :x: AI coding agents, AI autocomplete (eg. Copilot, Cursor, Claude Code)
- :x: Changes made prior to the interview will not be accepted

## Preparation

- [ ] Fork the repository and clone to your local machine
- [ ] Successfully run the application stack (see Quick Start in [README.md](README.md))
- [ ] Verify you can access both the frontend and backend
- [ ] Review the codebase structure and familiarize yourself with the key components

## Tasks

You will complete the following tasks to demonstrate your full-stack development skills:

### 1. Add System Prompt Feature (Backend)

Add a system prompt feature to our chat application:
- System prompts must be stored and managed in the database
- Each conversation must have a system prompt associated with it
- Only 1 prompt may be active at a time
- New conversations must use the active prompt
- Existing conversations must use the system prompt associated with them during creation
- The system prompt _must not_ be leaked to the client

**Note:** It is not necessary to implement system prompt CRUD functionality as part of this interview.

### 2. Add Markdown Rendering (Frontend)

Implement proper markdown rendering for LLM responses:
- LLM responses should be rendered as formatted markdown in the UI
- Support common markdown features (headers, lists, code blocks, links, emphasis, etc.)
- Ensure markdown renders correctly during streaming responses
- Maintain a good user experience while messages are being streamed

## Requirements

- All changes must work with the existing application architecture
- Be prepared to implement and run your solution
- Demonstrate that both features work correctly