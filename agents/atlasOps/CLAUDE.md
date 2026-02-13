# AtlasOps - Project Configuration

## Overview

**AtlasOps** es una plataforma de orquestacion de agentes AI con arquitectura de microservicios.

**Ubicacion:** `c:/agents/atlasops`
**Clasificador:** agents

---

## Arquitectura

```
┌──────────────────────────────────────────────────────────┐
│                     AtlasOps Platform                    │
├──────────────────────────────────────────────────────────┤
│  ┌─────────────┐   ┌─────────────┐   ┌──────────────┐   │
│  │ Orchestrator│──▶│   Agents    │──▶│   Platform   │   │
│  │(TypeScript) │   │  (Python)   │   │    (.NET)    │   │
│  │  Fastify    │   │   FastAPI   │   │  ASP.NET Core│   │
│  └──────┬──────┘   └──────┬──────┘   └──────┬───────┘   │
│         └────────┬────────┴────────┬────────┘           │
│         ┌────────▼────────┐  ┌─────▼──────┐             │
│         │   PostgreSQL    │  │   Redis    │             │
│         └─────────────────┘  └────────────┘             │
└──────────────────────────────────────────────────────────┘
```

---

## Servicios

| Servicio | Tecnologia | Puerto | Path |
|----------|------------|--------|------|
| Orchestrator | Node.js 20 + TypeScript + Fastify | 3000 | `apps/orchestrator-ts/` |
| Agent Service | Python 3.11 + FastAPI + FAISS | 8000 | `apps/agents-py/` |
| Platform API | .NET 8 + ASP.NET Core | 5000 | `apps/platform-dotnet/` |
| PostgreSQL | PostgreSQL 16 | 5432 | - |
| Redis | Redis 7 | 6379 | - |

---

## Estructura del Proyecto

```
atlasops/
├── apps/
│   ├── orchestrator-ts/       # TypeScript orchestrator
│   ├── agents-py/             # Python agent service
│   └── platform-dotnet/       # .NET platform API (Clean Architecture)
│       └── src/
│           ├── Api/           # ASP.NET Core Web API
│           ├── Application/   # Application layer
│           ├── Domain/        # Domain entities
│           └── Infrastructure/# Infrastructure layer
├── libs/                      # Shared libraries
├── infra/                     # Docker Compose, Makefile
├── data/                      # Data files
└── docs/                      # Documentation
```

---

## Comandos Frecuentes

```bash
# Infraestructura (desde /infra)
make up                # Start all services
make down              # Stop all services
make dev               # Start with dev tools
make logs              # View logs
make status            # Check health

# .NET Platform (desde /apps/platform-dotnet)
dotnet build
dotnet run --project src/Api
dotnet test

# TypeScript Orchestrator (desde /apps/orchestrator-ts)
npm install
npm run dev

# Python Agents (desde /apps/agents-py)
pip install -r requirements.txt
uvicorn app.main:app --reload
```

---

## Health Checks

```bash
curl http://localhost:3000/health  # Orchestrator
curl http://localhost:8000/health  # Agents
curl http://localhost:5000/health  # Platform
```

---

## Environment Variables

Archivo: `infra/.env`

```bash
POSTGRES_PASSWORD=<secure-password>
REDIS_PASSWORD=<secure-password>
JWT_SECRET=<min-32-chars>
ANTHROPIC_API_KEY=sk-ant-api03-<your-key>
```

---

## Documentacion Adicional

- [README.md](c:/agents/atlasops/README.md)
- [QUICK_START.md](c:/agents/atlasops/docs/QUICK_START.md)
- [INFRASTRUCTURE.md](c:/agents/atlasops/docs/INFRASTRUCTURE.md)
- [DATABASE_DESIGN.md](c:/agents/atlasops/docs/DATABASE_DESIGN.md)

---

## Convenciones

### .NET Platform
- Clean Architecture (Domain, Application, Infrastructure, Api)
- Entity Framework Core
- Swagger/OpenAPI

### TypeScript Orchestrator
- Fastify framework
- Pino logging

### Python Agents
- FastAPI framework
- FAISS para vector search

---

## Work in Progress

### Feature 1: LLM Provider Abstraction (Epica 6)
- **Estado:** En progreso (4/12 stories completadas)
- **Próximo:** Implementar OpenAI, Gemini, Ollama providers
- **Delegar a:** python-backend-developer

### Feature 2: PR Analyzer Multi-Domain (NUEVO)
- **Estado:** Diseño completado, pendiente implementación
- **MVP:** 37 story points (10 stories)
- **Próximo:** Implementar Webhook Handler (ATLAS-043)

---

## Documentos del Proyecto

- [ARCHITECTURE_PR_ANALYZER.md](C:/claude_context/agents/atlasops/ARCHITECTURE_PR_ANALYZER.md) - Diseño técnico PR Analyzer
- [PRODUCT_BACKLOG_PR_ANALYZER.md](C:/claude_context/agents/atlasops/PRODUCT_BACKLOG_PR_ANALYZER.md) - User stories PR Analyzer
- [TASK_STATE.md](C:/claude_context/agents/atlasops/TASK_STATE.md) - Estado de tareas

---

**Ultima actualizacion:** 2026-01-31
