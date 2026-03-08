# PA-012: MCP server entry point y setup

**Points:** 3 | **Priority:** Critical | **MoSCoW:** Must Have
**Epic:** EPIC-PA-003 | **DoR Level:** L1 | **Sprint:** 1

## User Story

**As a** Claude Code user
**I want** Project Admin to expose an MCP server
**So that** I can interact with the project registry directly from my IDE

## Acceptance Criteria

**AC1: MCP server starts**
- Given the database is running and migrated
- When I run `npm run start:mcp` (or `node src/index.js`)
- Then an MCP server starts using stdio transport
- And it announces server name "project-admin" and version from config

**AC2: Server registration**
- Given the MCP server is running
- When Claude Code discovers the server
- Then it appears as "project-admin" in the available MCP servers
- And tools are listed with their descriptions

**AC3: Error handling on startup**
- Given the database is not available
- When the MCP server starts
- Then a descriptive error is logged
- And the server does not hang indefinitely

**AC4: Graceful shutdown**
- Given the MCP server is running
- When the stdio connection is closed
- Then the database pool is drained
- And the process exits cleanly

## Technical Notes
- File: `src/index.js`
- Uses @modelcontextprotocol/sdk McpServer class
- Transport: StdioServerTransport (standard for Claude Code)
- Server name and version from config.js
- Initializes DB pool, registers all tools from src/mcp/tools/index.js, then starts
- Follow SBM pattern for tool registration

## Definition of Done
- [ ] index.js starts MCP server with stdio transport
- [ ] DB pool initialization on startup
- [ ] Graceful shutdown on connection close
- [ ] MCP server registration documented in README
- [ ] Build with 0 errors, 0 warnings
