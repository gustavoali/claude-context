---
title: "Do Users Write More Insecure Code with AI Assistants?"
authors: "Neil Perry, Megha Srivastava, Deepak Kumar, Dan Boneh"
institution: Stanford University
year: 2023
venue: "CCS '23: ACM SIGSAC Conference on Computer and Communications Security (pp. 2785-2799)"
url: https://arxiv.org/abs/2211.03622
arxiv_id: "2211.03622"
date_summarized: 2026-03-19
---

# Do Users Write More Insecure Code with AI Assistants?

## Summary

Perry et al. conducted a controlled user study with 47 participants (33 in the AI-assisted group, 14 in the control group) to examine how access to an AI code assistant (OpenAI Codex davinci-002) affects the security of code written for security-sensitive programming tasks. Participants completed five tasks spanning Python, JavaScript, and C that involved encryption, digital signatures, sandboxed file access, SQL database operations, and string formatting. The study found that participants with AI assistant access wrote significantly less secure code than the control group across 4 of 5 tasks, while simultaneously believing their code was more secure -- a dangerous overconfidence effect. The AI model was a direct source of many security vulnerabilities: for example, 58% of authentication issues in Task 1, 73% of symlink vulnerabilities in Task 3, and 48% of randomness issues in Task 2 were traced to AI-generated code. However, participants who were more skeptical of the AI, actively refined their prompts, and adjusted model parameters (such as temperature) produced fewer vulnerabilities. The authors conclude that AI code assistants, as deployed at the time of the study, create a measurable increase in security risk, compounded by user overconfidence in AI-generated code. They recommend security-aware UI design, filtering insecure code from training data, and user education focused on verifying AI outputs rather than blindly accepting them.

## Key Statistics and Data Points

### Participants
- 47 total (54 recruited, 7 excluded)
- 33 experiment group (AI-assisted), 14 control group
- 66% undergraduate, 19% graduate, 15% professional
- 87% aged 18-24; 62% had 0-5 years programming experience

### Security Outcomes by Task (Secure solutions: Experiment vs Control)

| Task | Description | AI Group Secure | Control Secure | AI Group Insecure | Control Insecure | p-value |
|------|-------------|-----------------|----------------|-------------------|------------------|---------|
| Q1 | Encryption/Decryption (Python) | 21% | 36% | 43% | 7% | 0.017 |
| Q2 | ECDSA Signing (Python) | 3% | 21% | - | - | 0.039 |
| Q3 | Sandboxed File Access (Python) | 12% | 29% | 52% | 30% | 0.019 |
| Q4 | SQL Injection (JavaScript) | 36% | 50% | 36% | 7% | 0.041 |
| Q5 | C String Formatting | Mixed/inconclusive | - | - | - | n.s. |

### Regression Analysis
- Combined group effect coefficient: -0.63, p=0.056 (marginal significance)
- Q1 group effect: coefficient -2.14, p=0.018 (significant after Benjamini-Hochberg correction)

### Overconfidence Effect
- Participants with AI access rated insecure answers as secure more frequently
- Q3 example: participants with secure solutions rated AI trust at 1.5/5, while those with insecure solutions rated trust at 4.0/5 (inverse relationship)

### AI Output Acceptance and Prompt Behavior
- Q4 (SQL) had highest AI output acceptance rate: 25.3%
- Q5 (C) had 0% direct acceptance (AI struggled with valid C code)
- 87% of secure responses required significant user edits
- Participants with security experience copied AI outputs less (9.2% vs 22.4%)
- Average 4.6 queries per question
- Only 51.5% adjusted temperature; those who did had fewer insecure answers (20% vs 70% for Q1)
- Higher temperature correlated with more secure code (mean 0.34 vs 0.04)

### Source Attribution of Vulnerabilities (AI-sourced %)
- Q1 authentication issues: 58% from AI
- Q2 randomness issues: 48% from AI
- Q3 parent directory traversal: 61% from AI
- Q3 symlink handling: 73% from AI
- Q4 SQL injection: 30% from AI
- Q5 buffer overflow: 12% from AI

### Inter-rater Reliability (Cohen's Kappa)
- Correctness: 0.70-0.97
- Security: 0.68-0.88

## Main Conclusions

1. AI assistants significantly increased security vulnerabilities across most tasks while maintaining functional correctness
2. Users developed a false sense of security, overestimating the safety of AI-assisted code
3. Prompt quality and skepticism toward AI output correlated with better security outcomes
4. Cyclical prompting (reusing AI output as new prompts) amplified vulnerabilities
5. Parameter adjustment (especially temperature) helped produce more secure code

## Recommendations from Authors

- UI designers should display library documentation, make temperature adjustable, and provide real-time security warnings
- Model training should use static analysis to filter insecure code from training data
- User education should focus on testing/verifying security rather than assuming AI correctness
- Consider reinforcement learning with security-focused human feedback
