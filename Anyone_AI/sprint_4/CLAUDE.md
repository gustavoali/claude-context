# Anyone AI Sprint 4 - Best Buy Product Classification
**Version:** 0.1.0 | **Tests:** 21 (not yet run on Windows) | **Coverage:** TBD
**Ubicacion:** C:/Anyone_AI/sprint_4/Assignment

## Stack
- Python 3.9 (TF 2.10 incompatible con 3.11+)
- TensorFlow 2.10.0, PyTorch 2.0.0, Transformers 4.44.2
- scikit-learn 0.24.2, Keras (via TF)
- Jupyter Notebook

## Componentes
| Componente | Ubicacion | Estado |
|------------|-----------|--------|
| Image Embeddings (ResNet50/ConvNextV2) | src/vision_embeddings_tf.py | Completo |
| Text Embeddings (MiniLM/BERT) | src/nlp_models.py | Completo |
| Classic ML (RF, LR, PCA, t-SNE) | src/classifiers_classic_ml.py | Completo |
| MLP Early Fusion (Keras) | src/classifiers_mlp.py | Completo |
| Utils (download, preprocess, split) | src/utils.py | Completo |
| Main Notebook | AnyoneAI - Sprint Project 04.ipynb | Ejecutado previamente (Mac M1) |
| Preprocessing Notebook | preprocessing(optional).ipynb | Ejecutado |

## Datos
- `data/processed_products_with_images.csv` - 52K rows
- `data/images/` - ~50K product images
- `data/images.zip` - 395MB compressed
- `data/Raw/` - Raw data

## Targets de Performance
| Modalidad | Accuracy | F1-Score |
|-----------|----------|----------|
| Multimodal | >= 85% | >= 80% |
| Text-only | >= 85% | >= 80% |
| Image-only | >= 75% | >= 70% |

## Resultados Previos (Mac M1, 2024-09-25)
- Image: 82% acc | Text: 93% acc | Multimodal: 92% acc
- Todos superan targets

## Pendiente
- Regenerar Embeddings/ y results/ en Windows (no existen)
- Ejecutar pipeline en Google Colab (GPU para ~50K imagenes)
- Correr pytest tests/ (21 tests)

## Comandos
```bash
# Activar venv
.venv/Scripts/activate
# Build/Test
pip install -r requirements.txt
pytest tests/ -v
# Jupyter
jupyter notebook
```

## MCP Google Drive
- OAuth configurado y autenticado (gustavoali@gmail.com)
- Server: @piotr-agier/google-drive-mcp en settings.json
- Necesita reinicio de Claude Code para activar herramientas

## Docs
@C:/claude_context/Anyone_AI/sprint_4/TASK_STATE.md
