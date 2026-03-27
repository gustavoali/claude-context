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

### 2026-03-24 - sec_edgar_downloader v5+ renamed `save_path` to `download_folder`
**Context:** Setting up SEC EDGAR 10-K filing downloads for financial advisor chatbot project
**Learning:** The `sec_edgar_downloader` library renamed the `Downloader` constructor parameter from `save_path` to `download_folder` in recent versions. Using the old parameter name fails silently (no error, but files may go to unexpected location). Always check `help(Downloader.__init__)` when using pinned vs latest versions.
**Applies to:** Projects using `sec_edgar_downloader` library, SEC EDGAR data pipelines

### 2026-03-24 - sec_edgar_downloader saves under `sec-edgar-filings/` subdirectory
**Context:** Download script reported 0 files downloaded despite successful API calls because file count logic looked in `output_dir/TICKER/10-K/` instead of actual path
**Learning:** `sec_edgar_downloader` creates an intermediate `sec-edgar-filings/` directory inside the download folder. Actual file structure is `download_folder/sec-edgar-filings/TICKER/FORM_TYPE/ACCESSION_NUMBER/{full-submission.txt, primary-document.html}`. File counting/processing logic must account for this extra directory level.
**Applies to:** SEC EDGAR download pipelines, file post-processing scripts

### 2026-03-24 - SEC 10-K filings come as HTML+TXT, not PDF
**Context:** Planning to use PyMuPDF/pdfplumber for text extraction from SEC filings
**Learning:** SEC EDGAR 10-K filings downloaded via `sec_edgar_downloader` come as `primary-document.html` and `full-submission.txt`, not PDFs. Text extraction can be done directly from HTML (BeautifulSoup) or plain text, eliminating the need for PDF parsing libraries. This simplifies the processing pipeline significantly.
**Applies to:** SEC EDGAR document processing, RAG pipelines over financial filings

### 2026-03-24 - sec_edgar_downloader fails silently on delisted/acquired tickers
**Context:** Bulk downloading 10-K filings for 50 NASDAQ tech companies; ANSS (Ansys, acquired by Synopsys) and CHEGG (delisted) failed with "Ticker is invalid and cannot be mapped to a CIK"
**Learning:** `sec_edgar_downloader` uses an internal ticker-to-CIK mapping that doesn't cover all tickers, especially recently delisted or acquired companies. The error is a `ValueError` that can be caught gracefully. When building bulk download scripts, always wrap individual ticker downloads in try/except and log failures separately rather than letting one bad ticker abort the entire batch. Expect ~2-5% failure rate on large ticker lists.
**Applies to:** SEC EDGAR bulk download pipelines, financial data collection scripts

