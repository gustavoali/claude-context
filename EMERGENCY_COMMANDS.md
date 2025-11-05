# Comandos de Emergencia - YouTube RAG System
## Para usar en caso de interrupción de sesión

---

## 🚨 COMANDOS CRÍTICOS DE RESTART

### 1. Verificar estado actual
```bash
curl -s http://localhost:8000/health
```

### 2. Si API no responde - REINICIAR SERVER
```bash
cd C:\agents\youtube_rag_mvp\backend
ENVIRONMENT=development ENABLE_AUTH=false PROCESSING_MODE=mock STORAGE_MODE=database MYSQL_DATABASE=youtube_rag_db python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 3. Verificar base de datos MySQL
```bash
docker exec mysql-youtube-rag mysql -u root -prootpassword -e "USE youtube_rag_db; SELECT COUNT(*) FROM users; SELECT COUNT(*) FROM videos;"
```

### 4. Verificar Docker MySQL está corriendo
```bash
docker ps | findstr mysql-youtube-rag
```

### 5. Si MySQL no está corriendo - INICIAR
```bash
docker start mysql-youtube-rag
```

---

## 📊 ESTADO ACTUAL CONOCIDO

- **API:** ✅ Funcionando en puerto 8000
- **DB:** ✅ youtube_rag_db LIMPIA (0 usuarios, 0 videos)
- **Docker:** ✅ mysql-youtube-rag container activo
- **Background Process:** b53248 (servidor principal)

---

## 🔧 CONFIGURACIÓN CRÍTICA

### Variables de entorno necesarias:
```
ENVIRONMENT=development
ENABLE_AUTH=false
PROCESSING_MODE=mock
STORAGE_MODE=database
MYSQL_DATABASE=youtube_rag_db
```

### Database connection:
```
Host: localhost:3306
User: youtube_rag_user
Pass: youtube_rag_password
DB: youtube_rag_db
```

---

## 📁 ARCHIVOS IMPORTANTES DE CONTEXTO

1. `C:\CLAUDE_CONTEXT\SESSION_STATE_2025-09-20.md` - Estado completo
2. `C:\CLAUDE_CONTEXT\REFACTORING_SUMMARY.md` - Refactorización previa
3. `C:\agents\youtube_rag_mvp\backend\.env.development` - Config desarrollo
4. `C:\agents\youtube_rag_mvp\backend\app\main.py` - Main unificado