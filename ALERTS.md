# Alertas del Ecosistema
**Ultima revision:** 2026-03-20

## Alertas Activas
| Fecha | Tipo | Mensaje | Accion |
|-------|------|---------|--------|
| 2026-03-19 | recordatorio | Ecosystem Hub (`pj eh`): impulsar proyecto, tiene seed + backlog (22 stories) + scaffold Angular + backend con parsers. Avanzar con implementacion | Sesion dedicada: revisar backlog, priorizar, arrancar Sprint 1 |
| 2026-03-05 | recordatorio | Iniciar preparacion certificacion AWS (IDEA-034) | Revisar roadmap y planificar primeros pasos |
| 2026-03-05 | recordatorio | Avanzar capacitacion en Anthropic Academy | Continuar cursos pendientes |
| 2026-03-05 | recordatorio | Avanzar capacitacion en DeepLearning.AI | Relevar cursos y comenzar |
| 2026-03-09 | recordatorio | Capacitacion Gen AI Training de Intive (Become AI Ready). URL: https://smtsoftwareservices.sharepoint.com/SitePages/Gen-AI-Training-at-intive--Become-AI-Ready.aspx | Revisar contenido y planificar avance |
| 2026-03-09 | recordatorio | Cloud Backup (`pj cb`): implementar backup.ps1 con rclone + Google Drive | Instalar rclone, configurar GDrive, implementar script, primer backup manual |
| 2026-03-09 | recordatorio | YouTube MCP: exportar cookies del browser para youtube-transcript-api | Evita IP ban sin depender de Whisper. Configurar `YOUTUBE_COOKIE_FILE` en .env |
| 2026-03-09 | recordatorio | Mandarin Chinese: iniciar Fase 1 del roadmap de aprendizaje (pinyin + pictogramas + pronunciacion). Investigacion v1.0 completa (15 docs). Ver `resources/roadmap-aprendizaje.md` | Instalar Pleco + HelloChinese + Anki, arrancar 20 min/dia. Evaluar ampliacion de investigacion al completar Fase 4 (~semana 12) |
| 2026-03-10 | recordatorio | Ordenamiento general de carpetas de proyectos y contexto. Incluye: limpiar legacy en `C:/agents/` (linkedin_rag, youtube_rag*, youtube_jupyter + video suelto 396MB), unificar nomenclatura de carpetas (agents->agentes ya hecho), verificar consistencia entre paths reales y registry, actualizar referencias legacy en docs de project-admin e ideas | Sesion dedicada de limpieza y reorganizacion |
| 2026-03-10 | recordatorio | Agent Token Economics (`pj ate`): impulsar proyecto, avanzar con investigacion/implementacion | Revisar semilla y definir proximos pasos |
| 2026-03-10 | recordatorio | Narrador TTS (`pj nr`): impulsar proyecto, avanzar con investigacion/implementacion | Revisar semilla y definir proximos pasos |
| 2026-03-10 | recordatorio | AI Futures Research (`pj af`): 3 materiales nuevos en `pending/` (Era IA 2022, Karen Hao Imperio IA, NYT Amodei consciencia). Ampliar investigacion. | Procesar pendientes: leer, analizar, integrar con reading_notes |
| 2026-03-11 | recordatorio | Capacitacion Ingles: iniciar proyecto para alcanzar nivel C1. Paso 1: nivelacion (determinar nivel actual). Paso 2: disenar roadmap de avance con hitos intermedios (B1->B2->C1). Considerar sembrar proyecto dedicado en investigacion/ | Sesion dedicada: test de nivelacion + roadmap personalizado |
| 2026-03-11 | recordatorio | Investigar setup de OpenTelemetry para monitoreo automatizado de consumo de tokens en Claude Code. Motivacion: deteccion tardia de consumo excesivo por componentes en prueba (ej: Atlas agent idle loops). Evaluar: (1) OTEL_METRICS_EXPORTER=console como MVP rapido, (2) Prometheus+Grafana como solucion completa, (3) script de alertas por umbral. Considerar integrarlo al proyecto Agent Token Economics (`pj ate`) | Sesion dedicada: configurar OTEL, validar metricas, definir umbrales de alerta |
| 2026-03-20 | recordatorio | Crear MCP server de generacion de PDF. Necesidad detectada en FuturosSociosApi: generar documentos tecnicos con fragmentos de codigo. Librerias disponibles: fpdf2, reportlab. Skills `/pdf` y `/code-screenshot` creados como MVP | Sembrar proyecto, definir scope (md-to-pdf, html-to-pdf, code-screenshot-to-pdf), registrar en project-admin |
| 2026-03-20 | recordatorio | Incorporar herramienta de captura de codigo (code-screenshot) al MCP server de Playwright. Actualmente funciona via skill con flujo manual (HTML + base64 data URL + navigate + screenshot). Ideal: tool nativa `code_screenshot(file, start_line, end_line, language, theme)` que genere PNG directamente | Evaluar si extender playwright MCP existente o crear tool independiente. Considerar integracion con el MCP server de PDF |
| 2026-03-20 | recordatorio | Evaluar mover PostgreSQL (sprint-backlog-pg, project-admin-pg) a otra maquina Windows como DB server dedicado. Opciones: Docker en WSL2 o PG nativo. Ventaja: liberar WSL local | Cuando la otra maquina este disponible, armar setup |
| 2026-03-11 | recordatorio | Analizar infografia Udemy "Top 100 Skills 2026" (`C:/Users/gdali/Downloads/CON25Q4_Infographic _ Trends Top 100 Skills_ESXL.pdf`). Extraer insights relevantes para capacitacion personal y proyectos del ecosistema | Sesion dedicada: leer PDF, cruzar con roadmaps de capacitacion existentes (AWS, AI, etc.) |

## Historial
| 2026-03-19 | recordatorio | Revision trimestral Marzo 2026 pendiente (directiva 6) | Completado: auditoria 15 directivas, 25 learnings nuevos en CROSS_PROJECT v2.0, CONTINUOUS_IMPROVEMENT actualizado, sync repos a /close-session |
| 2026-03-13 | incidente | Project Admin DB ECONNREFUSED (port 5434). llm-landscape y ai-dev-cost-model sin registrar. | Resuelto: container levantado, ambos proyectos registrados en PA DB (#357, #358) con short y context_path. |
| 2026-03-12 | recordatorio | Watch Later MCP: importacion completa (435/440, 12 skipped). | Completado: 82 videos agregados en ultima corrida. 3 fallos por videos eliminados/privados. |
| Fecha | Tipo | Mensaje | Resolucion |
|-------|------|---------|------------|
| 2026-03-10 | recordatorio | Unificar carpetas agents -> agentes | Completado: 3 proyectos movidos (atlas-agent, atlasOps, claude-personal), registry actualizado, CLAUDE.md punteros actualizados. Legacy queda en C:/agents/ para limpieza posterior. |
| 2026-03-10 | recordatorio | Orchestrator: registrar 4 proyectos pendientes en Project Admin | Completado: 4/4 registrados (mandarin-chinese #319, cloud-backup #320, narrador #321, agent-token-economics #322) |
| 2026-03-10 | incidente | WSL2 auto-suspend causa crash loops en todos los Docker containers (INC-007) | Resuelto: .wslconfig con vmIdleTimeout=-1, autoMemoryReclaim=disabled, instanceIdleTimeout=-1. Containers PG recreados con healthcheck. |
| 2026-03-09 | recordatorio | Investigar agente TTS + generacion de imagenes | Proyecto creado: `pj nr` (narrador), repo: github.com/gustavoali/narrador |
| 2026-03-09 | recordatorio | Crear proyecto investigacion Chino Mandarin | Proyecto creado: `pj mc`, repo: github.com/gustavoali/mandarin-chinese |
| 2026-03-09 | recordatorio | Crear proyecto AI Futures Research (Amodei + otros) | Proyecto creado: `pj af`, repo: github.com/gustavoali/ai-futures-research |
| 2026-03-09 | recordatorio | Crear herramienta/skill de cierre de sesion automatizado | Implementado como skill `/close-session` en `~/.claude/commands/close-session.md` |
| 2026-03-09 | recordatorio | YouTube MCP: reiniciar sesion Claude Code para cargar Whisper fallback | Resuelto: sesion reiniciada 2026-03-09 |
| 2026-03-06 | recordatorio | Verificar si todavia se puede cargar el proyecto de Anyone AI | Sprint 1 project recreado desde cero, 11/11 tests passing |
| 2026-03-04 | incidente | Hook auto-learnings colgado 13h (timeout en seg no ms) | Corregido: timeouts + scripts reescritos |
