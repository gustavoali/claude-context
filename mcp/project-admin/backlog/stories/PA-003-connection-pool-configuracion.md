# PA-003: Connection pool y configuracion centralizada

**Points:** 2 | **Priority:** Critical | **MoSCoW:** Must Have
**Epic:** EPIC-PA-001 | **DoR Level:** L1 | **Sprint:** 1

## User Story

**As a** backend developer
**I want** a configured PostgreSQL connection pool and centralized config module
**So that** all services share a single, properly configured database connection

## Acceptance Criteria

**AC1: Connection pool creation**
- Given the .env file has valid DATABASE_URL
- When the application starts
- Then a pg Pool is created with max 10 connections
- And the pool connects successfully to PostgreSQL on port 5433

**AC2: Connection pool error handling**
- Given the database is not reachable
- When the application tries to connect
- Then a descriptive error is logged with host, port, and database name
- And the application does not crash silently

**AC3: Graceful shutdown**
- Given the application is running with active connections
- When SIGTERM or SIGINT is received
- Then the pool drains all connections before exiting
- And a log message confirms shutdown

**AC4: Config module**
- Given .env file with all variables
- When config.js is imported
- Then it exports an object with all configuration grouped by domain (db, api, mcp, scan)
- And missing required variables throw a descriptive error at startup

## Technical Notes
- File: `src/db/pool.js` - exports Pool instance and query helper
- File: `src/config.js` - loads dotenv, validates, exports config object
- Pool settings: max 10, idleTimeoutMillis 30000, connectionTimeoutMillis 5000
- Export a `query(text, params)` helper function that uses the pool

## Definition of Done
- [ ] pool.js creates and exports configured pool
- [ ] config.js validates and exports all env vars
- [ ] Graceful shutdown on SIGTERM/SIGINT
- [ ] Error handling for connection failures
- [ ] Build with 0 errors, 0 warnings
