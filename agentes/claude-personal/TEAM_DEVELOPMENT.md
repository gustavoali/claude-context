# Claude Personal - Equipo de Desarrollo

## Composicion

| Rol | Agente | Responsabilidad |
|-----|--------|-----------------|
| Backend Developer (.NET) | `dotnet-backend-developer` | Core engine, API client, tool implementations, CLI |
| Test Engineer | `test-engineer` | Unit tests, integration tests, mocking de API |
| Code Reviewer | `code-reviewer` | Review riguroso pre-merge |
| DevOps | `devops-engineer` | CI/CD, packaging, distribucion |

## Notas
- El backend developer implementa tanto el core como los tools (todo es .NET)
- Tests deben mockear la API de Anthropic (no llamadas reales en CI)
- El reviewer debe prestar especial atencion a seguridad (filesystem access, secrets)
- DevOps configura build + test + packaging como dotnet tool global o ejecutable standalone
