# Learnings - AnyoneAI Sprint 4

### 2026-03-06 - TensorFlow 2.10 requires Python 3.9
**Context:** Setting up AnyoneAI Sprint 4 ML project environment on Windows
**Learning:** TensorFlow 2.10.0 is not compatible with Python 3.11+. It requires Python 3.9 (or 3.10 at most). When a requirements.txt pins old TF versions, verify Python version compatibility before attempting to install.
**Applies to:** Any ML project with pinned TensorFlow versions, environment setup

### 2026-03-06 - Multimodal classification: text outperforms images significantly
**Context:** Training image-only, text-only, and fusion MLP classifiers for product categorization (Best Buy data, 16 categories, ~50K products)
**Learning:** Text features (93% accuracy) vastly outperformed image features (82%) for product classification. Early fusion (92%) did not beat text-only, suggesting text carries most discriminative signal for product categories. When building multimodal classifiers, always benchmark unimodal baselines first.
**Applies to:** Multimodal ML projects, product classification tasks

### 2026-03-06 - ConvNextV2 embeddings for ~50K images is very slow on CPU
**Context:** Generating image embeddings using ConvNextV2 backbone without GPU
**Learning:** Generating vision embeddings (e.g., ConvNextV2 via timm/transformers) for large image datasets (~50K) on CPU takes hours. ResNet50 via keras.applications is significantly faster on CPU and doesn't require downloading HuggingFace models. For CPU-only environments, prefer lighter backbones or pre-compute embeddings on GPU machines.
**Applies to:** Computer vision pipelines without GPU, embedding generation at scale

### 2026-03-07 - MCP servers require Claude Code restart to activate
**Context:** Configured @piotr-agier/google-drive-mcp in ~/.claude/settings.json during a session, then tried to use it in the same session
**Learning:** MCP servers added to settings.json are only loaded at Claude Code session startup. If you configure a new MCP server mid-session, you must restart Claude Code (close and reopen) for the tools to become available. The server may start fine when tested manually, but Claude Code won't expose its tools until next session init.
**Applies to:** Any MCP server setup, Claude Code configuration changes

### 2026-03-07 - @piotr-agier/google-drive-mcp is read-only (no upload)
**Context:** Set up Google Drive MCP server with OAuth to upload project files to Google Drive for Colab
**Learning:** The `@piotr-agier/google-drive-mcp` npm package only provides read/search capabilities for Google Drive, not file upload. For uploading files to Google Drive programmatically, you need either a custom Python script using the Google Drive API, or manual upload via the browser. The MCP setup effort was wasted for the upload use case.
**Applies to:** Choosing tools for Google Drive integration, MCP server selection

