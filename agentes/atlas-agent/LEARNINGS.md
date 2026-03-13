# Learnings - Atlas Agent

### 2026-03-06 - Independent modules composed by AI meta-session
**Context:** Implementing ATL-004 through ATL-008 modules for the Atlas Agent (session-lifecycle, backlog-manager, block-detector, context-assembly, state-persistence)
**Learning:** When building modules that will be orchestrated by an AI meta-session (Claude Code), design them as fully independent units with no cross-imports. The AI composes them at runtime based on its system prompt. This eliminates coupling, simplifies unit testing (no complex mock graphs), and lets you iterate each module independently without cascading changes.
**Applies to:** Projects where an AI agent coordinates multiple functional modules; agent-based architectures using Claude Code or similar LLM orchestration

### 2026-03-06 - Batch implementation with dependency-ordered waves
**Context:** Implementing 8 stories across 4 batches, each batch depending on the previous one
**Learning:** When implementing a set of stories with dependency chains, group them into "waves" (batches) where stories within a batch are independent but depend on prior batches. Implement each batch, run full test suite, commit, then proceed to next batch. This gives clean rollback points and catches integration issues early without waiting until the end.
**Applies to:** Any project with multiple interdependent stories being implemented in a single session

### 2026-03-06 - Custom MCP server preferred over community when scope is narrow and well-defined
**Context:** Researched 9 existing Telegram MCP servers to evaluate replacing Atlas Agent's custom telegram-mcp (~200 LOC, 3 tools). Best community candidate (electricessence/Telegram-Bridge-MCP) had superior features but was pre-release, heavy (Whisper, TTS, file mgmt), and had 1 star.
**Learning:** When your MCP server needs are narrow (3 specific tools), a custom implementation of ~200 LOC with exactly the features you need (rate limiting, timeout, lazy init) is preferable to adopting a community server that's either feature-incomplete or feature-bloated. Key decision factors: (1) no candidate is a drop-in replacement, (2) all Bot API candidates have low adoption (<50 stars), (3) custom code is fully controlled and integrated with project config. Reserve community adoption for when you need features that would significantly expand your LOC (voice, files, live status).
**Applies to:** Any project evaluating build-vs-adopt for MCP servers or similar integration components with narrow, well-defined requirements

### 2026-03-06 - vi.doMock + dynamic import fails when module is statically imported in vitest
**Context:** Two supervisor tests timed out because they used `vi.doMock('@anthropic-ai/claude-agent-sdk')` followed by `await import('../src/supervisor.js')` to re-import with a mocked SDK. The module was already statically imported at the top of the test file, so vitest's module cache returned the original (unmocked) version.
**Learning:** When a test file has a static `import` of a module that depends on an external package you want to mock, use `vi.mock()` (hoisted) instead of `vi.doMock()` + dynamic `import()`. Vitest hoists `vi.mock()` calls before all imports, ensuring the mock is in place when the static import resolves. `vi.doMock()` only works if the module hasn't been imported yet and you use a fresh dynamic `import()` without cache hits.
**Applies to:** Any vitest (or jest) project where you need to mock a dependency of a statically imported module; ESM modules with `import { x } from 'pkg'` at the top level

### 2026-03-07 - AI agent system prompts need explicit NEVER-level prohibitions for role boundaries
**Context:** E2E test showed Atlas agent attempting to debug PostgreSQL/Docker infrastructure instead of reporting the issue via Telegram and pausing. The system prompt already said "you are a coordinator, not an executor" but the agent still tried to fix infrastructure.
**Learning:** Positive role descriptions ("you are a coordinator") are insufficient to prevent an AI agent from overstepping its role. You need explicit NEVER-level prohibitions in multiple locations: (1) the Safety Rules section, (2) the NEVER table in the autonomy matrix, and (3) the error handling table with specific error types mapped to "report and pause, do NOT fix". Redundancy across sections is intentional -- the model may attend to different sections at different times.
**Applies to:** Any project using AI agents with system prompts that define role boundaries; autonomous agent architectures where the agent might encounter problems outside its scope

### 2026-03-07 - Atlas is a user-orchestrator bridge, not a sprint manager
**Context:** User clarified that backlog management is the responsibility of each worker session, not Atlas. Atlas's role is purely: receive user instructions via Telegram, relay to orchestrator, monitor sessions, report back to user. Sprint Backlog Manager MCP is not needed by Atlas.
**Learning:** When designing a meta-agent that coordinates other agents, resist the temptation to give it domain responsibilities (like backlog management). The meta-agent should be a thin coordination layer: user communication + session lifecycle + escalation. Domain logic belongs in the worker sessions that have full project context. This keeps the meta-agent's context window lean and its role clear.
**Applies to:** Atlas Agent architecture; any multi-agent system where a supervisor/coordinator agent manages worker agents

