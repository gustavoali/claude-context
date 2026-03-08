# IDEA-020: Evolucion del sistema de agentes especializados y delegacion

**Fecha:** 2026-02-15
**Categoria:** improvements
**Estado:** In Progress
**Prioridad:** Media

---

## Descripcion

Evolucionar el sistema de perfiles de agentes con herencia y mejorar el mecanismo de delegacion de tareas a agentes especializados. Actualmente cubre architects, developers, reviewer y tester. Oportunidad de extender especializaciones por stack y automatizar la composicion de prompts.

## Motivacion

La delegacion a agentes es el core de la metodologia de trabajo. Un sistema mas robusto de perfiles reduce errores de contexto, mejora la calidad de los outputs y acelera la delegacion. La v1.0 demostro el patron con architects; la v2.0 lo extiende a developers, reviewer y tester.

## Alcance Estimado

Mediano

## Progreso

### v1.0 (2026-02-14) - Architects
- AGENT_ARCHITECT_BASE.md
- AGENT_ARCHITECT_FRONTEND.md
- AGENT_ARCHITECT_BACKEND.md
- AGENT_MCP_SERVER.md (standalone)

### v2.0 (2026-02-15) - Developers + Reviewer + Tester
- AGENT_DEVELOPER_BASE.md (compartida por todos los developers)
- AGENT_DEVELOPER_DOTNET.md
- AGENT_DEVELOPER_NODEJS.md
- AGENT_DEVELOPER_ANGULAR.md
- AGENT_REVIEWER_BASE.md (standalone/composable)
- AGENT_TESTER_BASE.md (standalone/composable)
- README.md actualizado a v2.0

**Total: 10 archivos de agente, 8 roles cubiertos.**

## Lineas de Trabajo Pendientes

1. **Especializaciones por stack para Reviewer y Tester:**
   - AGENT_REVIEWER_DOTNET.md, AGENT_REVIEWER_NODEJS.md
   - AGENT_TESTER_DOTNET.md, AGENT_TESTER_NODEJS.md
   - Crear bajo demanda cuando se detecte necesidad
2. **Especializaciones de Developer faltantes:**
   - AGENT_DEVELOPER_REACT.md, AGENT_DEVELOPER_FLUTTER.md, AGENT_DEVELOPER_PYTHON.md
   - Crear bajo demanda
3. **Automatizar composicion de prompts:**
   - Evaluar skill `/delegate` que lea perfiles, componga prompt y delegue
   - Reducir carga manual del coordinador (Claude)
4. **Perfiles por proyecto:**
   - Un developer con contexto especifico de un proyecto
   - Ej: AGENT_DEVELOPER_ANGULAR_WEBMONITOR.md
5. **Evaluar Agent Teams de Claude Code:**
   - Feature experimental (feb 2026), multiples instancias coordinadas
   - Limitacion: split panes no soportado en Windows Terminal
   - Custom subagents con memoria persistente entre sesiones
   - Monitorear madurez antes de adoptar
6. **Metricas de calidad de delegacion:**
   - El agente entendio bien la tarea?
   - El output fue usable sin correcciones?
7. **Biblioteca de prompts exitosos:**
   - Referencia de prompts compuestos que funcionaron bien

## Proyectos Relacionados

- Sistema de agentes: `claude_context/metodologia_general/agents/`
- Metodologia general v3.0
- Todos los proyectos activos (consumidores del sistema)

## Referencias Externas

### TinyClaw (C:/agents/tinyclaw)
- **Repo:** https://github.com/jlia0/tinyclaw.git
- **Que es:** Orquestador multi-agente multi-canal (Discord/Telegram/WhatsApp), 24/7 via tmux
- **Patron interesante:** Agentes se mencionan entre si con tags (`[@agent: message]`) para coordinacion automatica en equipos
- **Cola file-based:** incoming → processing → outgoing (JSON files, sin race conditions)
- **Heartbeat:** agentes actuan proactivamente en intervalos configurables
- **Limitaciones:** solo Linux/macOS, sin tests, usa `--dangerously-skip-permissions`
- **Relevancia:** referencia para patrones de comunicacion inter-agente y equipos auto-coordinados

---

## Historial

| Fecha | Evento |
|-------|--------|
| 2026-02-14 | v1.0: sistema de herencia para architects (3 archivos + MCP standalone) |
| 2026-02-15 | Idea capturada formalmente |
| 2026-02-15 | Investigacion Agent Teams de Claude Code (feature experimental) |
| 2026-02-15 | v2.0: developers (base + 3 stacks), reviewer base, tester base (6 archivos nuevos) |
