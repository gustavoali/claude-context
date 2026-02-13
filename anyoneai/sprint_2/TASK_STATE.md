# Estado de Tareas - AnyoneAI Sprint 2 (Home Credit Default Risk)

**Ultima actualizacion:** 2026-02-02
**Sesion activa:** Si

---

## Resumen Ejecutivo

**Trabajo en curso:** Proyecto de clasificacion binaria para predecir default de creditos
**Fase actual:** Inicio - Implementacion de funciones base y EDA
**Bloqueantes:** Ninguno

---

## Tareas Activas

### 1. [PENDIENTE] Exploratory Data Analysis (EDA)
- **Descripcion:** Completar ejercicios 1.4 a 1.13 en el notebook
- **Archivos afectados:** AnyoneAI - Sprint Project 02.ipynb

### 2. [PENDIENTE] Implementar get_feature_target()
- **Descripcion:** Separar features (X) y target (y) de los datasets
- **Archivos afectados:** src/data_utils.py

### 3. [PENDIENTE] Implementar get_train_val_sets()
- **Descripcion:** Split train/validation con train_test_split (80/20)
- **Archivos afectados:** src/data_utils.py

### 4. [PENDIENTE] Implementar preprocess_data()
- **Descripcion:** Pipeline de preprocessing completo:
  - Corregir outliers en DAYS_EMPLOYED
  - Encoding categorico (OrdinalEncoder para 2 categorias, OneHotEncoder para >2)
  - Imputacion de missing values (mediana)
  - Feature scaling (MinMaxScaler)
- **Archivos afectados:** src/preprocessing.py

### 5. [PENDIENTE] Entrenar modelos
- **Descripcion:** LogisticRegression (baseline), RandomForest, RandomizedSearchCV
- **Archivos afectados:** notebook

### 6. [PENDIENTE] Predicciones finales
- **Descripcion:** Usar mejor modelo para predecir test_data y guardar en CSV
- **Archivos afectados:** dataset/application_test_aai.csv

---

## Contexto Tecnico

- **Framework:** scikit-learn
- **Metrica:** ROC AUC Score
- **Dataset train:** 246,008 samples, 122 features
- **Dataset test:** 61,503 samples, 122 features
- **Target:** Binary (0=paga, 1=no paga)

---

## Proximos Pasos

1. Implementar get_feature_target() y get_train_val_sets() en data_utils.py
2. Implementar preprocess_data() en preprocessing.py
3. Completar EDA en notebook
4. Entrenar modelos
5. Generar predicciones

---

## Historial de Sesiones

### 2026-02-02 (actual)
- Inicio del proyecto
- Analisis de estructura y TODOs pendientes
- Creacion de TASK_STATE.md

