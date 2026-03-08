# PA-001: Setup del proyecto y infraestructura base

**Points:** 3 | **Priority:** Critical | **MoSCoW:** Must Have
**Epic:** EPIC-PA-001 | **DoR Level:** L1 | **Sprint:** 1

## User Story

**As a** developer starting work on Project Admin
**I want** a fully configured project with Docker PostgreSQL, ESM modules, and npm scripts
**So that** the team can begin implementing features on a solid foundation

## Acceptance Criteria

**AC1: Project scaffolding**
- Given a clean checkout of the project repository
- When I run `npm install`
- Then all dependencies are installed without errors
- And the project uses ESM modules (type: "module" in package.json)

**AC2: Docker PostgreSQL container**
- Given Docker Desktop is running
- When I execute the documented docker run command
- Then a PostgreSQL 17 container named `project-admin-pg` starts on port 5433
- And the database `project_admin` is created
- And the container uses a named volume `project-admin-pgdata`
- And the restart policy is `unless-stopped`

**AC3: Environment configuration**
- Given the project is cloned
- When I copy `.env.example` to `.env`
- Then all required variables are documented with default values
- And DATABASE_URL points to localhost:5433/project_admin

**AC4: NPM scripts**
- Given the project is set up
- When I run `npm run start:api` or `npm run start:mcp`
- Then the respective entry point starts without errors
- And `npm test`, `npm run migrate`, `npm run seed` scripts exist

**AC5: Linting and formatting**
- Given the project is set up
- When I run `npm run lint`
- Then ESLint executes with 0 errors and 0 warnings on the initial codebase

## Technical Notes
- Entry points: `src/index.js` (MCP server), `src/server.js` (REST API Fastify)
- Config: `src/config.js` centralized using dotenv
- Docker command per SEED_DOCUMENT.md section 11
- Dependencies: fastify 5.x, pg 8.x, @modelcontextprotocol/sdk, zod 4.x, dotenv
- Dev dependencies: jest, eslint, prettier
- .gitignore must exclude node_modules, .env, coverage/

## Definition of Done
- [ ] package.json with all dependencies and scripts
- [ ] .env.example with all variables documented
- [ ] .gitignore configured
- [ ] Docker PostgreSQL container starts and connects
- [ ] ESLint + Prettier configured
- [ ] src/config.js reads environment variables
- [ ] src/index.js and src/server.js are placeholder entry points
- [ ] README.md with Quick Start section
- [ ] Build with 0 errors, 0 warnings
