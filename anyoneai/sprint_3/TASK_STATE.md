# Estado - AnyoneAI Sprint 3
**Actualizacion:** 2026-03-02 01:40 | **Proyecto:** `C:/Anyone_AI/sprint_3/`

## Resumen Ejecutivo
TODAS LAS FASES COMPLETADAS (0-6). Proyecto ENTREGADO como `sprint_3_submission_noroot.zip`.

## Resultados de Tests

| Suite | Tests | Resultado |
|-------|-------|-----------|
| API unit tests | 9/9 | PASS |
| ML model test | 1/1 | PASS |
| UI tests | 6/6 | PASS |
| Integracion (curl) | 2/2 | PASS |
| **Total** | **18/18** | **PASS** |

## Stress Test (Locust)

### 1 worker (baseline)
| Metrica | GET / | POST /model/predict |
|---------|-------|---------------------|
| Requests | 6 | 7 |
| Failures | 6 (404 esperado) | 0 |
| Avg response | 14s | 21.6s |
| req/s | 0.12 | 0.14 |

### 2 workers (--scale model=2)
| Metrica | GET / | POST /model/predict |
|---------|-------|---------------------|
| Requests | 10 | 18 |
| Failures | 10 (404 esperado) | 0 |
| Avg response | 14.7s | 21.4s |
| req/s | 0.09 | 0.16 |

**Conclusion:** Con 2 workers el throughput de predict sube ~14% (0.14->0.16 req/s). La latencia individual no baja (bottleneck: ResNet50 en CPU ~21s/imagen). El beneficio real es que 2 requests se procesan en paralelo desde la cola Redis.

## Fases Completadas

| Fase | Descripcion | Estado |
|------|-------------|--------|
| 0 | Setup (.env, network, Docker) | DONE |
| 1 | Dockerfile.populate | DONE |
| 2 | ML Service (ml_service.py) | DONE |
| 3 | API (utils, services, routers) | DONE |
| 4 | UI (Streamlit app) | DONE |
| 5 | Integracion y validacion | DONE |
| 6 | Stress testing (Locust) | DONE |

## Archivos Implementados
- `model/ml_service.py` - Redis + ResNet50 + predict + classify_process
- `api/Dockerfile.populate` - Dockerfile para populate_db.py
- `api/app/utils.py` - allowed_file, get_file_hash
- `api/app/model/services.py` - Redis queue + model_predict
- `api/app/model/router.py` - /model/predict endpoint
- `api/app/user/router.py` - POST /user/ registration
- `ui/app/image_classifier_app.py` - login, predict, send_feedback
- `stress_test/locustfile.py` - index + predict tasks

## Cambios al docker-compose.yml
- `postgres:latest` -> `postgres:16`
- Agregado `restart: unless-stopped` a todos los servicios
