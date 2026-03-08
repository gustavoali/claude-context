# Gaia Protocol - Equipo de Desarrollo

## Composicion

| Rol | Agente | Responsabilidad |
|-----|--------|-----------------|
| Backend Developer (.NET) | `dotnet-backend-developer` | Engines de simulacion (C#), API backend, modelo de dominio |
| Test Engineer | `test-engineer` | Unit tests de engines, tests de escenarios, snapshot testing |
| Code Reviewer | `code-reviewer` | Review riguroso pre-merge, seguridad, patrones |
| DevOps | `devops-engineer` | CI/CD, build pipeline, Docker para DB |

## Notas
- Los engines son C# puro (sin dependencia de Unity) para testabilidad
- El frontend Unity se desarrolla manualmente o con asistencia directa (no hay agente Unity)
- El test engineer debe crear el balance harness (IA vs IA) para calibracion
- DevOps configura pipeline de build .NET + tests automatizados
- Code reviewer aplica modo riguroso (directiva 8 de metodologia)

## Stack de Testing
- xUnit o NUnit para engines C#
- Tests de escenarios con seeds controladas (20-50 turnos)
- Snapshot testing con golden files
- Balance harness: simulaciones automaticas para ajuste de parametros
