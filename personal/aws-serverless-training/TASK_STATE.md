# Estado - AWS Serverless Training
**Actualizacion:** 2026-03-05 16:30 | **Version:** 0.1.0

## En Progreso

### AWS-001: Account Setup + Billing Alerts

**Completado:**
- Cuenta AWS recuperada (gustavoali@gmail.com, Account ID: 554474286491)
- MFA root configurado (Google Authenticator)
- Tools instalados: AWS CLI 2.34.2, SAM CLI 1.154.0, dotnet lambda tools 6.0.4
- IAM user `gdali-dev` creado (sin permisos ni access keys todavia)

**Pendiente (retomar aca):**
1. Asignar politica AdministratorAccess al user gdali-dev
   - Click en gdali-dev -> Tab Permisos -> Agregar permisos -> Adjuntar politicas directamente -> AdministratorAccess
2. Crear Access Key para CLI
   - Tab Credenciales de seguridad -> Claves de acceso -> Crear clave de acceso -> CLI
   - Copiar Access Key ID y Secret (se muestra una sola vez)
3. Configurar AWS CLI local: `aws configure` con las keys
4. Configurar billing alert a $5 USD
   - Billing -> Budgets -> Create budget -> Monthly $5 -> email gustavoali@gmail.com
5. Verificar con `aws sts get-caller-identity`

## Proximos Pasos (post AWS-001)

1. AWS-002: IAM Fundamentals (teoria + lab)
2. AWS-003: Lambda .NET 8
3. AWS-004: API Gateway
4. AWS-005: DynamoDB
