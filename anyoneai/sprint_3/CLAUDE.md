# Sprint 3 - MLOps & Deployment
**Tema:** Model Deployment, Docker, Microservices, FastAPI, Streamlit, Redis, AWS, CI/CD, Monitoring
**Contenido:** `C:/Anyone_AI/sprint_3/contenidos/`
**Assignment ZIP:** `C:/Anyone_AI/contenidos/bruto/sprint3/4-sprint-project/1-sprint-project-3-download/assignment_v2.zip`
**Proyecto de trabajo:** `C:/Anyone_AI/sprint_3/`

## Modulos

| # | Modulo | Contenido |
|---|--------|-----------|
| 14.1 | Intro MLOps | Ciclo de vida ML en produccion, Design/Dev/Ops |
| 14.2 | Serving ML with APIs | FastAPI, endpoints, Pydantic, /docs |
| 14.3 | Docker | Dockerfile, build, run, volumes, port mapping |
| 14.4 | Microservices | Monolithic vs Microservices, Redis, docker-compose |
| 14.5 | Streamlit | UI para ML, widgets, file uploader, session state |
| 14.6 | AWS | EC2, Lambda, S3, deploy en cloud |
| 14.9 | Monitoring & CI/CD | Sentry, GitHub Actions, drift monitoring |
| Extra | MLOps E2E | FastAPI + MLflow + Docker (bike-sharing) |

## Sprint Project: Image Classifier Microservices

### Arquitectura
```
User -> Streamlit UI (:9090) -> FastAPI API (:8000) -> Redis Queue -> ML Service (ResNet50) -> Redis -> API -> UI
                                    |
                                PostgreSQL (:5432)
```

### Servicios (Docker Compose)
| Servicio | Tecnologia | Puerto |
|----------|-----------|--------|
| API | FastAPI | 8000 |
| ML Service | TensorFlow ResNet50 | - |
| UI | Streamlit | 9090 |
| Redis | Redis 6.2.6 | - |
| PostgreSQL | postgres:latest | 5432 |

### Endpoints
| Method | Path | Descripcion |
|--------|------|-------------|
| POST | /login | Auth JWT |
| POST | /model/predict | Upload imagen, retorna prediccion |
| POST | /user/ | Registro usuario |
| GET | /user/ | Lista usuarios |
| POST | /feedback/ | Enviar feedback |
| GET | /feedback/ | Ver feedback |

### TODOs del assignment (orden recomendado)
1. `api/Dockerfile.populate` - Dockerfile para script de populado
2. `model/ml_service.py` - predict() y classify_process() con Redis
3. `api/app/utils.py` - allowed_file() y get_file_hash()
4. `api/app/model/services.py` - model_predict() via Redis
5. `api/app/model/router.py` - endpoint predict()
6. `api/app/user/router.py` - create_user_registration()
7. `ui/app/image_classifier_app.py` - login(), predict(), send_feedback()
8. Tests: model, API, UI, integration
9. `stress_test/locustfile.py` - Locust load testing
10. (Opcional) Batch processing en ML service

### Credenciales de prueba
- Admin: `admin@example.com` / `admin`

## Stack
- FastAPI 0.88.0, Uvicorn 0.20.0, Pydantic 1.10.2
- SQLAlchemy 1.3.24, PostgreSQL
- Redis 6.2.6 (message broker)
- TensorFlow 2.8.0, Pillow (ResNet50 pre-entrenado)
- Streamlit (UI)
- Locust (stress testing)
- Docker + docker-compose 3.2
- GitHub Actions (CI/CD)
- Argon2 (password hashing), python-jose 3.3.0 (JWT)
- pytest, black, isort

## PDFs de teoria
- `14.1 - Introduction to MLOps.pdf`
- `14.2 - Serving ML models with APIs.pdf`
- `14.3 - Containerization with Docker.pdf`
- `14.4 - Deploying microservice architectures locally.pdf`
- `14.5 - User Interfaces for ML with Streamlit.pdf`
- `14.6 - Deployment in AWS.pdf`
- `14.9 - Model Monitoring.pdf`

## Estado
ENTREGADO - Proyecto completado y entregado como `sprint_3_submission_noroot.zip`. 18/18 tests PASS.
