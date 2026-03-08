# Sprint 4 - Deep Learning & NLP
**Tema:** Deep Learning, Computer Vision, NLP, Transformers, LLMs, RAG, Multimodal Classification
**Contenido:** `C:/Anyone_AI/sprint_4/contenidos/`
**Proyecto de trabajo:** `C:/Anyone_AI/sprint_4/Assignment/`

## Modulos

| # | Modulo | Contenido |
|---|--------|-----------|
| 1 | Intro Sprint 4 | Welcome, Motivation |
| 2 | DL Computer Vision | CNNs, Theory notebooks, Practice notebooks |
| 3.1 | NLP - Intro | Normalization, Vectorization |
| 3.2 | NLP - Word Embeddings | Word2Vec, GloVe, FastText |
| 3.3 | NLP - RNN & Attention | LSTM, GRU, Attention mechanism |
| 3.4 | NLP - Transformers | Self-attention, encoder-decoder |
| 3.5 | NLP - LLMs I | GPT, BERT, fine-tuning |
| 3.6 | NLP - LLMs II | Advanced LLM topics |
| 3.7 | NLP - Theory Notebooks | Colab notebooks, drive files |
| 3.8 | NLP - Hugging Face | Intro to HF ecosystem |
| 3.9 | NLP - GPT from Scratch | Implementing GPT |
| 3.10 | NLP - Theory Questions | Review questions |
| 3.11 | NLP - RAG | Retrieval-Augmented Generation |

## Sprint Project: Best Buy Product Classification

### Objetivo
Clasificar productos de BestBuy en categorias usando embeddings multimodales (imagen + texto).

### Pipeline
```
1. EDA + Image Download
2. Image Embeddings (ResNet50, ConvNextV2)
3. Text Embeddings (MiniLM, BERT)
4. Preprocessing (merge, split, feature extraction)
5. Classic ML (RandomForest, LogisticRegression)
6. MLP (TensorFlow, early fusion)
```

### Dataset
- `data/processed_products_with_images.csv` - Productos con metadata
- `data/images/` - Imagenes 224x224 JPG
- `categories.json` - Jerarquia de categorias (opcional)
- Columnas: sku, name, description, image, type, price, shipping, manufacturer, class_id, sub_class1_id, image_path

### Archivos a implementar (TODOs)
| # | Archivo | Que implementar |
|---|---------|-----------------|
| 1 | `src/vision_embeddings_tf.py` | `FoundationalCVModel` (ResNet50 + ConvNextV2), `load_and_preprocess_image` |
| 2 | `src/nlp_models.py` | `HuggingFaceEmbeddings` (MiniLM obligatorio), `get_embedding`, `get_embeddings_df` |
| 3 | `src/utils.py` | `train_test_split_and_feature_extraction` |
| 4 | `src/classifiers_classic_ml.py` | `visualize_embeddings` (PCA 2D/3D), `train_and_evaluate_model` (RF, LR) |
| 5 | `src/classifiers_mlp.py` | `MultimodalDataset`, `create_early_fusion_model`, `train_mlp` |
| 6 | Notebook | `AnyoneAI - Sprint Project 04.ipynb` - Ejecutar pipeline completo |

### Modelos requeridos
- **Vision:** ResNet50 (keras.applications) + ConvNextV2 (HuggingFace TF)
- **Text:** sentence-transformers/all-MiniLM-L6-v2 (obligatorio)
- **Classic ML:** RandomForest + LogisticRegression (sklearn)
- **MLP:** TensorFlow early fusion model

### Targets de performance
| Modelo | Accuracy min | F1 min |
|--------|-------------|--------|
| Multimodal (imagen+texto) | 85% | 80% |
| Solo texto | 85% | 80% |
| Solo imagen | 75% | 70% |

### Output esperado
- `results/multimodal_results.csv`
- `results/image_results.csv`
- `results/text_results.csv`
- `Embeddings/Embeddings_{model_name}.csv`

### Submission
ZIP con: `src/`, `tests/`, `results/`, `README.md` (sin data/ ni Embeddings/)

### Tests
```bash
pytest tests/ --disable-warnings
# 21 tests esperados
```

## Stack
- Python 3.9.6
- TensorFlow 2.x, Keras
- Hugging Face Transformers (TF backend)
- scikit-learn (RF, LR, PCA, train_test_split, LabelEncoder)
- pandas, numpy, matplotlib
- Jupyter Notebook
- pytest, black

## PDFs de teoria
- `CNN_short_version.pdf`
- `17.1_Intro_NLP_Normalization_Vectorization.pdf`
- `17.2_Word_Embeddings.pdf`
- `17.3_RNN_Attention.pdf`
- `17.4_Transformers.pdf`
- `17.5_LLMs.pdf`
- `17.6_LLMs_2.pdf`
- `RAG.pdf`
- `Sprint_Project_4_Motivation.pdf`
- `Sprint_Project_4_Multimodal_eCommerce.pdf`
- `S4_C2_Image_Embeddings.pdf`
- `S4_C3_Text_Embeddings.pdf`
- `S4_C4_Data_Preprocessing.pdf`
- `S4_C5_Training_MLP.pdf`
- `S4_Sprint_Project_Presentation.pdf`

## Estado
EN CURSO - Assignment extraido en `C:/Anyone_AI/sprint_4/Assignment/`, TODOs pendientes.
