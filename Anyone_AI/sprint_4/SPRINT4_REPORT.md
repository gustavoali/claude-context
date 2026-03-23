# Sprint Project 04 - Multimodal Product Classification
## Step-by-Step Report

**Author:** Gustavo Ali
**Date:** 2026-03-21
**Dataset:** Best Buy Product Catalog (~51K products, 16 categories)

---

## 1. Problem Statement

Multi-class classification of Best Buy products into 16 categories using both textual descriptions and product images. The goal is to build unimodal (text-only, image-only) and multimodal (early fusion) classifiers that exceed accuracy and F1-score thresholds.

**Performance Targets:**

| Model | Accuracy | F1-Score |
|-------|----------|----------|
| Image-only | >= 75% | >= 70% |
| Text-only | >= 85% | >= 80% |
| Multimodal | >= 85% | >= 80% |

---

## 2. Dataset Overview

- **Source:** `data/processed_products_with_images.csv`
- **Rows:** 51,297 products
- **Columns:** sku, name, description, image (URL), type, price, shipping, manufacturer, class_id, sub_class1_id, num_classes, image_path
- **Images:** 49,689 JPG files (224x224 pixels) in `data/images/`
- **Classes:** 16 product categories (class_id), imbalanced distribution
  - Largest: abcat0900000 (9,317 samples)
  - Smallest: cat09000 (454 samples)

---

## 3. Embedding Generation

### 3.1 Image Embeddings

Two pre-trained computer vision models were used to extract visual features:

**ResNet50** (`tensorflow.keras.applications`)
- Architecture: 50-layer residual network pre-trained on ImageNet
- Output: 2,048-dimensional feature vector per image
- Processing: GlobalAveragePooling2D on penultimate layer output
- File: `Embeddings/Embeddings_resnet50.csv` (49,682 images x 2,048 features)

**ConvNextV2 Tiny** (`transformers.TFConvNextV2Model`)
- Architecture: ConvNextV2 Tiny pre-trained on ImageNet-1K (facebook/convnextv2-tiny-1k-224)
- Output: 768-dimensional feature vector per image
- Processing: Pooler output from transformer model
- File: `Embeddings/Embeddings_convnextv2_tiny.csv` (49,682 images x 768 features)

**Process:**
1. Images loaded and preprocessed to 224x224 RGB, normalized to [0, 1]
2. Corrupted/unreadable images filtered out (7 skipped)
3. Batch processing (32 images per batch) through the model
4. Features extracted and saved as CSV

### 3.2 Text Embeddings

**Sentence-Transformers MiniLM** (`sentence-transformers/all-MiniLM-L6-v2`)
- Architecture: 6-layer MiniLM distilled from BERT, fine-tuned for sentence similarity
- Output: 384-dimensional embedding vector per description
- Processing: Tokenization -> model forward pass -> mean pooling over sequence length
- File: `Embeddings/text_embeddings_minilm.csv` (51,297 rows x 384 features)

**Process:**
1. Product descriptions tokenized (max 512 tokens, with truncation and padding)
2. Forward pass through the transformer model
3. Mean pooling of last hidden state across sequence dimension
4. Embeddings saved as serialized lists in a single column

### 3.3 Embedding Merge

Text and image embeddings were merged using `preprocess_data()`:

1. Text embeddings parsed from serialized lists to individual columns (`text_1`, `text_2`, ..., `text_384`)
2. Image embedding columns renamed (`image_0`, `image_1`, ..., `image_767`)
3. Datasets joined on image filename (text `image_path` matched to image `ImageName`)
4. Final merged dataset: ~49K rows x 1,152 features (384 text + 768 image)
5. File: `Embeddings/embeddings_minilm.csv`

---

## 4. Dataset Preparation

- **Train/Test Split:** 70% training / 30% testing (random_state=42)
- **Feature extraction:**
  - Text features: 384 columns (prefix `text_`)
  - Image features: 768 columns (prefix `image_`)
  - Labels: `class_id` (16 classes)
- **Label encoding:** LabelEncoder fitted on training data only, applied to both sets

---

## 5. Model Training

### 5.1 Classic ML Models

Two classical models trained on each modality:

**RandomForestClassifier:**
- Ensemble of decision trees
- Applied to text-only, image-only, and combined features

**LogisticRegression:**
- Linear classification with softmax
- Applied to text-only, image-only, and combined features

Evaluation: Accuracy, Precision, Recall, F1-score, ROC-AUC with confusion matrices and ROC curves.

### 5.2 MLP Models (Early Fusion Neural Network)

Three Keras MLP models with early fusion architecture:

**Architecture:**
- Input layers: text (384-dim) and/or image (768-dim)
- Concatenation layer (for multimodal)
- Dense(256, ReLU) + BatchNorm + Dropout(0.2)
- Dense(128, ReLU) + BatchNorm + Dropout(0.2)
- Dense(16, Softmax) output

**Training Configuration:**
- Optimizer: Adam (lr=0.001)
- Loss: CategoricalCrossentropy
- Class weights: Balanced (computed from training distribution)
- Early stopping: patience=10, monitor=val_loss, restore_best_weights=True
- Max epochs: 50
- Batch size: 32
- Random seed: 42

**Models trained:**
1. **Image-only MLP:** Uses only the 768 ConvNextV2 features
2. **Text-only MLP:** Uses only the 384 MiniLM features
3. **Multimodal MLP (Early Fusion):** Concatenates both feature sets (1,152 total)

---

## 6. Results

### Final Performance (MLP Models)

| Model | Accuracy | F1-Score (macro) | AUC (macro) | Target Acc | Target F1 | Status |
|-------|----------|-----------------|-------------|------------|-----------|--------|
| **Image** | 79.72% | 73.18% | 96.81% | >= 75% | >= 70% | **PASS** |
| **Text** | 92.98% | 87.34% | 99.02% | >= 85% | >= 80% | **PASS** |
| **Multimodal** | 92.67% | 86.38% | 99.08% | >= 85% | >= 80% | **PASS** |

All three models exceed their respective targets.

### Key Observations

1. **Text embeddings are highly discriminative:** The text-only model (92.98% acc) nearly matches the multimodal model, indicating that product descriptions contain strong category signals.

2. **Image embeddings provide complementary information:** While image-only accuracy (79.72%) is lower, the AUC (96.81%) shows the model captures useful visual patterns. The gap in accuracy is likely due to the imbalanced class distribution affecting argmax predictions more than ranking.

3. **Multimodal fusion:** The early fusion model achieves the highest AUC (99.08%), confirming that combining modalities captures complementary information. The slightly lower accuracy than text-only (92.67% vs 92.98%) may be due to noise from image features in some categories where visual appearance is less distinctive.

4. **Class imbalance handling:** Balanced class weights in training helped the model perform well across all classes, as reflected in the macro-averaged F1 scores.

### Output Files

- `results/image_results.csv` - 14,880 predictions (Predictions, True Labels)
- `results/text_results.csv` - 14,880 predictions
- `results/multimodal_results.csv` - 14,880 predictions

---

## 7. Test Suite

19 automated tests validate the implementation:

| Test File | Tests | Description |
|-----------|-------|-------------|
| `test_utils.py` | 1 | Train/test split and feature extraction |
| `test_vision_embeddings_tf.py` | 3 | Image loading, ResNet50, ConvNextV2 models |
| `test_nlp_models.py` | 1 | HuggingFace MiniLM embeddings |
| `test_classifiers_classic_ml.py` | 3 | Visualization and classic ML training |
| `test_classifiers_mlp.py` | 11 | Dataset, model creation, training, results validation |

**Result: 19/19 PASSED**

---

## 8. Project Structure

```
Assignment/
  AnyoneAI - Sprint Project 04.ipynb   # Main notebook
  src/
    __init__.py
    utils.py                            # Data preprocessing, splits
    vision_embeddings_tf.py             # Image embedding generation
    nlp_models.py                       # Text embedding generation
    classifiers_classic_ml.py           # RandomForest, LogisticRegression
    classifiers_mlp.py                  # Keras MLP, early fusion
  data/
    processed_products_with_images.csv  # Product catalog (51K rows)
    images/                             # Product images (49K JPGs)
  Embeddings/
    Embeddings_resnet50.csv             # ResNet50 features
    Embeddings_convnextv2_tiny.csv      # ConvNextV2 features
    text_embeddings_minilm.csv          # MiniLM text features
    embeddings_minilm.csv               # Merged features
  results/
    image_results.csv                   # Image model predictions
    text_results.csv                    # Text model predictions
    multimodal_results.csv              # Multimodal predictions
  tests/                                # Automated test suite
  requirements.txt                      # Python dependencies
```

---

## 9. Environment

- **Python:** 3.9.13
- **TensorFlow:** 2.10.0
- **PyTorch:** 2.0.0
- **Transformers:** 4.44.2
- **scikit-learn:** 0.24.2
- **Platform:** Windows 11 (CPU execution)
