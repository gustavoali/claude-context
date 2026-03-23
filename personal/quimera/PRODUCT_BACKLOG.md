# Backlog - Quimera
**Version:** 1.0 | **Actualizacion:** 2026-03-21

## Resumen
| Metrica | Valor |
|---------|-------|
| Total stories | 48 |
| Completadas | 48 (100%) |
| Tests backend | 372 |
| Fecha completado | 2026-03-21 |

## Vision
Plataforma de entretenimiento AI para publico infantil/adolescente argentino (4-19). Cuatro productos integrados (cuentos, historias interactivas, roasts, memes/stickers) con identidad rioplatense, segura para menores, mobile-first.

## Epics
| Epic | Historias | Puntos | Status |
|------|-----------|--------|--------|
| E-01: Project Setup & Infra | QM-001..003 | 8 | Done |
| E-02: Auth & Profiles | QM-004..006 | 13 | Done |
| E-03: Security Core | QM-007..011 | 16 | Done |
| E-04: LLM & Image Services | QM-012..014 | 13 | Done |
| E-05: Cuentos (Tales) | QM-015..018 | 18 | Done |
| E-06: Roasts AI | QM-019..021 | 11 | Done |
| E-07: Payments | QM-022..024 | 13 | Done |
| E-08: Frontend MVP | QM-025..027 | 13 | Done |
| E-09: QA & Hardening | QM-028 | 5 | Done |
| E-10: Historias Interactivas | QM-029..033 | - | Done |
| E-11: Memes & Stickers | QM-034..036 | - | Done |
| E-12: TTS & Audio | QM-037..038 | - | Done |
| E-13: Suscripciones & Growth | QM-039..043 | - | Done |
| E-14: PWA & Expansion | QM-044..048 | - | Done |

## Fase 1 - MVP Cuentos + Roasts (sem 1-4)
### QM-001: Project Scaffold & Docker Setup
**Points:** 3 | **Priority:** Critical | **Epic:** E-01
**As a** developer **I want** the project scaffolded with FastAPI, PG in Docker, Redis **So that** I can start building features.
**AC1:** `docker-compose up -d` starts PG (5436) + Redis with healthchecks passing
**AC2:** `uvicorn app.main:app` starts FastAPI with /docs accessible
**AC3:** pydantic-settings loads from .env; .env.example documents all vars
**AC4:** `alembic upgrade head` creates all schema tables
**Tech:** Docker via WSL. Folder structure per ARCHITECTURE_ANALYSIS.md.
### QM-002: CI Pipeline (GitHub Actions)
**Points:** 2 | **Priority:** High | **Epic:** E-01
**As a** developer **I want** CI with linting and tests on push **So that** regressions are caught early.
**AC1:** Push triggers ruff lint + pytest
**AC2:** Failing test fails the pipeline with clear error
**AC3:** pip-audit runs to check vulnerable dependencies
### QM-003: Structured Logging & Error Handling
**Points:** 3 | **Priority:** High | **Epic:** E-01
**As a** developer **I want** structured logging and global error handler **So that** I debug without leaking data.
**AC1:** structlog logs method, path, status, duration (no PII) for every request
**AC2:** Unhandled exceptions return generic 500 (no stack trace in prod)
**AC3:** Logs never contain minor's name or email, only profile_id
### QM-004: Account Registration & Login
**Points:** 5 | **Priority:** Critical | **Epic:** E-02
**As a** parent or teen (14+) **I want** to register and log in **So that** I can access the platform.
**AC1:** POST /auth/register with valid data creates account + returns JWT pair
**AC2:** Teen (14+) registers with is_parent=false + consent checkbox required
**AC3:** Login returns access token (15 min) + refresh token (7 days) with rotation
**AC4:** Existing email returns generic response (no enumeration)
**AC5:** 5 failed logins triggers 429 with 15 min lockout
**Tech:** bcrypt cost 12+. JWT with account_id, is_parent claims.
### QM-005: Child Profile Management
**Points:** 5 | **Priority:** Critical | **Epic:** E-02
**As a** parent **I want** to create child profiles **So that** children get age-appropriate content.
**AC1:** POST /auth/profiles {name, age} creates profile with DB-generated age_segment
**AC2:** Max 4 profiles per parent; 5th attempt returns 400
**AC3:** GET /auth/profiles returns all children with age_segments
**AC4:** Non-parent account gets 403 on profile creation
**AC5:** JWT after profile switch contains profile_id + age_segment
### QM-006: Profile Ownership Validation (IDOR Prevention)
**Points:** 3 | **Priority:** Critical | **Epic:** E-02
**As a** system **I want** every endpoint to validate profile_id ownership **So that** no user accesses another family's data.
**AC1:** User A's JWT requesting user B's profile returns 403
**AC2:** Dependency verifies account_id ownership from DB for every profile resolution
**AC3:** Tale/roast fetch validates it belongs to requesting account's profile
### QM-007: Input Sanitization Layer
**Points:** 3 | **Priority:** Critical | **Epic:** E-03
**As a** system **I want** all inputs sanitized before LLM prompts **So that** prompt injection is blocked.
**AC1:** sanitize_name strips special chars; only letters/spaces/accents, max 50
**AC2:** sanitize_text strips control chars, truncates at max_len
**AC3:** Pydantic schemas reject invalid input with 422 before any LLM call
**AC4:** "[SYSTEM]" prefixes and brackets stripped from description fields
**Tech:** core/sanitization.py applied as Pydantic validators.
### QM-008: Double Moderation Pipeline
**Points:** 5 | **Priority:** Critical | **Epic:** E-03
**As a** system **I want** pre-LLM and post-LLM moderation **So that** no inappropriate content reaches minors.
**AC1:** pre_validate rejects chiquis themes with violence/death/adult topics
**AC2:** post_validate checks output against keyword blocklist + content classifier
**AC3:** Post-validation failure retries once, then returns generic error
**AC4:** Roast output moderation rejects insults about appearance/race/gender/disability
**AC5:** All moderation events logged with prompt hash, segment, result
**Tech:** services/moderation.py. Keyword blocklist (fast) + LLM classifier (edge cases).
### QM-009: Age-Gate Middleware
**Points:** 3 | **Priority:** Critical | **Epic:** E-03
**As a** system **I want** endpoints gated by age segment **So that** chiquis cannot access roasts.
**AC1:** Profile age=7 requesting /roasts/generate gets 403
**AC2:** @require_age(min=14) verifies age from DB, not just JWT
**AC3:** Denied attempts logged with profile_id and endpoint
**AC4:** Profile age=15 requesting /roasts/generate succeeds
### QM-010: Rate Limiting
**Points:** 3 | **Priority:** Critical | **Epic:** E-03
**As a** system **I want** rate limits on generation and auth endpoints **So that** abuse is prevented.
**AC1:** /auth/register: max 3/hour per IP
**AC2:** /tales/generate: max 5/hour per account
**AC3:** /roasts/generate: max 10/hour per account
**AC4:** Global: max 100 req/min per IP
**Tech:** slowapi with Redis backend.
### QM-011: Security Headers & JWT Hardening
**Points:** 2 | **Priority:** High | **Epic:** E-03
**As a** system **I want** security headers and hardened JWT **So that** common vulnerabilities are mitigated.
**AC1:** All responses include HSTS, CSP, X-Content-Type-Options, X-Frame-Options
**AC2:** Access token expires 15 min, refresh token 7 days
**AC3:** Used refresh tokens are rejected (rotation enforced)
**AC4:** /docs returns 404 when ENVIRONMENT=production
### QM-012: LLM Service (Multi-Provider)
**Points:** 5 | **Priority:** Critical | **Epic:** E-04
**As a** developer **I want** LLM abstraction with multiple providers **So that** I switch per product and have fallbacks.
**AC1:** provider_hint="claude" uses Claude API
**AC2:** provider_hint="openai" uses GPT-4o-mini
**AC3:** provider_hint="groq" uses Groq/Llama (dev)
**AC4:** Primary failure triggers fallback provider
**AC5:** Every call returns cost_usd calculated from token usage
**Tech:** services/llm.py. OpenAI SDK for GPT+Groq (L-032). Config per product in env vars.
### QM-013: Image Generation Service
**Points:** 5 | **Priority:** Critical | **Epic:** E-04
**As a** developer **I want** image generation for tale illustrations **So that** cuentos have cartoon-style AI art.
**AC1:** generate() returns cartoon illustration bytes from text description
**AC2:** Prompt always includes "cartoon illustration for children" never "realistic photo of child"
**AC3:** Images stored via StorageService with signed URLs
**AC4:** DALL-E failure uses placeholder; tale still generates
**AC5:** Cost tracked in cost_tracking table
### QM-014: PDF Generation Service
**Points:** 3 | **Priority:** High | **Epic:** E-04
**As a** developer **I want** PDF assembly for downloadable tales **So that** parents can download/print cuentos.
**AC1:** pdf.generate(pages, images) creates styled PDF with text + illustrations
**AC2:** PDF stored via StorageService with expiring signed URL
**AC3:** Child's name appears as protagonist; text in rioplatense Spanish
### QM-015: Tale Generator (Orchestrator)
**Points:** 5 | **Priority:** Critical | **Epic:** E-05
**As a** developer **I want** tale generator orchestrating LLM+images+PDF **So that** the cuento pipeline works e2e.
**AC1:** TaleGenerator.generate({child_name, age, theme, character}) calls LLM, image gen, PDF
**AC2:** System prompt instructs rioplatense Spanish with age-appropriate vocabulary
**AC3:** tale.status and progress updated in DB as generation advances
**AC4:** Moderation failure on a page triggers 1 retry, then error
**Tech:** generators/tale.py. Runs as FastAPI BackgroundTask.
### QM-016: Tales API Endpoints
**Points:** 3 | **Priority:** Critical | **Epic:** E-05
**As a** parent **I want** to generate and view cuentos **So that** my child gets a unique story each night.
**AC1:** POST /tales/generate returns 202 {task_id, status: "processing"}
**AC2:** GET /tales/tasks/{id} returns progress while processing
**AC3:** GET /tales/tasks/{id} returns completed tale with pages and pdf_url
**AC4:** GET /tales?profile_id=X returns paginated list (ownership validated)
**AC5:** GET /tales/{id} returns full tale detail for owner
### QM-017: Tale Prompt Engineering
**Points:** 3 | **Priority:** High | **Epic:** E-05
**As a** PO **I want** cuento prompts tuned for Argentine children **So that** output feels authentic.
**AC1:** Age 4-5: simple vocabulary, short sentences, gentle themes
**AC2:** Age 7-8: richer vocabulary, adventure elements, humor
**AC3:** Output uses vos/che/argentinisms naturally
**AC4:** Character parameter is central to the story
### QM-018: Ephemeral Photo Processing
**Points:** 2 | **Priority:** Critical | **Epic:** E-05
**As a** system **I want** photos processed in memory only and immediately discarded **So that** we comply with data protection.
**AC1:** Base64 photo decoded to bytes in memory only (never disk/tmp)
**AC2:** After response, bytes deleted + gc.collect()
**AC3:** Error path still cleans up (finally block)
**AC4:** No base64 data in any log entry
### QM-019: Roast Generator
**Points:** 5 | **Priority:** Critical | **Epic:** E-06
**As a** developer **I want** roast generator with Argentine humor and anti-bullying **So that** teens get safe, funny roasts.
**AC1:** {description, variant="red_flag"} generates humorous roast in Argentine Spanish
**AC2:** variant="serie_character" compares person to a TV/movie character
**AC3:** Post-moderation rejects insults about appearance/race/gender/disability
**AC4:** Photo (optional) analyzed via vision API, then ephemeral processing (QM-018)
**Tech:** generators/roast.py. Sync (~3 sec). Share token = UUIDv4.
### QM-020: Roasts API Endpoints
**Points:** 3 | **Priority:** Critical | **Epic:** E-06
**As a** teen (14+) **I want** to generate and share roasts **So that** I share AI humor with friends.
**AC1:** POST /roasts/generate (age>=14) returns 200 {id, text, share_url, variant}
**AC2:** GET /roasts/{id} by owner returns full detail
**AC3:** GET /share/{token} (public) shows roast text without profile data
**AC4:** Age=10 requesting /roasts/generate gets 403
### QM-021: Roast Prompt Engineering
**Points:** 3 | **Priority:** High | **Epic:** E-06
**As a** PO **I want** roast prompts tuned for safe Argentine teen humor **So that** roasts are authentic, never bullying.
**AC1:** System prompt forbids insults about physical traits, race, gender, disability
**AC2:** variant="red_flag" references Argentine culture (fernet, bondi, colegio, cumple de 15)
**AC3:** Humor is self-deprecating/ironic (Argentine style), never mean-spirited
### QM-022: Payment Service (MercadoPago)
**Points:** 5 | **Priority:** High | **Epic:** E-07
**As a** developer **I want** MercadoPago integration **So that** Argentine users pay with local methods.
**AC1:** POST /payments/checkout creates MP preference and returns checkout_url
**AC2:** Successful webhook (signature verified) records transaction and unlocks product
**AC3:** Invalid webhook signature returns 400 + security log
**AC4:** Price calculated server-side, never from client
**Tech:** services/payments.py. PaymentProvider interface. MP SDK.
### QM-023: Webhook Processing & Transactions
**Points:** 5 | **Priority:** High | **Epic:** E-07
**As a** system **I want** idempotent webhook processing with audit trail **So that** payments are reliable.
**AC1:** Duplicate provider_tx_id is ignored (idempotent)
**AC2:** Transaction recorded with account_id, product_type, amount, provider, status
**AC3:** Raw webhook payload stored for audit
**AC4:** Payment completion triggers/unlocks associated content generation
### QM-024: Cost Tracking & Circuit Breaker
**Points:** 3 | **Priority:** High | **Epic:** E-07
**As a** operator **I want** AI cost tracking with automatic cutoff **So that** cost spikes are caught.
**AC1:** Every LLM/image generation updates cost_tracking (date, product_type, provider, cost)
**AC2:** Daily cost > threshold rejects generation with "service temporarily unavailable"
**AC3:** GET /admin/costs?range=7d returns daily breakdown (admin only)
### QM-025: Frontend - Landing Page
**Points:** 5 | **Priority:** High | **Epic:** E-08
**As a** visitor **I want** a mobile-first landing page **So that** I understand and want to register.
**AC1:** Mobile view shows hero, 4 product cards, pricing, CTA
**AC2:** Content in rioplatense Spanish with Argentine identity
**AC3:** Lighthouse: performance >80, accessibility >90
**AC4:** CTAs navigate to register or product demo
### QM-026: Frontend - Tale Generation Flow
**Points:** 5 | **Priority:** High | **Epic:** E-08
**As a** parent **I want** a UI to generate cuentos **So that** I create personalized bedtime stories.
**AC1:** Profile selection shows tale form (name pre-filled, theme, character)
**AC2:** Processing shows progress indicator with animated state
**AC3:** Completion shows tale pages with illustrations + download PDF button
**AC4:** /tales shows paginated history for selected profile
### QM-027: Frontend - Roast Generation Flow
**Points:** 3 | **Priority:** High | **Epic:** E-08
**As a** teen **I want** a UI to generate and share roasts **So that** I get funny roasts and share via WhatsApp.
**AC1:** /roasts shows variant selector + description input
**AC2:** Result shows roast text + "Share on WhatsApp" button
**AC3:** Share button opens WhatsApp with pre-filled share URL
**AC4:** Share URL displays roast text publicly (no profile data)
### QM-028: E2E Testing & Security Validation
**Points:** 5 | **Priority:** High | **Epic:** E-09
**As a** developer **I want** e2e tests on critical security paths **So that** MVP launches with confidence.
**AC1:** Age-gate bypass tests pass (chiquis cannot access roasts)
**AC2:** IDOR tests pass (profile ownership validated)
**AC3:** Prompt injection tests pass (malicious input sanitized)
**AC4:** Rate limiting tests pass (429 after threshold)
**AC5:** Happy path e2e: register -> profile -> generate tale -> download PDF

## Fase 2 - Historias + Stickers + TTS (sem 5-8)
| ID | Titulo | Points | Priority | Epic |
|----|--------|--------|----------|------|
| QM-029 | Story Generator (Choose Your Adventure engine) | 8 | High | E-10 |
| QM-030 | Stories API (start, choose, chapters) | 5 | High | E-10 |
| QM-031 | Story Prompt Engineering (Argentine adventure) | 3 | High | E-10 |
| QM-032 | Frontend - Interactive Story Player | 5 | High | E-10 |
| QM-033 | Story Sagas & Daily Chapters | 3 | Medium | E-10 |
| QM-034 | Meme Generator (templates + AI text) | 5 | High | E-11 |
| QM-035 | Sticker Pack Generator (WhatsApp format) | 5 | High | E-11 |
| QM-036 | Memes/Stickers API & Frontend | 3 | High | E-11 |
| QM-037 | TTS Service Integration (audio for tales) | 5 | High | E-12 |
| QM-038 | Audio Player in Tale View | 2 | Medium | E-12 |

## Fase 3 - Suscripciones + Growth (mes 3-4)
| ID | Titulo | Points | Priority | Epic |
|----|--------|--------|----------|------|
| QM-039 | Subscription Plans & Management | 5 | High | E-13 |
| QM-040 | Recurring Payments (MP + Stripe) | 8 | High | E-13 |
| QM-041 | User Profiles & Preferences (avatars) | 3 | Medium | E-13 |
| QM-042 | SEO Optimization (SSR, meta, structured data) | 3 | Medium | E-13 |
| QM-043 | Analytics & Metrics Dashboard (admin) | 3 | Medium | E-13 |

## Fase 4 - PWA & Expansion (mes 5+)
| ID | Titulo | Points | Priority | Epic |
|----|--------|--------|----------|------|
| QM-044 | PWA Enhancements (offline, push) | 5 | Medium | E-14 |
| QM-045 | Stable Diffusion Self-Hosted (cost reduction) | 8 | Medium | E-14 |
| QM-046 | LATAM Expansion (localization) | 5 | Low | E-14 |
| QM-047 | Stripe Integration (international) | 5 | Medium | E-14 |
| QM-048 | Account Deletion & AAIP Compliance | 3 | High | E-14 |

## Completadas (indice)
| ID | Titulo | Puntos | Fecha | Detalle |
|----|--------|--------|-------|---------|

## ID Registry
| Rango | Estado |
|-------|--------|
| QM-001..QM-028 | Fase 1 (detalladas) |
| QM-029..QM-038 | Fase 2 (alto nivel) |
| QM-039..QM-043 | Fase 3 (alto nivel) |
| QM-044..QM-048 | Fase 4 (alto nivel) |
| **Proximo ID:** | **QM-049** |
