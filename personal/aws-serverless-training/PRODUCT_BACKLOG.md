# Backlog - AWS Serverless Training
**Version:** 1.0 | **Actualizacion:** 2026-03-05

## Resumen

| Metrica | Valor |
|---------|-------|
| Total historias | 15 |
| Pendientes | 15 |
| En progreso | 0 |
| Completadas | 0 |
| Puntos totales | 48 |

## Vision

Dominar AWS Serverless con .NET 8 para operar como Developer Senior en proyecto con Lambda, API Gateway, DynamoDB, SAM, Datadog y GitLab CI/CD. Obtener certificacion DVA-C02.

## Fases

| Fase | Historias | Puntos | Semanas | Status |
|------|-----------|--------|---------|--------|
| 1 - Fundamentos + Lab | AWS-001 a AWS-007 | 22 | 1-2 | Pendiente |
| 2 - Profundizacion + Observabilidad | AWS-008 a AWS-013 | 18 | 3-4 | Pendiente |
| 3 - Cert DVA-C02 | AWS-014 | 5 | 5-7 | Pendiente |
| 4 - Cert SAA-C03 (opcional) | AWS-015 | 3 | 8-10 | Pendiente |

## Pendientes

### Fase 1 - Fundamentos + Lab Rapido

| ID | Titulo | Pts | Prioridad | Deps |
|----|--------|-----|-----------|------|
| AWS-001 | Account Setup + Billing Alerts | 1 | Critical | - |
| AWS-002 | IAM Fundamentals | 2 | Critical | AWS-001 |
| AWS-003 | Lambda .NET 8 | 5 | Critical | AWS-002 |
| AWS-004 | API Gateway | 3 | Critical | AWS-002 |
| AWS-005 | DynamoDB Fundamentals | 5 | Critical | AWS-002 |
| AWS-006 | SAM CLI | 3 | Critical | AWS-003 |
| AWS-007 | Lab: CRUD API Serverless | 3 | Critical | AWS-003,004,005,006 |

### Fase 2 - Profundizacion + Observabilidad

| ID | Titulo | Pts | Prioridad | Deps |
|----|--------|-----|-----------|------|
| AWS-008 | Messaging Patterns (SQS/SNS/EventBridge) | 3 | High | AWS-007 |
| AWS-009 | Observability (CloudWatch/X-Ray) | 3 | High | AWS-007 |
| AWS-010 | Datadog Integration | 3 | High | AWS-009 |
| AWS-011 | GitLab CI/CD + SAM Pipeline | 3 | High | AWS-006 |
| AWS-012 | Security (Cognito/KMS/Secrets Manager) | 3 | High | AWS-007 |
| AWS-013 | Lab: Pipeline Completo | 3 | High | AWS-008,009,010,011,012 |

### Fase 3-4 - Certificaciones

| ID | Titulo | Pts | Prioridad | Deps |
|----|--------|-----|-----------|------|
| AWS-014 | Cert Prep DVA-C02 | 5 | High | AWS-013 |
| AWS-015 | Cert Prep SAA-C03 (opcional) | 3 | Medium | AWS-014 |

## Completadas

| ID | Titulo | Puntos | Fecha |
|----|--------|--------|-------|
| (ninguna) | | | |

## ID Registry

| Rango | Estado |
|-------|--------|
| AWS-001 a AWS-015 | Asignados |
| AWS-016+ | Disponible |
Proximo ID: AWS-016
