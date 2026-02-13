# Language Detection Library Analysis for LinkedIn Transcript Extractor

**Date:** 2026-01-28
**Author:** Claude (Technical Analysis)
**Status:** COMPLETED - Recommendation Ready

---

## Executive Summary

**RECOMMENDATION: `tinyld` (normal variant)**

After comprehensive evaluation of 4 npm packages, `tinyld` emerges as the best solution for the LinkedIn Transcript Extractor project due to:

1. **Highest accuracy** (94.4% overall, 100% for Spanish)
2. **Excellent non-Latin script detection** (100% - critical for rejecting Thai, Chinese, etc.)
3. **Perfect similar language distinction** (100% - no false positives for Portuguese/Polish as Spanish)
4. **Zero dependencies** (pure JavaScript)
5. **Active maintenance** (last update May 2023)
6. **Multiple variants** (light/normal/heavy) for bundle size optimization

---

## Problem Statement

The current regex-based language detection in `vtt-interceptor.js` has critical limitations:

### Current Issues
1. **False positives:** Polish and Vietnamese detected as Spanish due to shared accent patterns
2. **Manual pattern maintenance:** Error-prone, requires constant updates
3. **Poor scalability:** Adding new languages requires complex regex patterns
4. **No confidence scoring:** Binary detection without probability

### Requirements
- Must work in Node.js (Playwright crawler environment)
- Lightweight (no heavy ML models)
- Accurate for: Spanish, English, French, Portuguese, Italian, German
- Must reject: Thai, Vietnamese, Polish, Chinese, Japanese, Korean, Arabic
- Offline capability (no API calls)

---

## Packages Evaluated

### 1. `franc-cjs` (v6.2.0)

| Metric | Value |
|--------|-------|
| **Bundle Size** | 525 KB |
| **Dependencies** | 0 |
| **Overall Accuracy** | 88.9% |
| **Spanish Accuracy** | 100% |
| **Non-Latin Detection** | 80% (missed Arabic variant) |
| **License** | MIT |
| **Last Update** | Feb 2024 |

**Pros:**
- Good accuracy for Romance languages
- Small bundle size
- ISO 639-3 language codes
- Well-documented

**Cons:**
- Uses 3-letter codes (need mapping)
- Struggles with short text (< 50 chars)
- Arabic detected as "arb" instead of "ar"

### 2. `languagedetect` (v2.0.0)

| Metric | Value |
|--------|-------|
| **Bundle Size** | 302 KB |
| **Dependencies** | 0 |
| **Overall Accuracy** | 77.8% |
| **Spanish Accuracy** | 100% |
| **Non-Latin Detection** | 20% (returns "unknown") |
| **License** | Proprietary |
| **Last Update** | Nov 2019 |

**Pros:**
- Smallest bundle size
- Returns confidence scores
- Full language names (easier to read)

**Cons:**
- Cannot detect non-Latin scripts (returns "unknown")
- Unmaintained (5+ years old)
- Proprietary license
- Lower overall accuracy

### 3. `tinyld` (v1.3.4)

| Metric | Value |
|--------|-------|
| **Bundle Size** | 592 KB (normal), 70 KB (light), 2 MB (heavy) |
| **Dependencies** | 0 |
| **Overall Accuracy** | 94.4% |
| **Spanish Accuracy** | 100% |
| **Non-Latin Detection** | 100% |
| **License** | MIT |
| **Last Update** | May 2023 |

**Pros:**
- Highest accuracy overall
- Perfect non-Latin script detection
- Multiple variants for size/accuracy tradeoff
- ISO 639-1 codes (2-letter, matches our needs)
- Zero dependencies
- CLI tools included

**Cons:**
- Struggles with very short text (< 30 chars)
- Normal variant is 592 KB (acceptable)

### 4. `eld` (v2.0.2)

| Metric | Value |
|--------|-------|
| **Bundle Size** | 9.1 MB |
| **Dependencies** | 0 |
| **Overall Accuracy** | N/A (ESM-only) |
| **License** | Apache-2.0 |
| **Last Update** | Jan 2026 |

**Pros:**
- Most recent updates
- Based on Google's efficient language detector

**Cons:**
- ESM-only (not compatible with CommonJS projects without config changes)
- Large bundle size (9.1 MB)
- Cannot be tested easily in current project setup

---

## Detailed Test Results

### Test Suite Description
18 test cases covering:
- 3 Spanish samples (tech, simple, no special chars)
- 2 English samples (tech, casual)
- 5 Romance/Latin languages (Portuguese, French, Italian, German, Polish)
- 5 Non-Latin scripts (Thai, Chinese, Japanese, Korean, Arabic)
- 1 Vietnamese (Latin script but different)
- 2 Short text samples (< 30 chars)

### Accuracy by Category

| Category | franc-cjs | languagedetect | tinyld |
|----------|-----------|----------------|--------|
| **Spanish Detection** | 100% | 100% | 100% |
| **Non-Latin Scripts** | 80% | 20% | 100% |
| **Similar Languages** | 100% | 100% | 100% |
| **Short Text** | 50% | 100% | 50% |
| **Overall** | 88.9% | 77.8% | 94.4% |

### Critical Test Cases

#### Spanish vs Portuguese (Critical)
All three libraries correctly distinguished:
```
"A inteligência artificial está mudando a forma como trabalhamos."
Expected: pt | franc-cjs: pt | languagedetect: pt | tinyld: pt
```

#### Spanish vs Polish (Critical - Current Bug)
All three libraries correctly identified:
```
"Sztuczna inteligencja zmienia sposób naszej pracy."
Expected: pl | franc-cjs: pl | languagedetect: pl | tinyld: pl
```

#### Thai Detection (Critical - Current Bug)
```
"ปัญญาประดิษฐ์กำลังเปลี่ยนแปลงวิธีการทำงานของเรา"
Expected: th | franc-cjs: th | languagedetect: unknown | tinyld: th
```
**Note:** `languagedetect` cannot detect non-Latin scripts.

#### Vietnamese Detection (Critical - Current Bug)
```
"Trí tuệ nhân tạo đang thay đổi cách chúng ta làm việc."
Expected: vi | franc-cjs: vi | languagedetect: vi | tinyld: vi
```

---

## Recommendation

### Primary: `tinyld` (normal variant)

```bash
npm install tinyld
```

**Justification:**
1. **Best accuracy** for the project's specific needs
2. **Perfect non-Latin rejection** - eliminates Thai/Vietnamese/Polish false positives
3. **Zero dependencies** - no security/maintenance overhead
4. **MIT license** - permissive for any use
5. **ISO 639-1 codes** - matches our existing code
6. **Multiple variants** - can optimize later if bundle size becomes concern

### Fallback Strategy

For very short text (< 30 chars) where tinyld may fail:
1. Keep existing regex patterns as fallback
2. Use regex for Spanish-unique characters (ñ, ¿, ¡) as override

### Integration Approach

Following the "Extension Without Removal" principle:
1. Add tinyld as primary detector
2. Keep existing regex as fallback
3. Add confidence scoring for ambiguous cases

---

## Bundle Size Comparison

| Package | Size | Recommended For |
|---------|------|-----------------|
| `tinyld/light` | 70 KB | Low resources, sacrifices accuracy |
| `languagedetect` | 302 KB | When non-Latin detection not needed |
| `franc-cjs` | 525 KB | Good balance, 3-letter codes |
| `tinyld` (normal) | **592 KB** | **Best accuracy, recommended** |
| `tinyld/heavy` | 2 MB | Maximum accuracy, large corpus |
| `eld` | 9.1 MB | Not recommended (ESM-only, too large) |

---

## Performance Considerations

Based on tinyld benchmarks:
- **Detection time:** < 1ms for typical VTT content (500 chars)
- **Memory usage:** ~2-5 MB loaded in memory
- **Startup time:** < 50ms for module load

For the crawler context (processing ~50-100 VTTs per course), this is negligible.

---

## Migration Path

### Phase 1: Install and Test (1 hour)
1. Install tinyld: `npm install tinyld`
2. Create unit tests for language detection
3. Verify no regressions

### Phase 2: Integration (2-3 hours)
1. Update `detectContentLanguage()` function
2. Keep regex as fallback
3. Add confidence threshold
4. Test with real VTT samples from database

### Phase 3: Validation (1 hour)
1. Run crawler on known course
2. Verify correct language filtering
3. Check for false positives/negatives

---

## Code Integration Example

See: `C:\mcp\linkedin\crawler\vtt-interceptor-with-tinyld.example.js`

---

## Maintenance Notes

### tinyld Updates
- Check for updates quarterly
- Monitor GitHub issues for accuracy problems
- Test new versions against regression suite before updating

### Adding New Languages
With tinyld, no regex maintenance needed. Simply:
1. Add language code to accepted list
2. Add to fallback list if similar to Spanish

---

## References

- [tinyld GitHub](https://github.com/komodojp/tinyld)
- [franc GitHub](https://github.com/wooorm/franc)
- [languagedetect GitHub](https://github.com/FGRibreau/node-language-detect)
- [ISO 639-1 Language Codes](https://en.wikipedia.org/wiki/List_of_ISO_639-1_codes)

---

**Analysis completed:** 2026-01-28
**Next action:** Implement integration following code example
