# Quimera - Project Context
**Version:** 0.2.0-brote | **Tests:** 0 | **Coverage:** 0%
**Estado:** BROTE (arquitectura + backlog listos, listo para desarrollar)
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
| FastAPI App | backend/app/main.py | Pendiente |
| API Routers | backend/app/api/v1/ | Pendiente |
| Auth Module | backend/app/auth/ | Pendiente |
| Moderation | backend/app/services/moderation.py | Pendiente |
| LLM Service | backend/app/services/llm.py | Pendiente |
| Image Service | backend/app/services/image_gen.py | Pendiente |
| TTS Service | backend/app/services/tts.py | Pendiente |
| PDF Service | backend/app/services/pdf.py | Pendiente |
| Payment Service | backend/app/services/payments.py | Pendiente |
| Content Generators | backend/app/generators/ | Pendiente |
| Frontend PWA | frontend/ | Pendiente |

## Comandos
```bash
# Backend
cd C:/personal/quimera/backend
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000

# Frontend
cd C:/personal/quimera/frontend
npm install
npm run dev

# DB
docker run -d --name quimera-pg -p 5436:5432 \
  -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=quimera \
  -v quimera-pgdata:/var/lib/postgresql/data \
  --restart unless-stopped postgres:17
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
