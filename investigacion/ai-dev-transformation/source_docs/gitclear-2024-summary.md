---
title: "Coding on Copilot: 2023 Data Suggests Downward Pressure on Code Quality (incl 2024 projections)"
year: 2024
author: Bill Harding / GitClear
url: https://www.gitclear.com/coding_on_copilot_data_shows_ais_downward_pressure_on_code_quality
pdf_url: https://gitclear-public.s3.us-west-2.amazonaws.com/Coding-on-Copilot-2024-Developer-Research.pdf
date_accessed: 2026-03-19
---

# GitClear - Coding on Copilot (2024)

## Summary

GitClear analyzed approximately 153 million changed lines of code authored between January 2020 and December 2023 to evaluate the impact of AI coding assistants (primarily GitHub Copilot) on code quality. The methodology classifies every code change into seven categories (added, deleted, moved, updated, copy/pasted, find/replaced, and churned) to approximate developer intent and measure code health. The central finding is that code churn -- the percentage of lines reverted or substantially revised within two weeks of being authored -- is projected to double in 2024 compared to the 2021 pre-AI baseline, reaching over 7% of all code changes. Simultaneously, the proportion of "moved" and "updated" code (indicators of refactoring and maintenance) declined sharply, while "added" and "copy/pasted" code increased, suggesting AI assistants discourage code reuse and encourage duplication. The study found a Pearson correlation coefficient of 0.98 between estimated Copilot adoption rates and the frequency of "mistake code" being pushed to repositories. The report concludes that while AI assistants boost raw productivity (more lines written), they exert downward pressure on code quality and create what Bill Harding calls "AI-induced technical debt." This represents the largest known structured code change dataset used to evaluate AI's impact on code quality.

## Key Statistics and Data Points

### Dataset
- **153 million** changed lines of code analyzed (Jan 2020 - Dec 2023)
- Later expanded to **211 million** lines (Jan 2020 - Dec 2024) in the 2025 follow-up report
- Largest known database of structured code change data used for AI code quality evaluation

### Code Churn
- Code churn projected to **double in 2024** vs 2021 pre-AI baseline
- **7.9%** of newly added code was revised within 2 weeks (2024), vs **5.5%** in 2020
- Projected **>7%** of all code changes reverted within two weeks in 2024

### Code Composition Shifts
- "Moved code" (refactoring indicator) dropped from **25%** of changed lines in 2021 to **<10%** in 2024
- "Copy/pasted" (cloned) code rose from **8.3%** to **12.3%** (2021 to 2024)
- Prevalence of duplicate code blocks in 2024 was approximately **10x higher** than two years prior

### Correlation
- Pearson correlation coefficient of **0.98** between estimated Copilot adoption and frequency of "mistake code" pushed to repos
- Estimated Copilot prevalence: ~0% in 2021, 5-10% in 2022, ~30% in 2023

### Code Change Categories (methodology)
- **Added**: new lines distinct from existing code (new features)
- **Deleted**: lines removed (cleanup, codebase health)
- **Moved**: lines cut/pasted to new file or function (refactoring)
- **Updated**: modifications to existing lines (maintenance)
- **Copy/pasted**: duplicated code blocks (technical debt indicator)
- **Churned**: authored, pushed, then reverted/revised within 2 weeks (mistake code)

### Conclusions
- AI assistants are very effective at **adding** code but discourage **refactoring and reuse**
- Net effect: increased raw productivity at the cost of maintainability
- Creates "AI-induced technical debt" that accumulates over time
- Current AI implementation encourages writing new code rather than improving existing code

## Related
- 2025 follow-up report: [AI Copilot Code Quality: 2025 Data Suggests 4x Growth in Code Clones](https://www.gitclear.com/ai_assistant_code_quality_2025_research)
