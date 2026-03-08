# Sprint 2 - Machine Learning
**Tema:** ML Supervisado, No Supervisado, Redes Neuronales, Model Evaluation, Ensemble, Hyperparameter Optimization
**Contenido:** `C:/Anyone_AI/sprint_2/contenidos/`
**Proyecto de trabajo:** `C:/Anyone_AI/sprint_2/`

## Modulos

| # | Modulo | Contenido |
|---|--------|-----------|
| 1 | Introduction | Motivacion proyecto fintech |
| 2.1 | Machine Learning | Linear/Logistic Regression, Gradient Descent, Feature Engineering |
| 2.2 | Redes Neuronales | MLP con Keras, Customer Churn, CIFAR-10, Backpropagation |
| 2.3 | Supervised Learning | Decision Trees, SVM, Pipelines |
| 2.3.3 | Model Evaluation | Accuracy, Precision, Recall, F1, ROC-AUC, Confusion Matrix |
| 2.3.4 | Model Ensemble | Random Forest, Bagging, Boosting |
| 2.3.5 | Hyperparameter Opt | GridSearchCV, RandomizedSearchCV |
| 3 | Unsupervised Learning | K-Means, DBSCAN, PCA, t-SNE, Curse of Dimensionality |
| 5 | GitHub | Code versioning |

## Sprint Project: Home Credit Default Risk
- Clasificacion binaria: predecir default de creditos
- Dataset Kaggle: 246,008 train / 61,503 test / 122 features
- Target: binary (0=paga, 1=no paga)
- Metrica: ROC AUC Score

### Resultados obtenidos
| Modelo | Val AUC |
|--------|---------|
| Logistic Regression | 0.6772 |
| Random Forest (default) | 0.7078 |
| Random Forest (tuned) | 0.7340 |
| LightGBM (opcional) | 0.7551 |

## Estructura del proyecto
```
C:/Anyone_AI/sprint_2/
  AnyoneAI - Sprint Project 02.ipynb  # Notebook principal (93 celdas)
  src/
    config.py           # Paths y URLs de datasets
    data_utils.py       # get_datasets(), get_feature_target(), get_train_val_sets()
    preprocessing.py    # preprocess_data() pipeline completo
  tests/
    conftest.py         # Fixtures (session-scoped)
    test_data_utils.py  # Tests de funciones de datos
    test_preprocessing.py # Test de preprocessing
  dataset/
    application_test_aai.csv   # 32 MB (descargado)
    application_train_aai.csv  # Se descarga on-demand via gdown
  requirements.txt
```

## Stack
- scikit-learn 1.2.1 (LogisticRegression, RandomForest, RandomizedSearchCV, Pipeline)
- pandas 1.5.3, numpy 1.24.2
- matplotlib 3.6.3, seaborn 0.12.2
- gdown 4.6.0 (descarga datasets)
- LightGBM (opcional)
- Keras/TensorFlow (teoria, no en proyecto)
- pytest 7.2.1, black 23.1.0, isort 5.12.0, flake8 6.0.0

## Estado
COMPLETADO Y ENTREGADO - `C:/Anyone_AI/Sprint_02_Gustavo_Ali.zip`
Documentacion detallada: `C:/Anyone_AI/CONTENIDOS_SPRINT2.md`
