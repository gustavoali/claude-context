## NR-002: Configuracion y gestion de API keys

**As a** developer
**I want** a centralized configuration module that loads API keys and settings from environment
**So that** providers can access their credentials securely without hardcoding

### Acceptance Criteria

**AC1: Config module loads from .env**
- Given a .env file exists with API keys
- When I import `narrador.config`
- Then settings are loaded from .env via python-dotenv
- And each setting has a sensible default (None for optional API keys)

**AC2: Output directory configuration**
- Given OUTPUT_DIR is set in .env (or not)
- When the config is loaded
- Then output_dir defaults to `./output/` if not specified
- And the directory is created automatically if it doesn't exist

**AC3: Provider availability detection**
- Given some API keys are present and others are not
- When I call `config.available_providers()`
- Then it returns a list of providers with valid credentials
- And Edge TTS is always in the list (no key required)

**AC4: Validation on access**
- Given OPENAI_API_KEY is not set
- When a provider tries to access it
- Then a clear error message indicates which key is missing
- And suggests checking .env.example

### Technical Notes
- File: `src/narrador/config.py`
- Use pydantic-settings or plain dataclass + dotenv
- Keep it simple: dataclass preferred over pydantic for micro scale
- Settings: OPENAI_API_KEY, ELEVENLABS_API_KEY, OUTPUT_DIR, DEFAULT_PROVIDER, DEFAULT_LANGUAGE

### Definition of Done
- [ ] config.py implemented with all settings
- [ ] .env loading works correctly
- [ ] available_providers() returns correct list based on env
- [ ] Unit tests for config loading (with/without .env)
- [ ] No API keys hardcoded anywhere

### Story Points: 2
### Priority: Critical
### Epic: EPIC-001: Project Setup & Infrastructure
