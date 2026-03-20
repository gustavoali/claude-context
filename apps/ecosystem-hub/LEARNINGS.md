# Learnings - Ecosystem Hub



### 2026-03-19 - Fastify enum validation requires updating ALL schema occurrences
**Context:** Adding new alert types ('pendiente', 'code-review') to the alerts API
**Learning:** In Fastify routes with JSON Schema validation, enum arrays for the same field are duplicated across GET querystring, POST body, and PUT body schemas. When extending an enum, you must update ALL occurrences in the route file ÔÇö Fastify validates against the schema before the handler runs, so a missing update causes silent 400 rejections. Use `grep` to find all occurrences before committing.
**Applies to:** Fastify routes with JSON Schema validation, any API where enums are defined inline in multiple schemas

### 2026-03-19 - Import scripts need --force for enum schema changes
**Context:** After extending alert types in repository + routes, existing imported data was correct but new imports with the added types failed validation
**Learning:** When you extend validation enums (DB CHECK constraints, API schema enums, repository validation arrays), existing imported data won't include the new values. A `--force` re-import (truncate + re-insert) is needed to pick up records that were previously rejected. The import script should log skipped records with reasons so enum mismatches are visible.
**Applies to:** Data import scripts with validation, schema migrations that widen allowed values

