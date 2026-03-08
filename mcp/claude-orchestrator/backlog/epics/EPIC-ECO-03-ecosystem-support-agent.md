# EPIC-ECO-03: Ecosystem Support Agent

**Version:** 1.0 | **Fecha:** 2026-03-08
**Status:** Ready
**Total Points:** 34
**Stories:** ECO-009 a ECO-015 (7 stories)

---

## Vision

Evolucionar el orchestrator de gestor de sesiones a plataforma con capacidad de monitoreo y soporte autonomo del ecosistema. Un agente interno que verifica la salud de todos los servicios (Docker containers, Node.js servers, PostgreSQL databases, puertos), detecta problemas proactivamente, ejecuta remediaciones conocidas, y notifica incidentes via webhook/Telegram.

## Objetivo de Negocio

Reducir el tiempo de deteccion de problemas en el ecosistema de "cuando el usuario lo nota" (~minutos a horas) a deteccion automatica en segundos. Reducir downtime mediante auto-remediacion de problemas conocidos (container caido, servicio no responde).

## Metricas de Exito

| Metrica | Baseline | Target |
|---------|----------|--------|
| Tiempo medio de deteccion de fallo | Manual (~30min) | Automatico (<60s) |
| Tiempo medio de remediacion (problemas conocidos) | Manual (~5min) | Automatico (<30s) |
| Falsos positivos en deteccion | N/A | <5% |
| Cobertura de servicios monitoreados | 0% | 100% del ecosistema |

## Historias

| ID | Titulo | Pts | Priority | Dependencias |
|----|--------|-----|----------|--------------|
| ECO-015 | Support Agent Configuration & Lifecycle | 3 | Critical | Ninguna |
| ECO-009 | Ecosystem Health Check Engine | 5 | Critical | Ninguna |
| ECO-010 | Docker Container Monitoring | 5 | High | ECO-009 |
| ECO-012 | Ecosystem Status Dashboard Endpoint | 3 | High | ECO-009 |
| ECO-011 | Auto-Remediation Actions | 8 | High | ECO-009, ECO-010 |
| ECO-013 | Scheduled Maintenance Tasks | 5 | Medium | ECO-009, ECO-015 |
| ECO-014 | Incident Detection & Notification Payloads | 5 | Medium | ECO-009, ECO-006 |

## Orden de Implementacion

```
Ola 1 (paralelo):  ECO-015 (config, 3pts) + ECO-009 (engine, 5pts)
Ola 2 (paralelo):  ECO-010 (docker, 5pts) + ECO-012 (endpoint, 3pts)
Ola 3 (secuencial): ECO-011 (remediation, 8pts)
Ola 4 (paralelo):  ECO-013 (maintenance, 5pts) + ECO-014 (notifications, 5pts)
```

Estimacion total: ~4-5 dias de implementacion (1 developer).

## Arquitectura

El Support Agent es un modulo interno del orchestrator, no un servicio separado.

```
src/
  support-agent/
    index.js              # SupportAgent class (lifecycle, orchestration)
    config.js             # Configuration schema & defaults
    health-checker.js     # Health check engine (HTTP, TCP, Docker)
    docker-monitor.js     # Docker container monitoring via docker CLI
    remediator.js         # Auto-remediation actions registry
    maintenance.js        # Scheduled maintenance tasks
    incident-reporter.js  # Incident detection & notification payloads
```

Integracion con orchestrator:
- Se instancia en `server.js` al arrancar (si habilitado)
- Usa `webhook-emitter.js` existente (ECO-006) para notificaciones
- Expone estado via nuevos endpoints HTTP en `http/routes/`
- Configurable via env vars con prefix `SUPPORT_AGENT_*`

## Restricciones

- No crear servicio separado: todo dentro del orchestrator
- No duplicar: reusar health monitoring (ECO-002), webhooks (ECO-006), activity log (ECO-003)
- Configurable: todo deshabilitado por defecto excepto health checks
- Auto-remediacion conservadora: solo acciones conocidas y seguras (restart, no delete)
- Docker acceso via CLI (`docker` command), no via Docker API socket

## RICE Score

| Factor | Valor | Justificacion |
|--------|-------|---------------|
| Reach | 4 | Afecta a todo el ecosistema de desarrollo |
| Impact | 2 (High) | Reduce downtime, mejora productividad |
| Confidence | 80% | Tecnologias conocidas, scope bien definido |
| Effort | 2 person-months | ~34 story points, 1 developer |
| **RICE** | **3.2** | |

---

**Historial:**
| Fecha | Evento |
|-------|--------|
| 2026-03-08 | Epic creado. 7 stories, 34 points. |
