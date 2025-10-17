# Interview Python AI - Chat Application

Full-stack chat application with FastAPI + LangChain + Ollama backend and React + TypeScript frontend. Features real-time streaming responses from local LLMs.

## Interview

For interview-specific instructions, please see:
- [Software Engineer Interview](SDE_INTERVIEW.md)
- [DevSecOps Engineer Interview](DEVSECOPS_INTERVIEW.md)

## Quick Start

**Prerequisites**: Docker and Docker Compose installed

```bash
# Start the complete stack (recommended)
./scripts/init-dev.sh

# Or manually start all services:
docker-compose up

# To shutdown
docker-compose down
```

This will start all required services: frontend, backend, PostgreSQL database, and Ollama for LLM functionality.

### Accessing the Application

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | React chat interface |
| Backend API | http://localhost:8000/docs | FastAPI Swagger documentation |

## Structure 

```
interview-python-ai/
├── backend/
│   ├── app/
│   │   ├── routers/      # FastAPI routes and endpoints
│   │   ├── services/     # Business logic and integrations (e.g., LangChain, Ollama)
│   │   ├── config.py     # App configuration and settings
│   │   ├── database.py   # Database session and connection
│   │   ├── models.py     # SQLAlchemy models
│   │   ├── schemas.py    # Pydantic schemas
│   │   ├── main.py       # FastAPI application entrypoint
│   ├── alembic/          # Database migrations
└── frontend/
    ├── src/
    │   ├── api/          # Generated API client
    │   ├── components/   # React UI components
    │   ├── hooks/        # Custom React hooks
    │   ├── lib/          # Utility libraries
    │   ├── App.tsx       # Main React application
    │   └── main.tsx      # React entrypoint
    └── public/           # Static assets
```

## Development

**Database migrations**:
```bash
docker-compose exec backend alembic revision --autogenerate -m "description"
docker-compose exec backend alembic upgrade head
```

**Frontend API client regeneration** (when backend changes):
```bash
cd frontend && npx kubb
```

version: 0.1.9 <!-- x-release-please-version -->