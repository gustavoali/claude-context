# Estado - AWS Serverless Training
**Actualizacion:** 2026-03-24 | **Version:** 1.1.0

## En Progreso

### AWS-001: Account Setup + Billing Alerts
**Completado:**
- Cuenta AWS recuperada (gustavoali@gmail.com, Account ID: 554474286491)
- MFA root configurado (Google Authenticator)
- Tools instalados: AWS CLI 2.34.2, SAM CLI 1.154.0, dotnet lambda tools 6.0.4
- IAM user `gdali-dev` creado (sin permisos ni access keys todavia)

**Pendiente (retomar aca):**
1. Asignar politica AdministratorAccess al user gdali-dev
2. Crear Access Key para CLI
3. Configurar AWS CLI local: `aws configure` con las keys
4. Configurar billing alert a $5 USD
5. Verificar con `aws sts get-caller-identity`

## Roadmap de Certificacion (actualizado 2026-03-24)

### Target: DVA-C02 (AWS Developer Associate)
- 65 preguntas, 130 min, puntaje 720/1000 para aprobar
- Dominios: Development (32%), Security (26%), Deployment (24%), Troubleshooting (18%)
- Costo examen: USD 150

### Fase 1: Fundamentos + Lab (Semanas 1-2, 22 pts)
AWS-001 a AWS-007: Account, IAM, Lambda .NET 8, API Gateway, DynamoDB, SAM CLI, Lab CRUD

### Fase 2: Profundizacion (Semanas 3-4, 18 pts)
AWS-008 a AWS-013: Messaging, observabilidad, Datadog, GitLab CI/CD, seguridad, Lab pipeline

### Fase 3: Prep DVA-C02 (Semanas 5-7, 5 pts)
- Semana 5: Curso Stephane Maarek DVA-C02 (Udemy ~USD 15)
- Semana 6: Practice exams Tutorials Dojo (~USD 15-20)
- Semana 7: Simulacros finales + examen

### Fase 4: SAA-C03 opcional (Semanas 8-10)
- 30-40% overlap con DVA-C02, ~3-4 semanas adicionales
- Costo: USD 75 con voucher 50% post-DVA-C02

### Presupuesto Total
| Item | USD |
|------|-----|
| Maarek Udemy | ~15 |
| Tutorials Dojo | ~15 |
| Examen DVA-C02 | 150 |
| Examen SAA-C03 (voucher 50%) | 75 |
| **Total ambas certs** | **~255** |

### Tip: Voucher encadenado
Al aprobar DVA-C02, AWS envia voucher 50% para otro examen + practice exam gratis.

## Proximos Pasos (post AWS-001)
1. AWS-002: IAM Fundamentals (teoria + lab)
2. AWS-003: Lambda .NET 8
3. AWS-004: API Gateway
4. AWS-005: DynamoDB
