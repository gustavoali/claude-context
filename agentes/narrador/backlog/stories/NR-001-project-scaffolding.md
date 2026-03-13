## NR-001: Project scaffolding y entorno de desarrollo

**As a** developer
**I want** a properly structured Python project with virtual environment and dependencies
**So that** I can start implementing TTS providers with a consistent development setup

### Acceptance Criteria

**AC1: Project structure created**
- Given the narrador repository exists at C:/agentes/narrador
- When the scaffolding is complete
- Then the directory structure matches the architecture in SEED_DOCUMENT.md
- And all __init__.py files exist for proper package resolution

**AC2: Virtual environment and dependencies**
- Given pyproject.toml is configured with project metadata
- When I run `pip install -e ".[dev]"`
- Then all runtime deps (edge-tts, openai, pydub, python-dotenv) install successfully
- And all dev deps (pytest, ruff) install successfully

**AC3: Basic tooling works**
- Given the project is installed in editable mode
- When I run `pytest` from the project root
- Then pytest discovers the tests/ directory (even if empty)
- And when I run `ruff check src/` there are 0 errors

**AC4: .env.example provided**
- Given the project root
- When I check .env.example
- Then it lists all required API keys with placeholder values (OPENAI_API_KEY, ELEVENLABS_API_KEY)
- And it documents which are optional vs required

### Technical Notes
- Use `pyproject.toml` (not setup.py) for modern Python packaging
- Python 3.11+ as minimum version
- Edge TTS has no API key requirement - document this clearly
- Include .gitignore with Python defaults + .env + output/
- Output directory for generated audio: configurable via env var, default `./output/`

### Definition of Done
- [ ] Directory structure created per SEED_DOCUMENT architecture
- [ ] pyproject.toml with all deps and metadata
- [ ] Virtual environment created and deps installed
- [ ] .env.example with documented variables
- [ ] .gitignore configured
- [ ] pytest runs (0 tests, no errors)
- [ ] ruff check passes

### Story Points: 2
### Priority: Critical
### Epic: EPIC-001: Project Setup & Infrastructure
