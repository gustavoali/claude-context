# YouTube Content Intelligence Pipeline (MCP-based)

## Project Info
- **Ubicacion:** C:\mcp\youtube
- **Tipo:** MCP Server
- **Estado:** En desarrollo

---

## 1. Executive Summary

This document defines the full Product Requirements Document (PRD) and complete development issue breakdown for a system that transforms a YouTube URL into structured, analyzable text using an MCP-based architecture.

The system enables LLMs (ChatGPT, Claude, local models) to consume *real video content* instead of inferred summaries.

---

## 2. Product Goal

Given a YouTube URL, automatically produce:

- Verified transcript (subtitles or Whisper)
- Metadata
- Analytical artifacts (summary, key points, timeline, claims)
- Structured outputs (JSON, Markdown)

---

## 3. Functional Requirements

### 3.1 Input

- video_url (required)
- prefer_langs (default: ["es","en"])
- analysis_profile: basic | deep | fact_check
- whisper_model: tiny | base | small | medium | large
- output_formats: json | md
- force_whisper: boolean

---

### 3.2 Output Contract (JSON)

[See previous section - unchanged, stable contract]

---

## 4. Processing Pipeline

1. URL normalization
2. Metadata extraction
3. Subtitle extraction (manual -> auto -> any)
4. Whisper fallback
5. Text normalization
6. Artifact generation
7. Caching + diagnostics

---

## 5. MCP Server Tools

- youtube.get_transcript
- youtube.get_digest
- youtube.export_markdown
- system.health
- cache.purge

---

## 6. Non-Functional Requirements

- Deterministic output
- Caching
- Observability
- Portability (Windows, WSL, Linux)
- Legal-safe usage

---

## 7. Complete Issue Breakdown (Jira / GitHub)

### EPIC 1 - Core Infrastructure

#### Issue 1.1 - Project bootstrap
- Repo structure
- Virtualenv
- Base dependencies

#### Issue 1.2 - URL normalization
- watch / youtu.be / shorts
- Validation + errors

---

### EPIC 2 - Metadata Extraction

#### Issue 2.1 - yt-dlp metadata wrapper
- title, channel, duration
- publish date (best-effort)

#### Issue 2.2 - Metadata normalization

---

### EPIC 3 - Subtitle Extraction

#### Issue 3.1 - youtube-transcript-api integration
- language priority
- error handling

#### Issue 3.2 - yt-dlp subtitle fallback
- auto-subs
- VTT parsing

---

### EPIC 4 - Whisper Transcription

#### Issue 4.1 - Audio download
- yt-dlp audio extraction
- temp storage

#### Issue 4.2 - Whisper transcription
- model selection
- segment generation

#### Issue 4.3 - Cleanup & caching

---

### EPIC 5 - Text Post-Processing

#### Issue 5.1 - Transcript normalization
- punctuation
- deduplication

#### Issue 5.2 - Language detection

---

### EPIC 6 - Artifact Generation

#### Issue 6.1 - Summary generation
- basic / deep modes

#### Issue 6.2 - Key points extraction

#### Issue 6.3 - Timeline generation

#### Issue 6.4 - Claims classification
- fact / opinion / prediction

---

### EPIC 7 - MCP Server

#### Issue 7.1 - MCP server scaffold
- FastMCP
- tool registration

#### Issue 7.2 - youtube.get_transcript

#### Issue 7.3 - youtube.get_digest

#### Issue 7.4 - youtube.export_markdown

#### Issue 7.5 - system.health

---

### EPIC 8 - Caching & Performance

#### Issue 8.1 - Cache key strategy

#### Issue 8.2 - Cache storage (disk)

---

### EPIC 9 - Observability

#### Issue 9.1 - Structured logging

#### Issue 9.2 - Error taxonomy

---

### EPIC 10 - Packaging & Delivery

#### Issue 10.1 - Dockerfile

#### Issue 10.2 - docker-compose

#### Issue 10.3 - README.md

---

## 8. Definition of Done

- Deterministic JSON output
- MCP tools callable
- Subtitle-first logic enforced
- Whisper fallback works
- Cache hit verified
- 6+ test URLs pass

---

## 9. Expected LLM Usage

1. User provides URL
2. LLM calls youtube.get_digest
3. Receives verified transcript
4. Performs analysis, RAG, debate

---

## 10. Closing Notes

This infrastructure acts as a **video-to-text cognitive extractor**, enabling reliable automation and LLM reasoning over audiovisual content.
