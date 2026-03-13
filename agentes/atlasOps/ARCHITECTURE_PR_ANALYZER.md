# Architecture Document: PR Analyzer Multi-Domain

**Version:** 1.0
**Date:** 2026-01-26
**Author:** Software Architect (Claude Code)
**Status:** DESIGN PHASE

---

## Executive Summary

### Business Value

El PR Analyzer Multi-Domain permite automatizar el analisis de codigo en Pull Requests de GitHub, detectando automaticamente el dominio tecnologico (.NET, Python, TypeScript) y aplicando agentes especializados que conocen las mejores practicas de cada stack.

**Beneficios clave:**
- Reduccion de tiempo de code review manual en 60-70%
- Deteccion temprana de issues especificos de cada tecnologia
- Consistencia en el feedback de PRs
- Escalabilidad para repositorios multi-stack

### High-Level Approach

```
GitHub PR Webhook
       |
       v
+----------------+     +------------------+     +------------------+
|  Orchestrator  | --> |  Agent Service   | --> |  Platform API    |
|  (TypeScript)  |     |    (Python)      |     |     (.NET)       |
|  Port: 3000    |     |   Port: 8000     |     |   Port: 5000     |
+----------------+     +------------------+     +------------------+
       |                       |                        |
       |  Webhook Handler      |  Domain Analyzers      |  Persistence
       |  Domain Detection     |  LLM Analysis          |  Audit Trail
       |  Task Distribution    |  Report Generation     |  GitHub API
       v                       v                        v
                    GitHub PR Comment
```

---

## 1. System Architecture

### 1.1 High-Level Architecture Diagram

```
                                   GitHub
                                     |
                                     | Webhook (PR created/updated)
                                     v
+-----------------------------------------------------------------------------+
|                              AtlasOps Platform                               |
|                                                                              |
|  +-----------------------------------------------------------------------+  |
|  |                     ORCHESTRATOR SERVICE (TypeScript)                 |  |
|  |                              Port: 3000                               |  |
|  |                                                                       |  |
|  |  +-------------------+  +-------------------+  +------------------+   |  |
|  |  | Webhook Handler   |  | Domain Detector   |  | Task Coordinator |   |  |
|  |  | POST /webhooks/   |  | Analyze files,    |  | Parallel agent   |   |  |
|  |  | github            |  | detect tech stack |  | execution        |   |  |
|  |  +-------------------+  +-------------------+  +------------------+   |  |
|  |           |                      |                      |             |  |
|  |           v                      v                      v             |  |
|  |  +-------------------------------------------------------------------+|  |
|  |  |                    PR Analysis Workflow (LangGraph)               ||  |
|  |  |                                                                   ||  |
|  |  |  [receive_webhook] -> [extract_diff] -> [detect_domains] ->      ||  |
|  |  |  [select_agents] -> [parallel_analysis] -> [consolidate] ->      ||  |
|  |  |  [post_comment]                                                  ||  |
|  |  +-------------------------------------------------------------------+|  |
|  +-----------------------------------------------------------------------+  |
|                                     |                                        |
|                                     | HTTP/REST                              |
|                                     v                                        |
|  +-----------------------------------------------------------------------+  |
|  |                     AGENT SERVICE (Python + FAISS)                    |  |
|  |                              Port: 8000                               |  |
|  |                                                                       |  |
|  |  +------------------+  +------------------+  +-------------------+    |  |
|  |  | Base Code        |  | Domain-Specific  |  | Report            |    |  |
|  |  | Analyzer         |  | Analyzers        |  | Consolidator      |    |  |
|  |  +------------------+  +------------------+  +-------------------+    |  |
|  |                              |                                        |  |
|  |         +--------------------+--------------------+                   |  |
|  |         |                    |                    |                   |  |
|  |         v                    v                    v                   |  |
|  |  +------------+       +------------+       +------------+             |  |
|  |  | .NET       |       | Python     |       | TypeScript |             |  |
|  |  | Analyzer   |       | Analyzer   |       | Analyzer   |             |  |
|  |  +------------+       +------------+       +------------+             |  |
|  |  - Nullable refs      - Type hints         - Type safety             |  |
|  |  - Async/await        - PEP8               - Null checks             |  |
|  |  - EF queries         - Imports            - React patterns          |  |
|  |  - SOLID              - Async              - ESLint rules            |  |
|  |                                                                       |  |
|  |  +------------------+                                                 |  |
|  |  | Generic          |                                                 |  |
|  |  | Analyzer         |                                                 |  |
|  |  +------------------+                                                 |  |
|  |  - Complexity                                                         |  |
|  |  - Duplication                                                        |  |
|  |  - Security basics                                                    |  |
|  |                                                                       |  |
|  +-----------------------------------------------------------------------+  |
|                                     |                                        |
|                                     | HTTP/REST                              |
|                                     v                                        |
|  +-----------------------------------------------------------------------+  |
|  |                     PLATFORM API (.NET 8)                             |  |
|  |                              Port: 5000                               |  |
|  |                                                                       |  |
|  |  +-------------------+  +-------------------+  +------------------+   |  |
|  |  | GitHub            |  | PR Analysis       |  | Audit            |   |  |
|  |  | Integration       |  | Repository        |  | Service          |   |  |
|  |  +-------------------+  +-------------------+  +------------------+   |  |
|  |  - Fetch PR diff        - Store analysis      - Track all actions   |  |
|  |  - Post comments        - Store findings      - Compliance          |  |
|  |  - Verify webhooks      - Query history       - Metrics             |  |
|  |                                                                       |  |
|  +-----------------------------------------------------------------------+  |
|                                                                              |
|  +-------------------------+  +-------------------------+                    |
|  |      PostgreSQL         |  |         Redis           |                    |
|  |      Port: 5432         |  |       Port: 6379        |                    |
|  +-------------------------+  +-------------------------+                    |
|  - PR Analyses               - Webhook deduplication                         |
|  - Domain Findings           - Analysis job queue                            |
|  - Agent Configurations      - Rate limiting                                 |
|  - Audit Logs                - GitHub token cache                            |
|                                                                              |
+-----------------------------------------------------------------------------+
                                     |
                                     | POST /repos/{owner}/{repo}/issues/{pr}/comments
                                     v
                                   GitHub
```

### 1.2 Component Responsibilities

#### Orchestrator Service (TypeScript/Fastify)

| Component | Responsibility |
|-----------|---------------|
| **Webhook Handler** | Receive GitHub webhooks, validate signatures, extract PR metadata |
| **Domain Detector** | Analyze file extensions/paths to determine tech domains |
| **Agent Registry** | Map domains to specialized agents, manage agent configurations |
| **Task Coordinator** | Distribute analysis tasks in parallel, collect results |
| **Report Builder** | Merge agent findings into unified PR comment |

#### Agent Service (Python/FastAPI)

| Component | Responsibility |
|-----------|---------------|
| **Base Analyzer** | Common code analysis (complexity, duplication) |
| **.NET Analyzer** | C# specific: nullable refs, async patterns, EF queries, SOLID |
| **Python Analyzer** | Python specific: type hints, PEP8, imports, async |
| **TypeScript Analyzer** | TS specific: types, null checks, React patterns |
| **Generic Analyzer** | Language-agnostic security and quality checks |
| **Report Consolidator** | Merge findings from multiple analyzers |

#### Platform API (.NET 8)

| Component | Responsibility |
|-----------|---------------|
| **GitHub Service** | Fetch diffs, post comments, verify webhook signatures |
| **PR Analysis Repository** | CRUD for analysis results |
| **Agent Config Repository** | Store/retrieve agent configurations |
| **Audit Service** | Log all operations for compliance |

---

## 2. API Contracts

### 2.1 Orchestrator Service APIs

#### Webhook Endpoint

```yaml
POST /api/webhooks/github
Content-Type: application/json
X-GitHub-Event: pull_request
X-Hub-Signature-256: sha256=<signature>

Request Body (GitHub PR Event):
{
  "action": "opened" | "synchronize" | "reopened",
  "number": 123,
  "pull_request": {
    "id": 123456789,
    "number": 123,
    "title": "feat: Add new feature",
    "head": {
      "sha": "abc123def456",
      "ref": "feature/new-feature"
    },
    "base": {
      "sha": "789xyz012",
      "ref": "main"
    },
    "user": {
      "login": "developer"
    },
    "html_url": "https://github.com/owner/repo/pull/123",
    "diff_url": "https://github.com/owner/repo/pull/123.diff"
  },
  "repository": {
    "id": 987654321,
    "full_name": "owner/repo",
    "private": false
  },
  "installation": {
    "id": 12345678
  }
}

Response 202 Accepted:
{
  "analysisId": "uuid-analysis-id",
  "status": "queued",
  "message": "PR analysis queued successfully",
  "estimatedCompletionSeconds": 30
}

Response 400 Bad Request:
{
  "error": "Invalid webhook payload",
  "code": "INVALID_PAYLOAD"
}

Response 401 Unauthorized:
{
  "error": "Invalid webhook signature",
  "code": "INVALID_SIGNATURE"
}
```

#### Analysis Status Endpoint

```yaml
GET /api/analyses/{analysisId}

Response 200 OK:
{
  "analysisId": "uuid-analysis-id",
  "prNumber": 123,
  "repository": "owner/repo",
  "status": "pending" | "analyzing" | "completed" | "failed",
  "domains": ["dotnet", "typescript"],
  "progress": {
    "total": 4,
    "completed": 2,
    "agents": [
      {"name": "dotnet-analyzer", "status": "completed"},
      {"name": "typescript-analyzer", "status": "running"},
      {"name": "generic-analyzer", "status": "pending"},
      {"name": "security-analyzer", "status": "pending"}
    ]
  },
  "startedAt": "2026-01-26T10:00:00Z",
  "completedAt": null,
  "commentUrl": null
}
```

#### Manual Analysis Trigger

```yaml
POST /api/analyses
Content-Type: application/json
Authorization: Bearer <jwt-token>

Request:
{
  "repository": "owner/repo",
  "prNumber": 123,
  "force": false
}

Response 202 Accepted:
{
  "analysisId": "uuid-analysis-id",
  "status": "queued"
}
```

### 2.2 Agent Service APIs

#### Code Analysis Endpoint

```yaml
POST /api/analyze/code
Content-Type: application/json

Request:
{
  "analysisId": "uuid-analysis-id",
  "domain": "dotnet" | "python" | "typescript" | "generic",
  "files": [
    {
      "path": "src/Services/UserService.cs",
      "content": "... file content ...",
      "diff": "... unified diff ...",
      "language": "csharp"
    }
  ],
  "prContext": {
    "title": "feat: Add user authentication",
    "description": "Implements JWT-based auth",
    "author": "developer",
    "baseBranch": "main"
  },
  "analysisConfig": {
    "maxIssuesPerFile": 10,
    "severityThreshold": "warning",
    "enabledChecks": ["nullable", "async", "security"]
  }
}

Response 200 OK:
{
  "analysisId": "uuid-analysis-id",
  "domain": "dotnet",
  "findings": [
    {
      "id": "finding-uuid",
      "severity": "error" | "warning" | "info" | "suggestion",
      "category": "nullable" | "async" | "security" | "performance" | "style",
      "message": "Nullable reference type not checked before use",
      "file": "src/Services/UserService.cs",
      "line": 42,
      "column": 15,
      "endLine": 42,
      "endColumn": 30,
      "codeSnippet": "    var user = _repository.FindById(id);",
      "suggestion": "Add null check: if (user is null) return NotFound();",
      "rule": "CS8602",
      "documentation": "https://docs.microsoft.com/..."
    }
  ],
  "summary": {
    "totalFindings": 5,
    "byCategory": {
      "nullable": 2,
      "async": 1,
      "security": 1,
      "style": 1
    },
    "bySeverity": {
      "error": 1,
      "warning": 3,
      "info": 1
    }
  },
  "metadata": {
    "analyzedFiles": 3,
    "latencyMs": 1250,
    "modelUsed": "claude-3-5-sonnet-20241022",
    "tokensUsed": 4500
  }
}
```

#### Batch Analysis Endpoint (Parallel)

```yaml
POST /api/analyze/batch
Content-Type: application/json

Request:
{
  "analysisId": "uuid-analysis-id",
  "tasks": [
    {
      "taskId": "task-1",
      "domain": "dotnet",
      "files": [...]
    },
    {
      "taskId": "task-2",
      "domain": "typescript",
      "files": [...]
    }
  ]
}

Response 200 OK:
{
  "analysisId": "uuid-analysis-id",
  "results": [
    {
      "taskId": "task-1",
      "status": "completed",
      "findings": [...]
    },
    {
      "taskId": "task-2",
      "status": "completed",
      "findings": [...]
    }
  ],
  "totalLatencyMs": 2500
}
```

#### Report Consolidation Endpoint

```yaml
POST /api/analyze/consolidate
Content-Type: application/json

Request:
{
  "analysisId": "uuid-analysis-id",
  "domainResults": [
    {
      "domain": "dotnet",
      "findings": [...],
      "summary": {...}
    },
    {
      "domain": "typescript",
      "findings": [...],
      "summary": {...}
    }
  ],
  "prContext": {
    "title": "...",
    "filesChanged": 15,
    "linesAdded": 450,
    "linesRemoved": 120
  }
}

Response 200 OK:
{
  "analysisId": "uuid-analysis-id",
  "report": {
    "overallScore": 78,
    "recommendation": "approve_with_suggestions" | "request_changes" | "approve",
    "summary": "Good PR overall with some nullable reference issues to address.",
    "sections": [
      {
        "domain": "dotnet",
        "score": 72,
        "criticalIssues": 1,
        "warnings": 3,
        "suggestions": 2
      },
      {
        "domain": "typescript",
        "score": 85,
        "criticalIssues": 0,
        "warnings": 1,
        "suggestions": 3
      }
    ],
    "topIssues": [
      {
        "severity": "error",
        "message": "...",
        "file": "...",
        "line": 42
      }
    ]
  },
  "markdownComment": "## PR Analysis Report\n\n..."
}
```

### 2.3 Platform API (.NET) APIs

#### GitHub Integration

```yaml
POST /api/github/comments
Content-Type: application/json
Authorization: Bearer <jwt-token>

Request:
{
  "repository": "owner/repo",
  "prNumber": 123,
  "body": "## PR Analysis Report\n\n...",
  "analysisId": "uuid-analysis-id"
}

Response 201 Created:
{
  "commentId": 987654321,
  "url": "https://github.com/owner/repo/pull/123#issuecomment-987654321",
  "createdAt": "2026-01-26T10:05:00Z"
}
```

#### PR Analysis Persistence

```yaml
POST /api/pr-analyses
Content-Type: application/json

Request:
{
  "analysisId": "uuid-analysis-id",
  "repository": "owner/repo",
  "prNumber": 123,
  "prTitle": "feat: Add new feature",
  "prAuthor": "developer",
  "headSha": "abc123",
  "baseSha": "def456",
  "domains": ["dotnet", "typescript"],
  "overallScore": 78,
  "recommendation": "approve_with_suggestions",
  "findingsCount": {
    "error": 1,
    "warning": 4,
    "info": 3,
    "suggestion": 5
  },
  "report": {...},
  "commentId": 987654321,
  "commentUrl": "https://..."
}

Response 201 Created:
{
  "id": "uuid-record-id",
  "analysisId": "uuid-analysis-id",
  "createdAt": "2026-01-26T10:05:00Z"
}
```

```yaml
GET /api/pr-analyses?repository=owner/repo&prNumber=123

Response 200 OK:
{
  "items": [
    {
      "id": "uuid-record-id",
      "analysisId": "uuid-analysis-id",
      "prNumber": 123,
      "overallScore": 78,
      "recommendation": "approve_with_suggestions",
      "createdAt": "2026-01-26T10:05:00Z",
      "commentUrl": "https://..."
    }
  ],
  "total": 1
}
```

---

## 3. Data Model

### 3.1 Entity Relationship Diagram

```
+------------------------+       +------------------------+
|     PrAnalyses         |       |     DomainFindings     |
+------------------------+       +------------------------+
| PK  AnalysisId (UUID)  |<----->| PK  FindingId (UUID)   |
|     Repository         |   1:N | FK  AnalysisId         |
|     PrNumber           |       |     Domain             |
|     PrTitle            |       |     Severity           |
|     PrAuthor           |       |     Category           |
|     HeadSha            |       |     Message            |
|     BaseSha            |       |     FilePath           |
|     Status             |       |     LineNumber         |
|     Domains (JSONB)    |       |     ColumnNumber       |
|     OverallScore       |       |     CodeSnippet        |
|     Recommendation     |       |     Suggestion         |
|     Report (JSONB)     |       |     Rule               |
|     GitHubCommentId    |       |     CreatedAt          |
|     CommentUrl         |       +------------------------+
|     StartedAt          |
|     CompletedAt        |       +------------------------+
|     CreatedAt          |       |   AgentConfigurations  |
+------------------------+       +------------------------+
         |                       | PK  ConfigId (UUID)    |
         |                       |     Domain             |
         v                       |     AgentName          |
+------------------------+       |     Settings (JSONB)   |
|      AuditLogs         |       |     EnabledChecks      |
+------------------------+       |     SeverityThreshold  |
| PK  AuditLogId (UUID)  |       |     MaxIssuesPerFile   |
| FK  AnalysisId         |       |     IsActive           |
|     Action             |       |     CreatedAt          |
|     EntityType         |       |     UpdatedAt          |
|     EntityId           |       +------------------------+
|     OldValue (JSONB)   |
|     NewValue (JSONB)   |       +------------------------+
|     UserId             |       |   WebhookDeliveries    |
|     IpAddress          |       +------------------------+
|     CreatedAt          |       | PK  DeliveryId (UUID)  |
+------------------------+       |     GitHubDeliveryId   |
                                 |     Event              |
                                 |     Action             |
                                 |     Repository         |
                                 |     PrNumber           |
                                 |     Payload (JSONB)    |
                                 |     Signature          |
                                 |     ProcessedAt        |
                                 |     Status             |
                                 |     ErrorMessage       |
                                 |     CreatedAt          |
                                 +------------------------+
```

### 3.2 DDL (PostgreSQL)

```sql
-- PR Analyses table
CREATE TABLE "PrAnalyses" (
    "AnalysisId" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "Repository" VARCHAR(255) NOT NULL,
    "PrNumber" INT NOT NULL,
    "PrTitle" VARCHAR(500),
    "PrAuthor" VARCHAR(100),
    "HeadSha" VARCHAR(40) NOT NULL,
    "BaseSha" VARCHAR(40) NOT NULL,
    "Status" VARCHAR(20) NOT NULL DEFAULT 'pending',
    "Domains" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "OverallScore" INT CHECK ("OverallScore" >= 0 AND "OverallScore" <= 100),
    "Recommendation" VARCHAR(50),
    "Report" JSONB,
    "GitHubCommentId" BIGINT,
    "CommentUrl" TEXT,
    "StartedAt" TIMESTAMPTZ,
    "CompletedAt" TIMESTAMPTZ,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_status CHECK ("Status" IN ('pending', 'analyzing', 'completed', 'failed')),
    CONSTRAINT chk_recommendation CHECK (
        "Recommendation" IS NULL OR
        "Recommendation" IN ('approve', 'approve_with_suggestions', 'request_changes')
    )
);

CREATE INDEX idx_pr_analyses_repo_pr ON "PrAnalyses"("Repository", "PrNumber");
CREATE INDEX idx_pr_analyses_status ON "PrAnalyses"("Status", "CreatedAt" DESC);
CREATE INDEX idx_pr_analyses_created ON "PrAnalyses"("CreatedAt" DESC);
CREATE UNIQUE INDEX idx_pr_analyses_head_sha ON "PrAnalyses"("Repository", "PrNumber", "HeadSha");

-- Domain Findings table
CREATE TABLE "DomainFindings" (
    "FindingId" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "AnalysisId" UUID NOT NULL REFERENCES "PrAnalyses"("AnalysisId") ON DELETE CASCADE,
    "Domain" VARCHAR(50) NOT NULL,
    "Severity" VARCHAR(20) NOT NULL,
    "Category" VARCHAR(50) NOT NULL,
    "Message" TEXT NOT NULL,
    "FilePath" VARCHAR(500) NOT NULL,
    "LineNumber" INT,
    "ColumnNumber" INT,
    "EndLineNumber" INT,
    "EndColumnNumber" INT,
    "CodeSnippet" TEXT,
    "Suggestion" TEXT,
    "Rule" VARCHAR(100),
    "Documentation" TEXT,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_severity CHECK ("Severity" IN ('error', 'warning', 'info', 'suggestion')),
    CONSTRAINT chk_domain CHECK ("Domain" IN ('dotnet', 'python', 'typescript', 'generic'))
);

CREATE INDEX idx_findings_analysis ON "DomainFindings"("AnalysisId");
CREATE INDEX idx_findings_severity ON "DomainFindings"("Severity", "AnalysisId");
CREATE INDEX idx_findings_domain ON "DomainFindings"("Domain", "AnalysisId");

-- Agent Configurations table
CREATE TABLE "AgentConfigurations" (
    "ConfigId" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "Domain" VARCHAR(50) NOT NULL,
    "AgentName" VARCHAR(100) NOT NULL,
    "Settings" JSONB NOT NULL DEFAULT '{}'::jsonb,
    "EnabledChecks" JSONB NOT NULL DEFAULT '[]'::jsonb,
    "SeverityThreshold" VARCHAR(20) NOT NULL DEFAULT 'warning',
    "MaxIssuesPerFile" INT NOT NULL DEFAULT 10,
    "IsActive" BOOLEAN NOT NULL DEFAULT TRUE,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    "UpdatedAt" TIMESTAMPTZ,

    CONSTRAINT uk_agent_domain UNIQUE ("Domain", "AgentName")
);

-- Webhook Deliveries table (for idempotency)
CREATE TABLE "WebhookDeliveries" (
    "DeliveryId" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "GitHubDeliveryId" VARCHAR(100) NOT NULL UNIQUE,
    "Event" VARCHAR(50) NOT NULL,
    "Action" VARCHAR(50),
    "Repository" VARCHAR(255) NOT NULL,
    "PrNumber" INT,
    "Payload" JSONB NOT NULL,
    "Signature" VARCHAR(100),
    "ProcessedAt" TIMESTAMPTZ,
    "Status" VARCHAR(20) NOT NULL DEFAULT 'received',
    "ErrorMessage" TEXT,
    "CreatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_delivery_status CHECK ("Status" IN ('received', 'processing', 'completed', 'failed', 'skipped'))
);

CREATE INDEX idx_webhook_github_id ON "WebhookDeliveries"("GitHubDeliveryId");
CREATE INDEX idx_webhook_repo_pr ON "WebhookDeliveries"("Repository", "PrNumber");
CREATE INDEX idx_webhook_created ON "WebhookDeliveries"("CreatedAt" DESC);

-- Seed initial agent configurations
INSERT INTO "AgentConfigurations" ("Domain", "AgentName", "Settings", "EnabledChecks") VALUES
('dotnet', 'dotnet-analyzer', '{"model": "claude-3-5-sonnet-20241022", "maxTokens": 8000}'::jsonb,
 '["nullable", "async", "ef_queries", "solid", "security"]'::jsonb),
('python', 'python-analyzer', '{"model": "claude-3-5-sonnet-20241022", "maxTokens": 8000}'::jsonb,
 '["type_hints", "pep8", "imports", "async", "security"]'::jsonb),
('typescript', 'typescript-analyzer', '{"model": "claude-3-5-sonnet-20241022", "maxTokens": 8000}'::jsonb,
 '["types", "null_checks", "react_patterns", "eslint", "security"]'::jsonb),
('generic', 'generic-analyzer', '{"model": "claude-3-5-haiku-20241022", "maxTokens": 4000}'::jsonb,
 '["complexity", "duplication", "security_basics"]'::jsonb);
```

### 3.3 DTOs (TypeScript)

```typescript
// orchestrator/src/types/pr-analyzer.ts

export interface PRWebhookPayload {
  action: 'opened' | 'synchronize' | 'reopened' | 'closed';
  number: number;
  pull_request: {
    id: number;
    number: number;
    title: string;
    body: string | null;
    head: { sha: string; ref: string };
    base: { sha: string; ref: string };
    user: { login: string };
    html_url: string;
    diff_url: string;
  };
  repository: {
    id: number;
    full_name: string;
    private: boolean;
  };
  installation?: { id: number };
  sender: { login: string };
}

export interface AnalysisRequest {
  analysisId: string;
  repository: string;
  prNumber: number;
  prTitle: string;
  prAuthor: string;
  headSha: string;
  baseSha: string;
  files: FileChange[];
  domains: Domain[];
}

export interface FileChange {
  path: string;
  status: 'added' | 'modified' | 'removed' | 'renamed';
  additions: number;
  deletions: number;
  content?: string;
  diff: string;
  language: string;
}

export type Domain = 'dotnet' | 'python' | 'typescript' | 'generic';

export interface DomainMapping {
  domain: Domain;
  extensions: string[];
  patterns: RegExp[];
}

export interface Finding {
  id: string;
  severity: 'error' | 'warning' | 'info' | 'suggestion';
  category: string;
  message: string;
  file: string;
  line?: number;
  column?: number;
  endLine?: number;
  endColumn?: number;
  codeSnippet?: string;
  suggestion?: string;
  rule?: string;
  documentation?: string;
}

export interface DomainAnalysisResult {
  domain: Domain;
  findings: Finding[];
  summary: {
    totalFindings: number;
    byCategory: Record<string, number>;
    bySeverity: Record<string, number>;
  };
  metadata: {
    analyzedFiles: number;
    latencyMs: number;
    modelUsed: string;
    tokensUsed: number;
  };
}

export interface ConsolidatedReport {
  overallScore: number;
  recommendation: 'approve' | 'approve_with_suggestions' | 'request_changes';
  summary: string;
  sections: DomainSection[];
  topIssues: Finding[];
  markdownComment: string;
}

export interface DomainSection {
  domain: Domain;
  score: number;
  criticalIssues: number;
  warnings: number;
  suggestions: number;
  findings: Finding[];
}

export type AnalysisStatus = 'pending' | 'analyzing' | 'completed' | 'failed';

export interface AnalysisProgress {
  analysisId: string;
  status: AnalysisStatus;
  progress: {
    total: number;
    completed: number;
    agents: AgentProgress[];
  };
  startedAt: string;
  completedAt?: string;
  commentUrl?: string;
}

export interface AgentProgress {
  name: string;
  domain: Domain;
  status: 'pending' | 'running' | 'completed' | 'failed';
  error?: string;
}
```

### 3.4 DTOs (Python - Pydantic)

```python
# agents-py/src/models/pr_analyzer.py

from datetime import datetime
from enum import Enum
from typing import List, Optional, Dict, Any
from uuid import UUID, uuid4
from pydantic import BaseModel, Field, ConfigDict


class Domain(str, Enum):
    DOTNET = "dotnet"
    PYTHON = "python"
    TYPESCRIPT = "typescript"
    GENERIC = "generic"


class Severity(str, Enum):
    ERROR = "error"
    WARNING = "warning"
    INFO = "info"
    SUGGESTION = "suggestion"


class FileInfo(BaseModel):
    """File information for analysis."""
    path: str = Field(description="File path relative to repo root")
    content: str = Field(description="File content")
    diff: str = Field(description="Unified diff")
    language: str = Field(description="Programming language")


class PRContext(BaseModel):
    """PR context information."""
    title: str
    description: Optional[str] = None
    author: str
    base_branch: str = "main"
    files_changed: int = 0
    lines_added: int = 0
    lines_removed: int = 0


class AnalysisConfig(BaseModel):
    """Configuration for analysis."""
    max_issues_per_file: int = Field(default=10, ge=1, le=50)
    severity_threshold: Severity = Severity.WARNING
    enabled_checks: List[str] = Field(default_factory=list)


class CodeAnalysisRequest(BaseModel):
    """Request for code analysis."""
    model_config = ConfigDict(extra="forbid")

    analysis_id: UUID = Field(default_factory=uuid4)
    domain: Domain
    files: List[FileInfo]
    pr_context: PRContext
    analysis_config: AnalysisConfig = Field(default_factory=AnalysisConfig)


class Finding(BaseModel):
    """A single code analysis finding."""
    id: UUID = Field(default_factory=uuid4)
    severity: Severity
    category: str
    message: str
    file: str
    line: Optional[int] = None
    column: Optional[int] = None
    end_line: Optional[int] = None
    end_column: Optional[int] = None
    code_snippet: Optional[str] = None
    suggestion: Optional[str] = None
    rule: Optional[str] = None
    documentation: Optional[str] = None


class AnalysisSummary(BaseModel):
    """Summary of analysis results."""
    total_findings: int
    by_category: Dict[str, int] = Field(default_factory=dict)
    by_severity: Dict[str, int] = Field(default_factory=dict)


class AnalysisMetadata(BaseModel):
    """Metadata about the analysis execution."""
    analyzed_files: int
    latency_ms: int
    model_used: str
    tokens_used: int
    mock_response: bool = False


class CodeAnalysisResponse(BaseModel):
    """Response from code analysis."""
    analysis_id: UUID
    domain: Domain
    findings: List[Finding] = Field(default_factory=list)
    summary: AnalysisSummary
    metadata: AnalysisMetadata


class BatchAnalysisTask(BaseModel):
    """A single task in batch analysis."""
    task_id: str
    domain: Domain
    files: List[FileInfo]


class BatchAnalysisRequest(BaseModel):
    """Request for batch analysis."""
    analysis_id: UUID
    tasks: List[BatchAnalysisTask]


class BatchTaskResult(BaseModel):
    """Result of a single batch task."""
    task_id: str
    status: str  # completed, failed
    findings: List[Finding] = Field(default_factory=list)
    error: Optional[str] = None


class BatchAnalysisResponse(BaseModel):
    """Response from batch analysis."""
    analysis_id: UUID
    results: List[BatchTaskResult]
    total_latency_ms: int


class DomainResult(BaseModel):
    """Result from a single domain analysis."""
    domain: Domain
    findings: List[Finding]
    summary: AnalysisSummary


class ConsolidationRequest(BaseModel):
    """Request for report consolidation."""
    analysis_id: UUID
    domain_results: List[DomainResult]
    pr_context: PRContext


class DomainSection(BaseModel):
    """Section of consolidated report for one domain."""
    domain: Domain
    score: int = Field(ge=0, le=100)
    critical_issues: int
    warnings: int
    suggestions: int


class ConsolidatedReport(BaseModel):
    """Consolidated analysis report."""
    overall_score: int = Field(ge=0, le=100)
    recommendation: str  # approve, approve_with_suggestions, request_changes
    summary: str
    sections: List[DomainSection]
    top_issues: List[Finding]


class ConsolidationResponse(BaseModel):
    """Response from consolidation."""
    analysis_id: UUID
    report: ConsolidatedReport
    markdown_comment: str
```

### 3.5 DTOs (C#)

```csharp
// platform-dotnet/src/Application/DTOs/PrAnalyzer/

namespace AtlasOps.Application.DTOs.PrAnalyzer;

public record CreatePrAnalysisRequest(
    Guid AnalysisId,
    string Repository,
    int PrNumber,
    string PrTitle,
    string PrAuthor,
    string HeadSha,
    string BaseSha,
    List<string> Domains,
    int? OverallScore,
    string? Recommendation,
    object? Report,
    long? GitHubCommentId,
    string? CommentUrl
);

public record PrAnalysisDto(
    Guid AnalysisId,
    string Repository,
    int PrNumber,
    string PrTitle,
    string PrAuthor,
    string Status,
    List<string> Domains,
    int? OverallScore,
    string? Recommendation,
    string? CommentUrl,
    DateTime? StartedAt,
    DateTime? CompletedAt,
    DateTime CreatedAt
);

public record CreateFindingRequest(
    Guid AnalysisId,
    string Domain,
    string Severity,
    string Category,
    string Message,
    string FilePath,
    int? LineNumber,
    int? ColumnNumber,
    string? CodeSnippet,
    string? Suggestion,
    string? Rule
);

public record FindingDto(
    Guid FindingId,
    Guid AnalysisId,
    string Domain,
    string Severity,
    string Category,
    string Message,
    string FilePath,
    int? LineNumber,
    int? ColumnNumber,
    string? CodeSnippet,
    string? Suggestion,
    string? Rule,
    DateTime CreatedAt
);

public record PostCommentRequest(
    string Repository,
    int PrNumber,
    string Body,
    Guid AnalysisId
);

public record CommentResponse(
    long CommentId,
    string Url,
    DateTime CreatedAt
);

public record AgentConfigurationDto(
    Guid ConfigId,
    string Domain,
    string AgentName,
    Dictionary<string, object> Settings,
    List<string> EnabledChecks,
    string SeverityThreshold,
    int MaxIssuesPerFile,
    bool IsActive
);
```

---

## 4. Communication Flow

### 4.1 Sequence Diagram - Full PR Analysis Flow

```
                GitHub                Orchestrator           Agent Service         Platform API
                  |                       |                       |                     |
                  |  POST /webhooks/github|                       |                     |
                  |---------------------->|                       |                     |
                  |                       |                       |                     |
                  |                       | Validate signature    |                     |
                  |                       | Check idempotency     |                     |
                  |                       |                       |                     |
                  |  202 Accepted         |                       |                     |
                  |<----------------------|                       |                     |
                  |                       |                       |                     |
                  |                       |=== ASYNC PROCESSING ==|                     |
                  |                       |                       |                     |
                  |                       | GET PR diff from GitHub                     |
                  |<--------------------->|                       |                     |
                  |                       |                       |                     |
                  |                       | Detect domains        |                     |
                  |                       | (.cs -> dotnet,       |                     |
                  |                       |  .py -> python, etc.) |                     |
                  |                       |                       |                     |
                  |                       | Create analysis record|                     |
                  |                       |---------------------------------------------->|
                  |                       |                       |                     |
                  |                       |                       |     201 Created     |
                  |                       |<----------------------------------------------|
                  |                       |                       |                     |
                  |                       |=== PARALLEL ANALYSIS =|                     |
                  |                       |                       |                     |
                  |                       | POST /analyze/batch   |                     |
                  |                       |---------------------->|                     |
                  |                       |                       |                     |
                  |                       |                       | Analyze .NET files  |
                  |                       |                       | (nullable, async,   |
                  |                       |                       |  EF, SOLID)         |
                  |                       |                       |                     |
                  |                       |                       | Analyze Python files|
                  |                       |                       | (type hints, PEP8)  |
                  |                       |                       |                     |
                  |                       |                       | Analyze TS files    |
                  |                       |                       | (types, React)      |
                  |                       |                       |                     |
                  |                       |                       | Generic analysis    |
                  |                       |                       | (complexity, sec)   |
                  |                       |                       |                     |
                  |                       |     200 OK (results)  |                     |
                  |                       |<----------------------|                     |
                  |                       |                       |                     |
                  |                       |=== CONSOLIDATION ====|                     |
                  |                       |                       |                     |
                  |                       | POST /analyze/        |                     |
                  |                       | consolidate           |                     |
                  |                       |---------------------->|                     |
                  |                       |                       |                     |
                  |                       |                       | Merge findings      |
                  |                       |                       | Calculate scores    |
                  |                       |                       | Generate markdown   |
                  |                       |                       |                     |
                  |                       |     200 OK (report)   |                     |
                  |                       |<----------------------|                     |
                  |                       |                       |                     |
                  |                       |=== POST COMMENT ======|                     |
                  |                       |                       |                     |
                  |                       | POST /github/comments |                     |
                  |                       |---------------------------------------------->|
                  |                       |                       |                     |
                  |                       |                       |                     | POST comment
                  |                       |                       |                     | to GitHub
                  |<----------------------------------------------------------------------------|
                  |                       |                       |                     |
                  |                       |                       |   201 Created       |
                  |                       |<----------------------------------------------|
                  |                       |                       |                     |
                  |                       | Update analysis record|                     |
                  |                       | (completed, comment)  |                     |
                  |                       |---------------------------------------------->|
                  |                       |                       |                     |
                  |                       | Store findings        |                     |
                  |                       |---------------------------------------------->|
                  |                       |                       |                     |
```

### 4.2 LangGraph Workflow Definition

```typescript
// orchestrator/src/graph/pr-analyzer-workflow.ts

import { StateGraph, END, START } from '@langchain/langgraph';
import { Annotation } from '@langchain/langgraph';

// State definition
const PRAnalysisStateAnnotation = Annotation.Root({
  // Input
  webhookPayload: Annotation<PRWebhookPayload>(),
  analysisId: Annotation<string>(),

  // Processing state
  prDiff: Annotation<PRDiff | null>({ default: () => null }),
  detectedDomains: Annotation<Domain[]>({ default: () => [] }),
  filesByDomain: Annotation<Map<Domain, FileChange[]>>({ default: () => new Map() }),

  // Analysis results
  domainResults: Annotation<DomainAnalysisResult[]>({ default: () => [] }),
  consolidatedReport: Annotation<ConsolidatedReport | null>({ default: () => null }),

  // Output
  commentPosted: Annotation<boolean>({ default: () => false }),
  commentUrl: Annotation<string | null>({ default: () => null }),

  // Metadata
  errors: Annotation<Error[]>({ default: () => [] }),
  metadata: Annotation<Record<string, unknown>>({ default: () => ({}) }),
});

type PRAnalysisState = typeof PRAnalysisStateAnnotation.State;

// Build workflow
export function buildPRAnalysisWorkflow() {
  const workflow = new StateGraph(PRAnalysisStateAnnotation)
    // Nodes
    .addNode('receive_webhook', receiveWebhook)
    .addNode('extract_diff', extractDiff)
    .addNode('detect_domains', detectDomains)
    .addNode('select_agents', selectAgents)
    .addNode('parallel_analysis', parallelAnalysis)
    .addNode('consolidate_report', consolidateReport)
    .addNode('post_comment', postComment)
    .addNode('handle_error', handleError)

    // Edges
    .addEdge(START, 'receive_webhook')
    .addEdge('receive_webhook', 'extract_diff')
    .addConditionalEdges('extract_diff', shouldContinueAfterDiff, {
      detect_domains: 'detect_domains',
      handle_error: 'handle_error',
    })
    .addEdge('detect_domains', 'select_agents')
    .addConditionalEdges('select_agents', hasAgentsToRun, {
      parallel_analysis: 'parallel_analysis',
      post_comment: 'post_comment', // No analysis needed
    })
    .addEdge('parallel_analysis', 'consolidate_report')
    .addEdge('consolidate_report', 'post_comment')
    .addEdge('post_comment', END)
    .addEdge('handle_error', END);

  return workflow.compile();
}

// Conditional functions
function shouldContinueAfterDiff(state: PRAnalysisState): string {
  if (state.errors.length > 0 || !state.prDiff) {
    return 'handle_error';
  }
  return 'detect_domains';
}

function hasAgentsToRun(state: PRAnalysisState): string {
  if (state.detectedDomains.length === 0) {
    return 'post_comment';
  }
  return 'parallel_analysis';
}
```

---

## 5. Technical Decisions

### ADR-001: Domain Detection Strategy

**Status:** Accepted

**Context:**
We need to automatically detect which programming languages/frameworks are present in a PR to route analysis to appropriate specialized agents.

**Decision:**
Use a multi-layered detection approach:
1. **File extension mapping** (primary): `.cs` -> dotnet, `.py` -> python, `.ts/.tsx` -> typescript
2. **Path patterns** (secondary): `/src/Api/` -> dotnet, `/components/` -> typescript/react
3. **Content analysis** (tertiary): Detect framework-specific imports/using statements

**Implementation:**

```typescript
const DOMAIN_MAPPINGS: DomainMapping[] = [
  {
    domain: 'dotnet',
    extensions: ['.cs', '.csproj', '.sln', '.razor'],
    patterns: [/Controllers\//, /Services\//, /\.Entity\./, /Microsoft\./],
  },
  {
    domain: 'python',
    extensions: ['.py', '.pyi', '.pyx'],
    patterns: [/from\s+\w+\s+import/, /def\s+\w+\(/, /@\w+/],
  },
  {
    domain: 'typescript',
    extensions: ['.ts', '.tsx', '.mts', '.cts'],
    patterns: [/import\s+.*from/, /interface\s+\w+/, /React\./],
  },
];

function detectDomain(file: FileChange): Domain[] {
  const domains: Set<Domain> = new Set();

  // Check extension
  for (const mapping of DOMAIN_MAPPINGS) {
    if (mapping.extensions.some(ext => file.path.endsWith(ext))) {
      domains.add(mapping.domain);
    }
  }

  // Check content patterns if available
  if (file.content) {
    for (const mapping of DOMAIN_MAPPINGS) {
      if (mapping.patterns.some(pattern => pattern.test(file.content!))) {
        domains.add(mapping.domain);
      }
    }
  }

  // Always include generic for all files
  domains.add('generic');

  return Array.from(domains);
}
```

**Consequences:**
- (+) Fast detection without external dependencies
- (+) Extensible for new languages
- (-) May miss edge cases with unusual file structures
- (-) Content analysis requires full file fetch

---

### ADR-002: Parallel vs Sequential Agent Execution

**Status:** Accepted

**Context:**
Multiple domain agents need to analyze different parts of the PR. We need to decide whether to run them sequentially or in parallel.

**Decision:**
Run domain-specific agents **in parallel** with the following constraints:
1. Maximum 4 concurrent agent executions
2. Timeout of 30 seconds per agent
3. Circuit breaker to prevent cascading failures
4. Generic analyzer always runs for all files

**Rationale:**
- PRs typically contain 5-20 files
- Sequential execution would take 4x longer
- LLM calls are I/O bound, not CPU bound
- Independent domain analyses don't share state

**Implementation:**

```typescript
async function parallelAnalysis(state: PRAnalysisState): Promise<Partial<PRAnalysisState>> {
  const tasks = state.detectedDomains.map(domain => ({
    taskId: `${state.analysisId}-${domain}`,
    domain,
    files: state.filesByDomain.get(domain) || [],
  }));

  // Execute in parallel with concurrency limit
  const results = await pLimit(4)(
    tasks.map(task =>
      callAgentService('/analyze/code', {
        analysisId: state.analysisId,
        domain: task.domain,
        files: task.files,
        prContext: state.metadata.prContext,
      })
    )
  );

  return {
    domainResults: results.filter(r => r.status === 'completed'),
    errors: results.filter(r => r.status === 'failed').map(r => new Error(r.error)),
  };
}
```

**Consequences:**
- (+) 4x faster analysis for multi-domain PRs
- (+) Independent failure handling per domain
- (-) Higher resource usage during analysis
- (-) More complex error handling

---

### ADR-003: Report Scoring Algorithm

**Status:** Accepted

**Context:**
We need to calculate an overall score and recommendation for the PR based on findings from multiple domain analyzers.

**Decision:**
Use a weighted scoring system:

```
Overall Score = 100 - (ErrorPenalty + WarningPenalty + InfoPenalty)

Where:
  ErrorPenalty = errors * 15 (capped at 60)
  WarningPenalty = warnings * 5 (capped at 30)
  InfoPenalty = infos * 1 (capped at 10)

Recommendation:
  Score >= 80 AND errors == 0 -> "approve"
  Score >= 60 OR errors <= 2 -> "approve_with_suggestions"
  Score < 60 OR errors > 2 -> "request_changes"
```

**Implementation:**

```python
def calculate_score(findings: List[Finding]) -> Tuple[int, str]:
    errors = sum(1 for f in findings if f.severity == Severity.ERROR)
    warnings = sum(1 for f in findings if f.severity == Severity.WARNING)
    infos = sum(1 for f in findings if f.severity == Severity.INFO)

    error_penalty = min(errors * 15, 60)
    warning_penalty = min(warnings * 5, 30)
    info_penalty = min(infos * 1, 10)

    score = max(0, 100 - error_penalty - warning_penalty - info_penalty)

    if score >= 80 and errors == 0:
        recommendation = "approve"
    elif score >= 60 or errors <= 2:
        recommendation = "approve_with_suggestions"
    else:
        recommendation = "request_changes"

    return score, recommendation
```

**Consequences:**
- (+) Transparent, deterministic scoring
- (+) Severity-weighted appropriately
- (-) May need tuning based on team preferences
- (-) Doesn't account for file/context importance

---

### ADR-004: Webhook Idempotency

**Status:** Accepted

**Context:**
GitHub may send duplicate webhooks for the same event. We need to handle idempotency to avoid duplicate analyses.

**Decision:**
Use GitHub's `X-GitHub-Delivery` header as unique identifier:
1. Store delivery ID in `WebhookDeliveries` table
2. Check for existing delivery before processing
3. Return 200 OK for duplicates (don't reprocess)

**Implementation:**

```typescript
async function receiveWebhook(state: PRAnalysisState): Promise<Partial<PRAnalysisState>> {
  const deliveryId = state.webhookPayload.headers['x-github-delivery'];

  // Check idempotency
  const existing = await redis.get(`webhook:${deliveryId}`);
  if (existing) {
    logger.info({ deliveryId }, 'Duplicate webhook, skipping');
    return { commentPosted: true }; // Skip to end
  }

  // Mark as processing
  await redis.setex(`webhook:${deliveryId}`, 86400, 'processing'); // 24h TTL

  // Store in DB for audit
  await platformApi.post('/api/webhook-deliveries', {
    gitHubDeliveryId: deliveryId,
    event: state.webhookPayload.headers['x-github-event'],
    action: state.webhookPayload.action,
    repository: state.webhookPayload.repository.full_name,
    prNumber: state.webhookPayload.number,
    payload: state.webhookPayload,
  });

  return {
    analysisId: generateUUID(),
    metadata: { deliveryId },
  };
}
```

**Consequences:**
- (+) No duplicate processing
- (+) Fast lookup via Redis
- (+) Full audit trail in PostgreSQL
- (-) Requires Redis availability

---

### ADR-005: GitHub App vs Personal Access Token

**Status:** Accepted

**Context:**
We need to authenticate with GitHub to fetch PR diffs and post comments.

**Decision:**
Use **GitHub App** authentication:
1. Register AtlasOps as a GitHub App
2. Generate installation tokens per repository
3. Cache tokens in Redis (1 hour TTL, token valid for 1 hour)

**Rationale:**
- GitHub Apps have higher rate limits (5000 req/hour vs 5000 req/hour)
- Fine-grained permissions per installation
- No personal account dependency
- Better audit trail

**Implementation:**

```csharp
// Platform API - GitHub Service
public class GitHubAppService : IGitHubService
{
    private readonly IDistributedCache _cache;
    private readonly GitHubAppSettings _settings;

    public async Task<string> GetInstallationToken(long installationId)
    {
        var cacheKey = $"github:token:{installationId}";
        var cached = await _cache.GetStringAsync(cacheKey);

        if (!string.IsNullOrEmpty(cached))
            return cached;

        // Generate JWT from App private key
        var jwt = GenerateAppJwt();

        // Exchange for installation token
        var token = await ExchangeForInstallationToken(jwt, installationId);

        // Cache for 55 minutes (token valid for 1 hour)
        await _cache.SetStringAsync(cacheKey, token,
            new DistributedCacheEntryOptions
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromMinutes(55)
            });

        return token;
    }

    public async Task<string> PostComment(string repo, int prNumber, string body, Guid analysisId)
    {
        var installationId = await GetInstallationId(repo);
        var token = await GetInstallationToken(installationId);

        using var client = new HttpClient();
        client.DefaultRequestHeaders.Authorization =
            new AuthenticationHeaderValue("Bearer", token);
        client.DefaultRequestHeaders.UserAgent.ParseAdd("AtlasOps-PR-Analyzer/1.0");

        var response = await client.PostAsJsonAsync(
            $"https://api.github.com/repos/{repo}/issues/{prNumber}/comments",
            new { body });

        response.EnsureSuccessStatusCode();

        var result = await response.Content.ReadFromJsonAsync<GitHubCommentResponse>();
        return result.HtmlUrl;
    }
}
```

**Consequences:**
- (+) Higher rate limits
- (+) Better security model
- (+) Per-installation permissions
- (-) More complex setup (App registration)
- (-) Requires installation by repo admin

---

## 6. Scalability Considerations

### 6.1 Bottleneck Analysis

| Component | Potential Bottleneck | Mitigation |
|-----------|---------------------|------------|
| **Webhook ingestion** | High volume during peak hours | Queue webhooks in Redis, async processing |
| **GitHub API calls** | Rate limiting (5000/hour) | Token rotation, request batching |
| **LLM API calls** | Cost and latency | Caching, model selection by severity |
| **Agent Service** | CPU-bound LLM tokenization | Horizontal scaling (3-5 replicas) |
| **PostgreSQL writes** | Write contention on findings | Batch inserts, async writes |

### 6.2 Scaling Strategy

```yaml
# Kubernetes HPA configuration
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: agent-service-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: agent-service
  minReplicas: 2
  maxReplicas: 8
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: External
      external:
        metric:
          name: analysis_queue_length
        target:
          type: Value
          value: 10
```

### 6.3 Caching Strategy

```
Redis Cache Structure:
  webhook:{delivery_id} -> "processing" | "completed"  (24h TTL)
  github:token:{installation_id} -> JWT token  (55min TTL)
  analysis:{analysis_id}:status -> JSON status  (1h TTL)
  domain:config:{domain} -> Agent config JSON  (24h TTL)
```

### 6.4 Rate Limiting

```typescript
// Per-repository rate limiting
const rateLimiter = new RateLimiter({
  points: 10,        // 10 analyses
  duration: 3600,    // per hour
  keyPrefix: 'rl:repo:',
});

async function checkRateLimit(repository: string): Promise<boolean> {
  try {
    await rateLimiter.consume(repository);
    return true;
  } catch (error) {
    if (error instanceof RateLimiterRes) {
      logger.warn({ repository, retryAfter: error.msBeforeNext }, 'Rate limited');
      return false;
    }
    throw error;
  }
}
```

---

## 7. Extensibility

### 7.1 Adding New Domain Analyzers

To add support for a new language/framework (e.g., Go):

1. **Add domain mapping** in Orchestrator:
```typescript
// Add to DOMAIN_MAPPINGS
{
  domain: 'go',
  extensions: ['.go', '.mod', '.sum'],
  patterns: [/package\s+\w+/, /func\s+\w+\(/, /import\s+\(/],
}
```

2. **Create analyzer** in Agent Service:
```python
# agents-py/src/agents/go_analyzer.py
class GoAnalyzer(BaseCodeAnalyzer):
    CHECKS = [
        'error_handling',      # Check for unhandled errors
        'nil_checks',          # Nil pointer checks
        'goroutine_leaks',     # Goroutine lifecycle
        'race_conditions',     # Data race potential
        'idioms',              # Go idioms and conventions
    ]

    def get_system_prompt(self) -> str:
        return """You are an expert Go code reviewer..."""
```

3. **Add configuration** in database:
```sql
INSERT INTO "AgentConfigurations" ("Domain", "AgentName", "Settings", "EnabledChecks")
VALUES ('go', 'go-analyzer', '{"model": "claude-3-5-sonnet-20241022"}'::jsonb,
        '["error_handling", "nil_checks", "goroutine_leaks"]'::jsonb);
```

4. **Update domain enum** in all services

### 7.2 Custom Check Rules

Domain analyzers support configurable checks via database:

```json
{
  "domain": "dotnet",
  "enabledChecks": [
    "nullable",
    "async",
    {
      "name": "custom_company_rule",
      "description": "Check for company-specific patterns",
      "prompt": "Verify that all public methods have XML documentation comments",
      "severity": "warning"
    }
  ]
}
```

### 7.3 Webhook Event Types

Currently supported: `pull_request` (opened, synchronize, reopened)

Future extensions:
- `pull_request_review`: Re-analyze after review comments
- `push`: Analyze commits directly
- `issue_comment`: Trigger re-analysis via `/analyze` command

---

## 8. Security Considerations

### 8.1 Webhook Signature Verification

```typescript
import crypto from 'crypto';

function verifyWebhookSignature(
  payload: string,
  signature: string,
  secret: string
): boolean {
  const expected = `sha256=${crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex')}`;

  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expected)
  );
}
```

### 8.2 Sensitive Data Handling

- **Never log** file contents or PR bodies containing secrets
- **Redact** potential secrets in analysis reports
- **Limit** stored diff content to 10KB per file
- **Encrypt** GitHub tokens at rest in Redis

### 8.3 Access Control

```yaml
Permissions required for GitHub App:
  - pull_requests: write  (post comments)
  - contents: read        (read PR diff)
  - metadata: read        (repository info)
```

### 8.4 Audit Trail

All operations are logged to `AuditLogs` table:
- Webhook received
- Analysis started
- Agent execution (without content)
- Comment posted
- Configuration changes

---

## 9. Monitoring and Observability

### 9.1 Key Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `pr_analyses_total` | Counter | Total PRs analyzed |
| `pr_analysis_duration_seconds` | Histogram | End-to-end analysis time |
| `agent_execution_duration_seconds` | Histogram | Per-agent execution time |
| `findings_total` | Counter | Findings by severity/domain |
| `github_api_calls_total` | Counter | GitHub API call count |
| `llm_tokens_used_total` | Counter | LLM token consumption |
| `llm_cost_usd_total` | Counter | Estimated LLM cost |

### 9.2 Alerts

```yaml
# Prometheus alerting rules
groups:
  - name: pr-analyzer
    rules:
      - alert: HighAnalysisFailureRate
        expr: rate(pr_analyses_total{status="failed"}[5m]) / rate(pr_analyses_total[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High PR analysis failure rate ({{ $value | humanizePercentage }})"

      - alert: AnalysisQueueBacklog
        expr: analysis_queue_length > 50
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Analysis queue backlog: {{ $value }} pending"

      - alert: GitHubRateLimitLow
        expr: github_rate_limit_remaining < 500
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "GitHub API rate limit low: {{ $value }} remaining"
```

### 9.3 Distributed Tracing

```typescript
// OpenTelemetry span for analysis
const span = tracer.startSpan('pr_analysis', {
  attributes: {
    'pr.repository': repository,
    'pr.number': prNumber,
    'pr.domains': detectedDomains.join(','),
  },
});

try {
  // Analysis logic
  span.setStatus({ code: SpanStatusCode.OK });
} catch (error) {
  span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
  span.recordException(error);
  throw error;
} finally {
  span.end();
}
```

---

## 10. Implementation Phases

### Phase 1: MVP (Week 1-2)

**Goal:** Basic PR analysis with single domain support

**Deliverables:**
- [ ] Webhook endpoint in Orchestrator
- [ ] Domain detection (extension-based only)
- [ ] Generic analyzer in Agent Service
- [ ] GitHub comment posting via Platform API
- [ ] Basic PostgreSQL persistence

**Success Criteria:**
- Analyze PRs with <20 files
- Post comment within 60 seconds
- Support .NET files only

### Phase 2: Multi-Domain (Week 3-4)

**Goal:** Full multi-domain support with parallel analysis

**Deliverables:**
- [ ] Python, TypeScript analyzers
- [ ] Parallel agent execution
- [ ] Report consolidation
- [ ] Scoring algorithm
- [ ] Redis caching

**Success Criteria:**
- Analyze multi-stack PRs
- <30 second analysis time
- 80%+ accuracy on finding detection

### Phase 3: Production Hardening (Week 5-6)

**Goal:** Production-ready with monitoring

**Deliverables:**
- [ ] GitHub App authentication
- [ ] Webhook signature verification
- [ ] Idempotency handling
- [ ] Rate limiting
- [ ] Prometheus metrics
- [ ] Grafana dashboards

**Success Criteria:**
- Handle 100 PRs/hour
- 99.9% webhook delivery
- <5% failure rate

### Phase 4: Advanced Features (Week 7-8)

**Goal:** Enhanced analysis capabilities

**Deliverables:**
- [ ] Custom check rules
- [ ] Re-analysis on command
- [ ] Analysis history UI
- [ ] Cost optimization (model selection)
- [ ] Batch PR analysis

**Success Criteria:**
- Customizable per-repository
- Cost per analysis <$0.10 average

---

## 11. Open Questions and Trade-offs

### Open Questions

1. **Comment format:** Single comment vs inline comments on specific lines?
   - Single comment is simpler and doesn't spam the PR
   - Inline comments are more actionable but may overwhelm

2. **Re-analysis trigger:** Automatic on PR update vs manual via comment?
   - Automatic ensures always up-to-date
   - Manual saves costs for WIP PRs

3. **Private repository support:** How to handle organizations without GitHub App installed?
   - Fallback to PAT?
   - Require App installation?

4. **Large PRs:** How to handle PRs with 100+ files?
   - Sample files by importance?
   - Split into multiple analyses?
   - Warn user about limitations?

### Trade-offs Accepted

| Decision | Trade-off |
|----------|-----------|
| Parallel agent execution | Higher resource usage for faster analysis |
| GitHub App authentication | More complex setup for better security |
| Single consolidated comment | Less granular feedback for cleaner PR experience |
| Redis for idempotency | External dependency for simpler state management |
| LLM-based analysis | Higher cost for more intelligent findings |

---

## 12. References

### Internal Documents
- [ARCHITECTURE_REVIEW.md](./ARCHITECTURE_REVIEW.md) - Overall platform architecture
- [DATABASE_DESIGN.md](./DATABASE_DESIGN.md) - Database schema design
- [INFRASTRUCTURE.md](./INFRASTRUCTURE.md) - Infrastructure setup

### External Resources
- [GitHub Webhooks Documentation](https://docs.github.com/en/webhooks)
- [GitHub Apps Documentation](https://docs.github.com/en/apps)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [OpenTelemetry Best Practices](https://opentelemetry.io/docs/best-practices/)

---

## Appendix A: Markdown Comment Template

```markdown
## AtlasOps PR Analysis Report

**PR:** #{{prNumber}} - {{prTitle}}
**Author:** @{{prAuthor}}
**Analyzed:** {{timestamp}}

### Overall Assessment

| Metric | Value |
|--------|-------|
| **Score** | {{overallScore}}/100 |
| **Recommendation** | {{recommendation}} |
| **Files Analyzed** | {{filesAnalyzed}} |
| **Domains Detected** | {{domains}} |

### Summary

{{summary}}

### Findings by Domain

{{#each domainSections}}
#### {{domain}} (Score: {{score}}/100)

{{#if criticalIssues}}
**Critical Issues ({{criticalIssues}}):**
{{#each criticalFindings}}
- **{{file}}:{{line}}** - {{message}}
  ```{{language}}
  {{codeSnippet}}
  ```
  > Suggestion: {{suggestion}}
{{/each}}
{{/if}}

{{#if warnings}}
**Warnings ({{warnings}}):**
{{#each warningFindings}}
- **{{file}}:{{line}}** - {{message}}
{{/each}}
{{/if}}

{{#if suggestions}}
<details>
<summary>Suggestions ({{suggestions}})</summary>

{{#each suggestionFindings}}
- **{{file}}:{{line}}** - {{message}}
{{/each}}
</details>
{{/if}}

{{/each}}

---

*Generated by [AtlasOps PR Analyzer](https://atlasops.dev) | Analysis ID: `{{analysisId}}`*
```

---

**Document Status:** DESIGN PHASE
**Last Updated:** 2026-01-26
**Next Review:** After Phase 1 completion
**Owner:** Software Architect
