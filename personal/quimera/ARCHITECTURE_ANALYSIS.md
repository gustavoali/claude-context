# Arquitectura - Quimera
**Version:** 0.1.0 | **Fecha:** 2026-03-21

## Diagrama de Componentes

```
                         +------------------+
                         |   Next.js PWA    |
                         |  (mobile-first)  |
                         +--------+---------+
                                  |
                           HTTPS / JSON
                                  |
                         +--------v---------+
                         |   FastAPI App     |
                         |   (uvicorn)       |
                         +--------+---------+
                                  |
              +-------------------+-------------------+
              |                   |                   |
     +--------v------+  +--------v------+  +---------v-----+
     |  API Router   |  |  Auth Module  |  | Moderation    |
     |  /stories     |  |  JWT + RBAC   |  | (age filters) |
     |  /roasts      |  |  parent/child |  | prompt guard  |
     |  /memes       |  +---------------+  +---------------+
     |  /tales       |
     |  /payments    |
     |  /users       |
     +-------+-------+
              |
     +--------v---------+
     |  Service Layer    |
     |  (business logic) |
     +--------+---------+
              |
   +----------+----------+----------+----------+
   |          |          |          |          |
+--v--+  +---v---+  +---v---+  +--v---+  +---v----+
| LLM |  | Image |  | TTS   |  | PDF  |  |Payment |
|Svc  |  | Gen   |  | Svc   |  | Svc  |  |  Svc   |
+--+--+  +---+---+  +---+---+  +--+---+  +---+----+
   |         |          |         |           |
   v         v          v         v           v
Claude/   DALL-E/     Edge     fpdf2     MercadoPago
GPT-4o    SD local    TTS                Stripe

              +----------+----------+
              |          |          |
         +----v---+ +---v----+ +---v----+
         |  PG    | | Redis  | | Object |
         | (5436) | | cache  | | Store  |
         +--------+ +--------+ +--------+
```

## Componentes

| Componente | Ubicacion | Responsabilidad |
|------------|-----------|-----------------|
| FastAPI App | `backend/app/main.py` | Entry point, middleware, CORS, lifespan |
| API Routers | `backend/app/api/v1/` | Endpoints por dominio (tales, stories, roasts, memes, users, payments) |
| Auth Module | `backend/app/auth/` | JWT, parent/child accounts, age-gated access |
| Moderation | `backend/app/services/moderation.py` | Filtros etarios, prompt guard, anti-bullying |
| LLM Service | `backend/app/services/llm.py` | Abstraccion multi-provider (Claude, GPT, Groq) |
| Image Service | `backend/app/services/image_gen.py` | DALL-E 3 / SD, procesamiento efimero |
| TTS Service | `backend/app/services/tts.py` | Text-to-speech para cuentos (Fase 2) |
| PDF Service | `backend/app/services/pdf.py` | Generacion de cuentos descargables |
| Payment Service | `backend/app/services/payments.py` | MercadoPago + Stripe, webhooks |
| Content Generators | `backend/app/generators/` | Logica de negocio por producto (tale, story, roast, meme) |
| Models | `backend/app/models/` | SQLAlchemy ORM models |
| Schemas | `backend/app/schemas/` | Pydantic request/response |
| DB | `backend/app/db/` | Session, migrations (Alembic) |
| Config | `backend/app/core/config.py` | Settings via pydantic-settings, env vars |

## Flujo de Datos

### Cuento Personalizado (Fase 1)
```
1. POST /api/v1/tales/generate {child_name, age, theme, character}
2. Auth middleware: verifica JWT, cuenta padre, perfil hijo
3. Moderation: valida inputs (age-appropriate theme, no PII extra)
4. TaleGenerator:
   a. LLM Service -> genera texto (5-10 paginas)
   b. Image Service -> genera 5-10 ilustraciones
   c. PDF Service -> ensambla cuento
   d. (Fase 2) TTS Service -> genera audio
5. Response: {tale_id, pdf_url, pages: [...], audio_url?}
6. Payment: cobro unitario o descuento de credito de suscripcion
```

### Roast AI (Fase 1)
```
1. POST /api/v1/roasts/generate {description, variant, age_segment}
   (foto: procesamiento efimero, NO se almacena)
2. Auth middleware: verifica JWT, edad >= 14
3. Moderation: filtro anti-bullying, safe mode
4. RoastGenerator:
   a. (opcional) Image analysis -> descripcion textual
   b. LLM Service -> genera roast en tono argentino
   c. Moderation post-gen: valida output
5. Response: {roast_id, text, share_url}
```

### Historia Interactiva (Fase 2)
```
1. POST /api/v1/stories/start {genre, character_name, age}
2. StoryGenerator: LLM genera prologo + 2-3 opciones
3. POST /api/v1/stories/{id}/choose {choice_id}
4. LLM continua desde contexto acumulado + eleccion
5. Repite hasta final. Guarda arbol de decisiones.
```

## ADRs (Architecture Decision Records)

### ADR-001: Modular Monolith vs Microservices

**Contexto:** 4 productos con servicios compartidos (LLM, images, auth). 1 developer.

| Opcion | Pros | Contras |
|--------|------|---------|
| Microservices | Escalado independiente, deploy aislado | Overhead operacional, 1 dev no puede mantener |
| **Modular Monolith** | Simple, 1 deploy, refactor facil, shared DB | Todo escala junto, boundaries requieren disciplina |

**Decision:** Modular monolith. Un solo proceso FastAPI con modulos bien separados. Extraer a servicios solo si aparece bottleneck real.

**Consecuencias:** Boundaries entre modulos via imports explícitos. No shared state entre generators. Service layer como abstraccion permite extraer despues.

### ADR-002: LLM Provider Strategy

**Contexto:** Costos AI variables. Claude es mejor para tono argentino pero mas caro. Necesitamos fallback.

| Opcion | Pros | Contras |
|--------|------|---------|
| Single provider (Claude) | Simplicidad, mejor calidad | Vendor lock-in, sin fallback, costo fijo alto |
| **Multi-provider con abstraccion** | Fallback, A/B testing, optimizacion costos | Mas codigo, prompts distintos por provider |

**Decision:** `LLMService` con interface comun. Provider configurable por tipo de contenido. Claude para cuentos (calidad importa), GPT-4o-mini para roasts (volumen importa), Groq/Llama para dev.

**Consecuencias:** Cada generator pide `llm.generate(prompt, provider_hint)`. Config por producto en env vars. Monitoreo de costo por generacion.

### ADR-003: Image Storage Strategy

**Contexto:** Fotos de menores NO se almacenan (requisito legal). Imagenes generadas si.

| Opcion | Pros | Contras |
|--------|------|---------|
| S3/R2 (object storage) | Escalable, CDN ready | Costo adicional, setup |
| **Filesystem + CDN lazy** | Simple, gratis en Railway, migrable | No escala a millones de assets |
| Base64 en DB | Zero infra | DB se infla, lento |

**Decision:** Filesystem local (Railway persistent volume) para Fase 1. Migrar a S3/R2 cuando supere 10GB. Imagenes generadas se guardan; fotos de input se procesan en memoria y se descartan.

**Consecuencias:** `StorageService` abstrae filesystem vs S3. Path: `/storage/tales/{id}/`, `/storage/memes/{id}/`. Migration path claro.

### ADR-004: Auth Model para Menores

**Contexto:** Menores de 13 no pueden tener cuenta propia (Ley 25.326). Adolescentes 14-19 si, con restricciones.

| Opcion | Pros | Contras |
|--------|------|---------|
| **Parent account + child profiles** | Compliant, padre controla | UX mas compleja para teens |
| Age self-declaration | Simple | No compliant, riesgo legal |

**Decision:** Parent account obligatoria para <13. Teens 14+ pueden crear cuenta propia con consent checkbox. Parent account puede tener hasta 4 child profiles. Cada profile tiene age_segment que gate-a productos.

**Consecuencias:** JWT contiene `account_id` + `profile_id` + `age_segment`. Middleware valida acceso por segment.

### ADR-005: Async Generation vs Sync

**Contexto:** Generar un cuento (LLM + 5-10 images + PDF) toma 30-60 seg. Roasts son rapidos (~3 seg).

| Opcion | Pros | Contras |
|--------|------|---------|
| Todo sync | Simple | Cuentos bloquean, timeout |
| Todo async (queue) | Escalable | Over-engineering para roasts |
| **Hibrido: sync rapido, async lento** | Cada producto con UX optima | Dos patterns en el codigo |

**Decision:** Roasts y memes: sync (respuesta inmediata). Cuentos e historias: async con polling. Background tasks de FastAPI para Fase 1, migrar a ARQ/Redis queue si necesario.

**Consecuencias:** `POST /tales/generate` retorna `{task_id, status: "processing"}`. `GET /tales/tasks/{id}` para polling. WebSocket opcional en Fase 2.

## Folder Structure

```
backend/
  app/
    main.py                       # FastAPI app, lifespan, middleware
    core/                         # config.py (pydantic-settings), security.py (JWT), exceptions.py
    auth/                         # router.py, dependencies.py, models.py, schemas.py
    api/v1/                       # tales.py, roasts.py, stories.py, memes.py, payments.py, users.py
    services/                     # llm.py, image_gen.py, tts.py, pdf.py, payments.py,
                                  # moderation.py, storage.py
    generators/                   # tale.py, roast.py, story.py, meme.py
    models/                       # base.py, user.py, content.py, payment.py
    schemas/                      # tales.py, roasts.py, stories.py, memes.py, common.py
    db/                           # session.py, migrations/ (Alembic)
  tests/                          # conftest.py, test_generators/, test_services/, test_api/
  requirements.txt
  alembic.ini
frontend/                         # Next.js PWA (Fase 2+)
docker-compose.yml                # PG + Redis (dev)
.env.example
```

## API Contracts

### Tales (Fase 1)
```
POST /api/v1/tales/generate
  Body: {child_name: str, age: int(4-8), theme: str, character?: str}
  Auth: JWT (parent account)
  Response 202: {task_id: uuid, status: "processing"}

GET /api/v1/tales/tasks/{task_id}
  Response 200: {status: "completed", tale: {id, title, pages: [{text, image_url}], pdf_url}}
  Response 200: {status: "processing", progress: 0.6}

GET /api/v1/tales/{tale_id}
  Response 200: {id, title, pages, pdf_url, audio_url?, created_at}

GET /api/v1/tales?profile_id=X&page=1&size=10
  Response 200: {items: [...], total, page, size}
```

### Roasts (Fase 1)
```
POST /api/v1/roasts/generate
  Body: {description: str, variant: "red_flag"|"serie_character"|"profile_pic", photo?: base64}
  Auth: JWT (age >= 14)
  Response 200: {id, text, share_url, variant}

GET /api/v1/roasts/{roast_id}
  Response 200: {id, text, variant, share_url, created_at}
```

### Auth
```
POST /api/v1/auth/register
  Body: {email, password, name, is_parent: bool}
  Response 201: {account_id, token}

POST /api/v1/auth/login
  Body: {email, password}
  Response 200: {token, account: {id, profiles: [...]}}

POST /api/v1/auth/profiles
  Body: {name, age, avatar_preference?}
  Auth: JWT (parent)
  Response 201: {profile_id, name, age_segment}
```

### Payments
```
POST /api/v1/payments/checkout
  Body: {product_type, product_id?, plan_id?, provider: "mercadopago"|"stripe"}
  Auth: JWT
  Response 200: {checkout_url, preference_id}

POST /api/v1/payments/webhook/{provider}
  Body: provider-specific payload
  Response 200: {ok: true}
```

## Database Schema

```
accounts
  id            UUID PK
  email         VARCHAR(255) UNIQUE NOT NULL
  password_hash VARCHAR(255) NOT NULL
  name          VARCHAR(100) NOT NULL
  is_parent     BOOLEAN DEFAULT true
  created_at    TIMESTAMPTZ DEFAULT now()
  INDEX idx_accounts_email ON (email)

profiles
  id            UUID PK
  account_id    UUID FK -> accounts NOT NULL
  name          VARCHAR(50) NOT NULL
  age           SMALLINT NOT NULL CHECK (age BETWEEN 4 AND 19)
  age_segment   VARCHAR(20) GENERATED ALWAYS AS (
                  CASE WHEN age BETWEEN 4 AND 8 THEN 'chiquis'
                       WHEN age BETWEEN 9 AND 13 THEN 'pibes'
                       WHEN age BETWEEN 14 AND 19 THEN 'adolescentes' END
                ) STORED
  avatar_url    VARCHAR(500)
  created_at    TIMESTAMPTZ DEFAULT now()
  INDEX idx_profiles_account ON (account_id)

subscription_plans
  id            UUID PK
  name          VARCHAR(50) NOT NULL        -- chiquis, pibes, adolescente, familiar
  price_usd     DECIMAL(6,2) NOT NULL
  max_profiles  SMALLINT DEFAULT 1
  features      JSONB NOT NULL              -- {tales_per_month: 30, stories: true, ...}

subscriptions
  id            UUID PK
  account_id    UUID FK -> accounts NOT NULL
  plan_id       UUID FK -> subscription_plans NOT NULL
  status        VARCHAR(20) DEFAULT 'active' -- active, cancelled, expired
  started_at    TIMESTAMPTZ DEFAULT now()
  expires_at    TIMESTAMPTZ
  provider      VARCHAR(20) NOT NULL        -- mercadopago, stripe
  provider_sub_id VARCHAR(100)
  INDEX idx_subs_account ON (account_id)

tales
  id            UUID PK
  profile_id    UUID FK -> profiles NOT NULL
  title         VARCHAR(200) NOT NULL
  theme         VARCHAR(100)
  character     VARCHAR(100)
  pages         JSONB NOT NULL              -- [{page_num, text, image_path}]
  pdf_path      VARCHAR(500)
  audio_path    VARCHAR(500)
  status        VARCHAR(20) DEFAULT 'processing'
  llm_provider  VARCHAR(30)
  cost_usd      DECIMAL(6,4)               -- AI generation cost tracking
  created_at    TIMESTAMPTZ DEFAULT now()
  INDEX idx_tales_profile ON (profile_id)
  INDEX idx_tales_created ON (created_at DESC)

roasts
  id            UUID PK
  profile_id    UUID FK -> profiles
  description   TEXT NOT NULL
  variant       VARCHAR(30) NOT NULL
  output_text   TEXT NOT NULL
  share_token   VARCHAR(32) UNIQUE          -- for share URLs
  llm_provider  VARCHAR(30)
  cost_usd      DECIMAL(6,4)
  created_at    TIMESTAMPTZ DEFAULT now()
  INDEX idx_roasts_share ON (share_token)

-- Fase 2 tables (stories, story_chapters, meme_packs) follow same pattern:
-- stories: id, profile_id FK, genre, title, character JSONB, status, created_at
-- story_chapters: id, story_id FK, chapter_num, text, choices JSONB, parent_chapter_id FK
-- meme_packs: id, profile_id FK, theme, items JSONB, cost_usd, created_at

transactions
  id            UUID PK
  account_id    UUID FK -> accounts NOT NULL
  product_type  VARCHAR(30) NOT NULL        -- tale, roast, meme_pack, subscription
  product_id    UUID
  amount_usd    DECIMAL(8,2) NOT NULL
  provider      VARCHAR(20) NOT NULL
  provider_tx_id VARCHAR(100)
  status        VARCHAR(20) DEFAULT 'pending'
  created_at    TIMESTAMPTZ DEFAULT now()
  INDEX idx_tx_account ON (account_id, created_at DESC)
  INDEX idx_tx_provider ON (provider, provider_tx_id)

cost_tracking
  id            UUID PK
  date          DATE NOT NULL
  product_type  VARCHAR(30) NOT NULL
  provider      VARCHAR(30) NOT NULL        -- claude, openai, dalle, groq
  requests      INTEGER DEFAULT 0
  total_cost    DECIMAL(8,4) DEFAULT 0
  UNIQUE (date, product_type, provider)
```

## Testing Strategy

| Capa | Framework | Coverage Target | Que testear |
|------|-----------|----------------|-------------|
| Generators | pytest | >80% | Logica de orquestacion, moderation filters |
| Services | pytest + mocks | >70% | LLM abstraction, payment flows, storage |
| API | pytest + httpx | >70% | Auth, age gating, request validation |
| Moderation | pytest | >90% | Filtros etarios, anti-bullying (CRITICO) |
| E2E | Playwright | Happy paths | Flujo completo cuento, roast, pago |

**Performance Targets (Fase 1):**
| Operacion | Target | Metodo |
|-----------|--------|--------|
| Roast generation | < 5 seg | Sync, LLM streaming |
| Tale generation | < 90 seg | Async, progress polling |
| API response (non-gen) | < 200 ms | Cache Redis |
| Concurrent users | 50 | uvicorn workers |

## Technical Debt / Riesgos

| ID | Descripcion | Severidad | Mitigacion |
|----|-------------|-----------|------------|
| TD-001 | Filesystem storage no escala | Low (Fase 1) | StorageService abstraction, migrar a S3 en Fase 3 |
| TD-002 | Background tasks de FastAPI sin retry | Medium | Suficiente para MVP, migrar a ARQ si falla >1%  |
| TD-003 | Sin rate limiting en API | High | Implementar slowapi en semana 2 |
| TD-004 | Sin monitoring de costos AI en tiempo real | Medium | cost_tracking table + alerta diaria |
| RISK-001 | Contenido inapropiado generado por LLM | Critical | Double moderation (pre-prompt + post-output) |
| RISK-002 | MercadoPago bloquea cuenta | High | Stripe como fallback, PaymentService abstraction |
| RISK-003 | Costos DALL-E escalan con volumen | Medium | Stable Diffusion self-hosted como fallback Fase 3 |
