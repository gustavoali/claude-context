# Quimera - Project Context
**Version:** 1.0.0 | **Tests:** 372 backend | **Frontend:** build OK
**Estado:** IMPLEMENTADO (4 fases completas, pre-deploy)
**Ubicacion proyecto:** C:/personal/quimera
**Ubicacion contexto:** C:/claude_context/personal/quimera

## Descripcion
Plataforma de entretenimiento AI para publico infantil/adolescente argentino (4-19 anos).
4 productos integrados: cuentos personalizados, historias interactivas, roasts AI, memes/stickers.
Identidad: espanol rioplatense, humor argentino, cultura local.

## Stack
- **Backend:** Python 3.11+ / FastAPI
- **LLM:** Claude API / GPT-4o-mini (produccion), Groq/Llama (dev)
- **Image Gen:** DALL-E 3 / Stable Diffusion
- **TTS:** Para audio de cuentos
- **PDF:** fpdf2 / reportlab
- **DB:** PostgreSQL (Docker)
- **Cache:** Redis
- **Frontend:** Next.js o Astro (PWA, mobile-first)
- **Pagos:** MercadoPago (AR) + Stripe (expansion)
- **Hosting:** Railway / Fly.io (~$15/mes total)

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| FastAPI App | backend/app/main.py | Implementado |
| API Routers (8) | backend/app/api/v1/ | Implementado |
| Auth + IDOR | backend/app/auth/ | Implementado |
| Moderation | backend/app/services/moderation.py | Implementado |
| LLM Service | backend/app/services/llm.py | Implementado |
| Image Service | backend/app/services/image_gen.py | Implementado |
| TTS Service | backend/app/services/tts.py | Implementado |
| PDF Service | backend/app/services/pdf.py | Implementado |
| Payment Service | backend/app/services/payments.py | Implementado |
| Content Generators (4) | backend/app/generators/ | Implementado |
| Frontend PWA | frontend/ | Implementado |
| CI Pipeline | .github/workflows/ci.yml | Implementado |

## Comandos
```bash
# Infra
docker compose up -d                          # PG (5436) + Redis (6379)

# Backend
cd C:/personal/quimera/backend
pip install -r requirements.txt
cp ../.env.example ../.env                    # Configurar API keys
uvicorn app.main:app --reload --port 8000
pytest --tb=short                             # 372 tests

# Frontend
cd C:/personal/quimera/frontend
npm install
npm run dev                                   # localhost:3000
npm run build                                 # Verificar build
```

## Agentes Recomendados
| Tarea | Agente |
|-------|--------|
| Backend API / Services | python-backend-developer |
| Frontend PWA | frontend-react-developer |
| Arquitectura general | software-architect |
| Base de datos | database-expert |
| Tests | test-engineer |
| Code review | code-reviewer |
| User stories | product-owner |
| DevOps/hosting | devops-engineer |

## Reglas del Proyecto
1. **Seguridad de menores es prioridad absoluta** - contenido filtrado por edad, sin datos de <13
2. **Tono argentino** - espanol rioplatense en todo contenido generado, no neutro
3. **Procesamiento efimero** - no almacenar fotos de menores en servidores
4. **Mobile-first** - 100% de la audiencia es mobile
5. **Costos AI variables** - monitorear costo por generacion, tener fallbacks

## Documentacion
@C:/claude_context/personal/quimera/SEED_DOCUMENT.md
@C:/claude_context/personal/quimera/ARCHITECTURE_ANALYSIS.md
@C:/claude_context/personal/quimera/SECURITY_ANALYSIS.md
@C:/claude_context/personal/quimera/PRODUCT_BACKLOG.md
@C:/claude_context/personal/quimera/BUSINESS_STAKEHOLDER_DECISION.md
@C:/claude_context/personal/quimera/TASK_STATE.md
