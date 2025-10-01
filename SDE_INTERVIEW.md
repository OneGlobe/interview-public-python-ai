# Software Engineer Interview

## Interview Guidelines

- :white_check_mark: Google / Internet Search
- :white_check_mark: AI questions w/o copy-paste (eg. Claude, ChatGPT, Perplexity)
- :x: AI coding agents, AI autocomplete (eg. Copilot, Cursor, Claude Code)
- :x: Changes made prior to the interview will not be accepted

## Preparation

- [ ] Clone this repository to your local machine
- [ ] Successfully run the application stack (see Quick Start in [README.md](README.md))
- [ ] Verify you can access both the frontend and backend
- [ ] Review the codebase structure and familiarize yourself with the key components

## Task

Your task is to add a system prompt to our chat.
The system prompt must be stored and managed in the database.
It is not necessary as part of the interview to implement system prompt CRUD functionality.

- Each conversation must have a system prompt associated with it.
- Only 1 prompt may be active at a time.
- New conversations must use the active prompt.
- Existing conversations must use the system prompt associated with them during creation.

The system prompt _must not_ be leaked.

Be prepared to implement and run your solution.