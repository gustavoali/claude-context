# Stack Detection Rules & Auto-Discovery Algorithm

**Project:** Project Admin
**Version:** 1.0
**Date:** 2026-02-13
**Author:** Data Correlation Analyst (matching-specialist)

---

## 1. Stack Detection Rules

### 1.1 Primary Detection Rules (Core Technologies)

Detection rules are organized by priority (weight). Higher priority rules are evaluated first.

| File/Pattern | Technology Detected | Priority | Confidence | Notes |
|--------------|-------------------|----------|-----------|-------|
| `pubspec.yaml` | flutter, dart | 10 | 1.0 | Flutter projects always have pubspec |
| `*.csproj` | dotnet | 10 | 1.0 | .NET project file |
| `*.sln` | dotnet | 9 | 0.95 | Solution file, may contain multiple projects |
| `package.json` | node | 8 | 0.95 | Node.js/npm project |
| `Cargo.toml` | rust | 10 | 1.0 | Rust project manifest |
| `go.mod` | go | 10 | 1.0 | Go module file |
| `requirements.txt` | python | 7 | 0.85 | Python dependencies (pip) |
| `pyproject.toml` | python | 8 | 0.95 | Modern Python project config |
| `Pipfile` | python | 8 | 0.90 | Python pipenv |
| `pom.xml` | java, maven | 9 | 0.95 | Maven project |
| `build.gradle` | java, gradle | 9 | 0.95 | Gradle project |
| `Package.swift` | swift | 10 | 1.0 | Swift package |
| `Gemfile` | ruby | 9 | 0.95 | Ruby bundler |
| `composer.json` | php | 9 | 0.95 | PHP composer |

### 1.2 Framework Detection Rules (Additive)

These rules ADD technologies to the stack when found in combination with base technologies.

| File/Pattern | Base Tech Required | Framework/Tool Added | Priority | Confidence |
|--------------|-------------------|---------------------|----------|-----------|
| `angular.json` | node | angular | 8 | 1.0 |
| `next.config.js` or `next.config.mjs` | node | nextjs | 8 | 1.0 |
| `nuxt.config.js` or `nuxt.config.ts` | node | nuxtjs | 8 | 1.0 |
| `svelte.config.js` | node | svelte | 8 | 1.0 |
| `vite.config.js` or `vite.config.ts` | node | vite | 7 | 0.95 |
| `webpack.config.js` | node | webpack | 6 | 0.90 |
| `tsconfig.json` | node | typescript | 7 | 0.95 |
| `nest-cli.json` | node | nestjs | 8 | 1.0 |
| `gatsby-config.js` | node | gatsby | 8 | 1.0 |
| `electron-builder.yml` or `electron-builder.json` | node | electron | 8 | 1.0 |
| `Dockerfile` | (any) | docker | 6 | 0.95 |
| `docker-compose.yml` or `docker-compose.yaml` | (any) | docker-compose | 7 | 0.95 |
| `*.ipynb` (any .ipynb file) | python | jupyter | 7 | 1.0 |
| `manage.py` | python | django | 8 | 0.95 |
| `flask_app.py` or imports flask | python | flask | 7 | 0.85 |
| `fastapi` in requirements.txt/pyproject.toml | python | fastapi | 8 | 0.95 |
| `alembic.ini` | python | alembic | 7 | 0.95 |
| `.env` or `.env.example` | (any) | env-config | 5 | 0.80 |

### 1.3 Package.json Deep Inspection Rules

When `package.json` is found, inspect dependencies for additional technologies:

| Dependency Pattern | Technology Added | Priority | Confidence |
|-------------------|------------------|----------|-----------|
| `"@modelcontextprotocol/sdk"` | mcp | 9 | 1.0 |
| `"fastify"` or `"@fastify/*"` | fastify | 8 | 1.0 |
| `"express"` | express | 8 | 1.0 |
| `"react"` or `"react-dom"` | react | 8 | 1.0 |
| `"vue"` | vue | 8 | 1.0 |
| `"@angular/core"` | angular | 8 | 1.0 |
| `"playwright"` | playwright | 7 | 1.0 |
| `"puppeteer"` | puppeteer | 7 | 1.0 |
| `"socket.io"` | websocket | 7 | 0.95 |
| `"ws"` | websocket | 7 | 0.95 |
| `"pg"` | postgresql | 7 | 0.95 |
| `"mysql"` or `"mysql2"` | mysql | 7 | 0.95 |
| `"mongodb"` or `"mongoose"` | mongodb | 7 | 0.95 |
| `"sqlite3"` or `"better-sqlite3"` | sqlite | 7 | 0.95 |
| `"redis"` | redis | 7 | 0.95 |
| `"zod"` | zod | 6 | 0.90 |
| `"jest"` | jest | 6 | 0.90 |
| `"vitest"` | vitest | 6 | 0.90 |

### 1.4 Pubspec.yaml Deep Inspection Rules

When `pubspec.yaml` is found, inspect dependencies:

| Dependency Pattern | Technology Added | Priority | Confidence |
|-------------------|------------------|----------|-----------|
| `flutter_bloc:` or `bloc:` | flutter_bloc | 7 | 1.0 |
| `riverpod:` or `flutter_riverpod:` | riverpod | 7 | 1.0 |
| `provider:` | provider | 7 | 1.0 |
| `get:` | getx | 7 | 0.95 |
| `sqflite:` or `sqflite_common:` | sqflite | 7 | 1.0 |
| `drift:` or `moor:` | drift | 7 | 1.0 |
| `hive:` or `hive_flutter:` | hive | 7 | 1.0 |
| `dio:` | dio | 7 | 1.0 |
| `http:` | http | 6 | 0.95 |
| `flutter_map:` | flutter_map | 7 | 1.0 |
| `geolocator:` | geolocator | 7 | 0.95 |

### 1.5 Chrome Extension Detection

| File/Pattern | Technology Added | Priority | Confidence |
|--------------|------------------|----------|-----------|
| `manifest.json` (with `"manifest_version": 3`) | chrome-extension-mv3 | 9 | 1.0 |
| `manifest.json` (with `"manifest_version": 2`) | chrome-extension-mv2 | 9 | 1.0 |

### 1.6 Database Detection (Environment Files)

When `.env` or `.env.example` is found, parse for database connection strings:

| Pattern in .env | Technology Added | Confidence |
|----------------|------------------|-----------|
| `DATABASE_URL=postgresql://...` | postgresql | 0.95 |
| `DATABASE_URL=mysql://...` | mysql | 0.95 |
| `DATABASE_URL=mongodb://...` | mongodb | 0.95 |
| `REDIS_URL=...` or `REDIS_HOST=...` | redis | 0.90 |
| `.db` file path in any env var | sqlite | 0.80 |

### 1.7 State Machine Detection

When `node_modules/` exists alongside `package.json`, mark as "installed". This can be used in health checks.

---

## 2. Auto-Discovery Algorithm

### 2.1 High-Level Flow

```
scanDirectory(rootDir, options)
  ├─► Validate input (path exists, is directory)
  ├─► Initialize scan context
  ├─► Walk directory tree recursively
  │   ├─► For each directory:
  │   │   ├─► Check exclusion rules
  │   │   ├─► Detect if it's a project root
  │   │   ├─► If project: extract metadata
  │   │   └─► If not excluded: recurse into subdirs
  │   └─► Return list of detected projects
  ├─► Reconcile with existing projects in DB
  └─► Return scan results
```

### 2.2 Pseudocode

```javascript
/**
 * Main scan function
 * @param {string} rootDirectory - Absolute path to scan (e.g., "C:/mcp/")
 * @param {object} options - Scan options
 * @returns {object} Scan results with projects found
 */
async function scanDirectory(rootDirectory, options = {}) {
  // Default options
  const config = {
    maxDepth: options.maxDepth || 3,
    followSymlinks: options.followSymlinks || false,
    detectWorktrees: options.detectWorktrees || true,
    deepInspection: options.deepInspection || true, // Parse package.json, etc.
    ...options
  };

  // Validate input
  if (!await fs.exists(rootDirectory)) {
    throw new Error(`Directory does not exist: ${rootDirectory}`);
  }

  // Initialize scan context
  const context = {
    startTime: Date.now(),
    rootDirectory,
    projectsFound: [],
    errors: [],
    directoriesScanned: 0,
    directoriesSkipped: 0
  };

  // Walk the tree
  await walkDirectory(rootDirectory, 0, config, context);

  // Return results
  return {
    rootDirectory,
    projectsFound: context.projectsFound,
    stats: {
      totalProjects: context.projectsFound.length,
      directoriesScanned: context.directoriesScanned,
      directoriesSkipped: context.directoriesSkipped,
      errors: context.errors,
      durationMs: Date.now() - context.startTime
    }
  };
}

/**
 * Recursive directory walker
 */
async function walkDirectory(dirPath, currentDepth, config, context) {
  // Stop if max depth reached
  if (currentDepth > config.maxDepth) {
    context.directoriesSkipped++;
    return;
  }

  // Check if directory should be excluded
  if (shouldExcludeDirectory(dirPath)) {
    context.directoriesSkipped++;
    return;
  }

  context.directoriesScanned++;

  // Check if this directory is a project root
  const projectDetection = await detectProject(dirPath, config);

  if (projectDetection.isProject) {
    // Extract full project metadata
    const projectData = await extractProjectMetadata(dirPath, projectDetection, config);
    context.projectsFound.push(projectData);

    // Don't recurse into project subdirectories (avoid detecting nested projects)
    // EXCEPTION: If detectWorktrees is true, scan for worktrees
    if (config.detectWorktrees) {
      await scanForWorktrees(dirPath, config, context);
    }
    return;
  }

  // Not a project, recurse into subdirectories
  try {
    const entries = await fs.readdir(dirPath, { withFileTypes: true });

    for (const entry of entries) {
      if (entry.isDirectory()) {
        const subPath = path.join(dirPath, entry.name);
        await walkDirectory(subPath, currentDepth + 1, config, context);
      }
    }
  } catch (error) {
    context.errors.push({
      directory: dirPath,
      error: error.message
    });
  }
}

/**
 * Determine if a directory should be excluded from scanning
 */
function shouldExcludeDirectory(dirPath) {
  const dirName = path.basename(dirPath);

  // Exclusion patterns (exact match)
  const excludedDirs = [
    'node_modules',
    '.git',
    'dist',
    'build',
    'out',
    'target',
    'vendor',
    '.venv',
    'venv',
    '__pycache__',
    '.pytest_cache',
    '.next',
    '.nuxt',
    '.output',
    'coverage',
    '.idea',
    '.vscode',
    '.DS_Store',
    'Pods',
    'DerivedData',
    '.dart_tool',
    '.pub-cache',
    'android/build',
    'ios/build',
    'windows/build',
    'linux/build',
    'macos/build'
  ];

  return excludedDirs.includes(dirName);
}

/**
 * Detect if a directory is a project root
 * @returns {object} { isProject: boolean, indicators: string[] }
 */
async function detectProject(dirPath, config) {
  const indicators = [];
  let isProject = false;

  // Primary indicators (strong signals)
  const primaryFiles = [
    'package.json',
    'pubspec.yaml',
    'Cargo.toml',
    'go.mod',
    'pom.xml',
    'build.gradle',
    'Package.swift',
    'Gemfile',
    'composer.json'
  ];

  // Secondary indicators (.NET, Python)
  const secondaryPatterns = [
    { pattern: '*.csproj', indicator: 'dotnet' },
    { pattern: '*.sln', indicator: 'dotnet' },
    { pattern: 'requirements.txt', indicator: 'python' },
    { pattern: 'pyproject.toml', indicator: 'python' }
  ];

  // Check primary files
  for (const file of primaryFiles) {
    if (await fs.exists(path.join(dirPath, file))) {
      indicators.push(file);
      isProject = true;
    }
  }

  // Check secondary patterns
  if (!isProject) {
    for (const { pattern, indicator } of secondaryPatterns) {
      const matches = await glob(pattern, { cwd: dirPath });
      if (matches.length > 0) {
        indicators.push(indicator);
        isProject = true;
        break; // One match is enough
      }
    }
  }

  // Additional check: .git directory (Git repository)
  // Note: This alone doesn't make it a project, but combined with other indicators
  const hasGit = await fs.exists(path.join(dirPath, '.git'));
  if (hasGit) {
    indicators.push('git');
  }

  return { isProject, indicators };
}

/**
 * Extract full project metadata
 */
async function extractProjectMetadata(dirPath, detection, config) {
  const metadata = {
    path: dirPath,
    name: path.basename(dirPath),
    slug: generateSlug(path.basename(dirPath)),
    detectionMethod: 'auto-scan',
    indicators: detection.indicators,
    stack: [],
    category: null,
    hasGit: false,
    packageManagers: []
  };

  // Detect stack technologies
  metadata.stack = await detectStack(dirPath, config);

  // Infer category from stack
  metadata.category = inferCategory(metadata.stack, dirPath);

  // Check Git
  const gitInfo = await checkGitRepository(dirPath);
  metadata.hasGit = gitInfo.hasGit;
  if (gitInfo.hasGit) {
    metadata.gitBranch = gitInfo.branch;
    metadata.gitRemote = gitInfo.remote;
  }

  // Detect package managers
  metadata.packageManagers = await detectPackageManagers(dirPath);

  return metadata;
}

/**
 * Detect stack technologies based on files present
 */
async function detectStack(dirPath, config) {
  const detectedTech = new Map(); // Tech name -> { priority, confidence }

  // Apply primary detection rules (Section 1.1)
  for (const rule of PRIMARY_DETECTION_RULES) {
    if (await fs.exists(path.join(dirPath, rule.file))) {
      for (const tech of rule.technologies) {
        updateDetectedTech(detectedTech, tech, rule.priority, rule.confidence);
      }
    }
  }

  // Apply framework detection rules (Section 1.2)
  for (const rule of FRAMEWORK_DETECTION_RULES) {
    // Check if base tech is already detected
    if (rule.baseTechRequired && !detectedTech.has(rule.baseTechRequired)) {
      continue;
    }

    if (await fs.exists(path.join(dirPath, rule.file))) {
      updateDetectedTech(detectedTech, rule.technology, rule.priority, rule.confidence);
    }
  }

  // Deep inspection if enabled
  if (config.deepInspection) {
    // Inspect package.json
    if (await fs.exists(path.join(dirPath, 'package.json'))) {
      const packageData = await readJSON(path.join(dirPath, 'package.json'));
      const packageTech = await inspectPackageJson(packageData);
      for (const [tech, { priority, confidence }] of packageTech) {
        updateDetectedTech(detectedTech, tech, priority, confidence);
      }
    }

    // Inspect pubspec.yaml
    if (await fs.exists(path.join(dirPath, 'pubspec.yaml'))) {
      const pubspecData = await readYAML(path.join(dirPath, 'pubspec.yaml'));
      const pubspecTech = await inspectPubspec(pubspecData);
      for (const [tech, { priority, confidence }] of pubspecTech) {
        updateDetectedTech(detectedTech, tech, priority, confidence);
      }
    }

    // Inspect .env files for database connections
    const envFiles = ['.env', '.env.example', '.env.local'];
    for (const envFile of envFiles) {
      if (await fs.exists(path.join(dirPath, envFile))) {
        const envTech = await inspectEnvFile(path.join(dirPath, envFile));
        for (const [tech, { priority, confidence }] of envTech) {
          updateDetectedTech(detectedTech, tech, priority, confidence);
        }
        break; // Only inspect one .env file
      }
    }
  }

  // Sort by priority (descending) and return tech names
  const sortedTech = Array.from(detectedTech.entries())
    .sort((a, b) => b[1].priority - a[1].priority)
    .map(([tech, _]) => tech);

  return sortedTech;
}

/**
 * Helper to update detected tech map
 */
function updateDetectedTech(map, tech, priority, confidence) {
  if (!map.has(tech) || map.get(tech).priority < priority) {
    map.set(tech, { priority, confidence });
  }
}

/**
 * Inspect package.json dependencies
 */
async function inspectPackageJson(packageData) {
  const detectedTech = new Map();

  const allDeps = {
    ...packageData.dependencies,
    ...packageData.devDependencies
  };

  for (const [dep, version] of Object.entries(allDeps)) {
    // Apply package.json rules from Section 1.3
    const rule = PACKAGE_JSON_RULES.find(r =>
      dep.includes(r.dependencyPattern) || dep === r.dependencyPattern
    );

    if (rule) {
      updateDetectedTech(detectedTech, rule.technology, rule.priority, rule.confidence);
    }
  }

  return detectedTech;
}

/**
 * Inspect pubspec.yaml dependencies
 */
async function inspectPubspec(pubspecData) {
  const detectedTech = new Map();

  const allDeps = {
    ...pubspecData.dependencies,
    ...pubspecData.dev_dependencies
  };

  for (const dep of Object.keys(allDeps)) {
    // Apply pubspec rules from Section 1.4
    const rule = PUBSPEC_RULES.find(r => dep === r.dependencyPattern.replace(':', ''));

    if (rule) {
      updateDetectedTech(detectedTech, rule.technology, rule.priority, rule.confidence);
    }
  }

  return detectedTech;
}

/**
 * Inspect .env file for database URLs
 */
async function inspectEnvFile(envPath) {
  const detectedTech = new Map();
  const content = await fs.readFile(envPath, 'utf8');

  // Apply .env rules from Section 1.6
  const rules = [
    { pattern: /DATABASE_URL=postgresql:\/\//, tech: 'postgresql', priority: 7, confidence: 0.95 },
    { pattern: /DATABASE_URL=mysql:\/\//, tech: 'mysql', priority: 7, confidence: 0.95 },
    { pattern: /DATABASE_URL=mongodb:\/\//, tech: 'mongodb', priority: 7, confidence: 0.95 },
    { pattern: /REDIS_(URL|HOST)=/, tech: 'redis', priority: 6, confidence: 0.90 },
    { pattern: /\.db/, tech: 'sqlite', priority: 5, confidence: 0.80 }
  ];

  for (const rule of rules) {
    if (rule.pattern.test(content)) {
      updateDetectedTech(detectedTech, rule.tech, rule.priority, rule.confidence);
    }
  }

  return detectedTech;
}

/**
 * Infer project category from stack
 */
function inferCategory(stack, dirPath) {
  // Category inference rules
  const path = dirPath.toLowerCase();

  // Explicit path-based categories
  if (path.includes('/mcp/') || path.includes('\\mcp\\')) {
    return 'mcp';
  }
  if (path.includes('/mobile/') || path.includes('\\mobile\\')) {
    return 'mobile';
  }
  if (path.includes('/apps/') || path.includes('\\apps\\')) {
    return 'app';
  }
  if (path.includes('/agents/') || path.includes('\\agents\\')) {
    return 'agent';
  }

  // Stack-based inference
  if (stack.includes('flutter') || stack.includes('dart')) {
    return 'mobile';
  }
  if (stack.includes('mcp')) {
    return 'mcp';
  }
  if (stack.includes('chrome-extension-mv3') || stack.includes('chrome-extension-mv2')) {
    return 'browser-extension';
  }
  if (stack.includes('electron')) {
    return 'desktop';
  }
  if (stack.includes('angular') || stack.includes('react') || stack.includes('vue')) {
    return 'web';
  }
  if (stack.includes('fastapi') || stack.includes('django') || stack.includes('express') || stack.includes('fastify')) {
    return 'backend';
  }
  if (stack.includes('jupyter')) {
    return 'notebook';
  }

  // Default
  return 'other';
}

/**
 * Check if directory is a Git repository
 */
async function checkGitRepository(dirPath) {
  try {
    const hasGit = await fs.exists(path.join(dirPath, '.git'));
    if (!hasGit) {
      return { hasGit: false };
    }

    // Get current branch
    const branchResult = await execCommand('git rev-parse --abbrev-ref HEAD', { cwd: dirPath });
    const branch = branchResult.stdout.trim();

    // Get remote URL
    let remote = null;
    try {
      const remoteResult = await execCommand('git remote get-url origin', { cwd: dirPath });
      remote = remoteResult.stdout.trim();
    } catch {
      // No remote configured
    }

    return { hasGit: true, branch, remote };
  } catch (error) {
    return { hasGit: false };
  }
}

/**
 * Detect package managers present
 */
async function detectPackageManagers(dirPath) {
  const managers = [];

  if (await fs.exists(path.join(dirPath, 'package-lock.json'))) {
    managers.push('npm');
  }
  if (await fs.exists(path.join(dirPath, 'yarn.lock'))) {
    managers.push('yarn');
  }
  if (await fs.exists(path.join(dirPath, 'pnpm-lock.yaml'))) {
    managers.push('pnpm');
  }
  if (await fs.exists(path.join(dirPath, 'pubspec.lock'))) {
    managers.push('pub');
  }
  if (await fs.exists(path.join(dirPath, 'Cargo.lock'))) {
    managers.push('cargo');
  }
  if (await fs.exists(path.join(dirPath, 'Pipfile.lock'))) {
    managers.push('pipenv');
  }
  if (await fs.exists(path.join(dirPath, 'poetry.lock'))) {
    managers.push('poetry');
  }
  if (await fs.exists(path.join(dirPath, 'Gemfile.lock'))) {
    managers.push('bundler');
  }

  return managers;
}

/**
 * Generate slug from project name
 */
function generateSlug(name) {
  return name
    .toLowerCase()
    .replace(/[^a-z0-9-_]/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');
}

/**
 * Scan for worktrees in the current directory
 */
async function scanForWorktrees(projectPath, config, context) {
  // Worktrees are detected by:
  // 1. Same parent directory as the main project
  // 2. Directory name pattern: <project>-<suffix>
  // 3. .git file (not directory) pointing to the main .git

  const parentDir = path.dirname(projectPath);
  const projectName = path.basename(projectPath);

  try {
    const entries = await fs.readdir(parentDir, { withFileTypes: true });

    for (const entry of entries) {
      if (!entry.isDirectory()) continue;

      const entryName = entry.name;

      // Check if it matches worktree pattern
      if (entryName.startsWith(projectName + '-')) {
        const worktreePath = path.join(parentDir, entryName);

        // Check if .git is a file (worktree) instead of directory
        const gitPath = path.join(worktreePath, '.git');
        if (await fs.exists(gitPath)) {
          const gitStats = await fs.stat(gitPath);
          if (gitStats.isFile()) {
            // This is a worktree
            const worktreeDetection = await detectProject(worktreePath, config);
            if (worktreeDetection.isProject) {
              const worktreeData = await extractProjectMetadata(worktreePath, worktreeDetection, config);
              worktreeData.isWorktree = true;
              worktreeData.mainProject = projectPath;
              context.projectsFound.push(worktreeData);
            }
          }
        }
      }
    }
  } catch (error) {
    context.errors.push({
      directory: projectPath,
      operation: 'scanForWorktrees',
      error: error.message
    });
  }
}
```

---

## 3. Relationship Detection Heuristics

### 3.1 Worktree Relationships

**Detection criteria:**
- Directory name pattern: `<main-project>-<suffix>` (e.g., `linkedin-LTE-001`)
- `.git` is a file (not directory) containing `gitdir:` reference
- Located in same parent directory as main project

**Relationship created:**
- Type: `worktree_of`
- Source: Worktree project
- Target: Main project
- Description: Auto-detected worktree

### 3.2 Dependency Relationships

**Detection criteria (Node.js):**
- `package.json` contains local file dependency: `"mylib": "file:../other-project"`
- Both projects exist in the scan results

**Relationship created:**
- Type: `depends_on`
- Source: Project with dependency
- Target: Project being depended on
- Description: Auto-detected local dependency

### 3.3 Replacement Relationships

**Detection criteria:**
- Project README contains "deprecated" or "replaced by"
- String matching to find replacement project name

**Relationship created:**
- Type: `replaced_by`
- Source: Deprecated project
- Target: Replacement project
- Description: Auto-detected from README

**Implementation note:** This requires parsing README files, which should be done carefully to avoid false positives.

### 3.4 Monorepo Relationships

**Detection criteria:**
- Parent directory contains multiple projects
- Parent directory has its own `package.json` with `"workspaces"` field
- Or `lerna.json` present

**Relationship created:**
- Type: `part_of_monorepo`
- Source: Child project
- Target: Monorepo root
- Description: Auto-detected monorepo structure

---

## 4. Reconciliation with Existing Projects

### 4.1 Matching Strategy

When scan results are reconciled with existing database records:

**Primary matching (exact):**
1. Match by `path` (exact match, case-insensitive on Windows)
2. If match found: UPDATE existing record

**Secondary matching (fuzzy):**
1. If no path match, try matching by `slug`
2. If slug matches but path differs:
   - Confidence score: Medium (0.7)
   - Action: Log as potential match, require manual confirmation
   - Reason: Project may have been moved

**No match:**
1. If neither path nor slug match:
   - Action: Mark as NEW project
   - Insert into database with `source: 'auto_scan'`

### 4.2 Update Strategy

For matched projects (by path):

**Always update:**
- `stack` (re-detect to catch changes)
- `last_scanned_at` timestamp
- `health.lastScanResult`

**Conditionally update (only if different):**
- `name` (if changed on filesystem)
- `category` (if inference rules changed)
- `hasGit`, `gitBranch`, `gitRemote`

**Never update (preserve manual edits):**
- `description` (manually curated)
- `status` (manually set: active/archived/deprecated)
- `config` (manually configured)
- Custom `project_metadata` entries with `source: 'manual'`

### 4.3 Handling Deleted Projects

**Detection:**
- Existing project in DB has `path` that no longer exists on filesystem

**Action options:**
1. **Mark as missing:** Set `status = 'missing'`, add `last_seen_at` timestamp
2. **Archive:** Set `status = 'archived'` after N days missing
3. **Delete:** Remove from DB (only if explicitly requested by user)

**Default:** Option 1 (mark as missing). User can manually archive/delete.

---

## 5. Validation Against Real Inventory

### 5.1 Test Cases from PROJECT_INVENTORY.md

The algorithm should correctly detect these 26 projects:

| # | Project | Path | Expected Stack (subset) | Notes |
|---|---------|------|----------------------|-------|
| 1 | atlasOps | `C:/agents/atlasOps` | node, python, dotnet, postgresql, redis | Multi-language project |
| 8 | mew-michis | `C:/apps/mew-michis` | flutter, dart, sqlite | Main project |
| 8a | mew-michis worktree | `C:/apps/mew-michis-*` | flutter, dart | Worktree (if exists) |
| 12 | linkedin | `C:/mcp/linkedin` | node, sqlite, chrome-extension-mv3, playwright | Main project |
| 12a | linkedin-LTE-001 | `C:/mcp/linkedin-LTE-001` | node, chrome-extension-mv3 | Worktree |
| 14 | sprint-backlog-manager | `C:/mcp/sprint-backlog-manager` | node, postgresql, mcp | MCP server |
| 17 | agenda | `C:/mobile/agenda` | flutter, dart, flutter_bloc, hive | State management + local DB |
| 19 | recetario | `C:/mobile/recetario` | flutter, dart, riverpod, drift, sqlite | Different state management |

### 5.2 Edge Cases to Handle

**Case 1: YouTube Jupyter (no package.json/pubspec.yaml)**
- Path: `C:/agents/youtube_jupyter`
- Has: `.ipynb` files
- Expected: Detect via `*.ipynb` pattern → `python, jupyter`

**Case 2: Projects with only documentation**
- Path: `C:/mcp/youtube` (empty on disk, only claude_context exists)
- Expected: NOT detected (no code on filesystem)

**Case 3: Deprecated project (Sprint Tracker)**
- Path: `C:/mcp/sprint-tracker`
- Expected: Detect as `node, cli`, status manual = 'deprecated'

**Case 4: Multi-language project (AtlasOps)**
- Path: `C:/agents/atlasOps`
- Has: `package.json` (TypeScript), `requirements.txt` (Python), `*.csproj` (.NET)
- Expected: All three detected in stack

**Case 5: Flutter with multiple state management options**
- Agenda: flutter_bloc
- Recetario: riverpod
- Expected: Both detect flutter + their specific state management library

### 5.3 Performance Validation

**Target performance (from SEED_DOCUMENT.md):**
- Scan completo del filesystem: < 10s
- 26 proyectos, 4 directorios

**Optimization strategies:**
1. **Parallel scanning:** Scan top-level directories in parallel
2. **Early exit:** Don't recurse into detected projects (except worktree scan)
3. **Lazy Git checks:** Only run `git` commands if `.git` exists
4. **Cache file reads:** Read `package.json` only once, use for multiple rules
5. **Exclude aggressively:** Skip node_modules, .git, build dirs immediately

---

## 6. Implementation Notes for scan-service.js

### 6.1 Error Handling

```javascript
// Graceful degradation
try {
  const stack = await detectStack(dirPath, config);
} catch (error) {
  // Log error but continue scan
  context.errors.push({ directory: dirPath, operation: 'detectStack', error: error.message });
  stack = []; // Empty stack, mark as unknown
}
```

### 6.2 Configuration Options

```javascript
const DEFAULT_SCAN_CONFIG = {
  maxDepth: 3,                  // Stop recursing after 3 levels
  followSymlinks: false,        // Don't follow symlinks (avoid cycles)
  detectWorktrees: true,        // Scan for git worktrees
  deepInspection: true,         // Parse package.json, pubspec.yaml
  parallelScans: true,          // Scan top-level dirs in parallel
  excludeDirs: [...],           // Custom exclusions
  gitTimeout: 2000,             // Timeout for git commands (ms)
  cacheResults: true,           // Cache scan results in memory
  cacheTTL: 300000              // Cache TTL: 5 minutes
};
```

### 6.3 Caching Strategy

```javascript
// In-memory cache for scan results
const scanCache = new Map(); // key: dirPath, value: { timestamp, result }

async function getCachedScan(dirPath) {
  const cached = scanCache.get(dirPath);
  if (cached && (Date.now() - cached.timestamp) < CACHE_TTL) {
    return cached.result;
  }
  return null;
}

function cacheScanResult(dirPath, result) {
  scanCache.set(dirPath, { timestamp: Date.now(), result });
}
```

### 6.4 Progress Reporting

For long scans, report progress:

```javascript
// Optional callback for progress
async function scanDirectory(rootDir, options, onProgress) {
  // ...
  if (onProgress) {
    onProgress({
      phase: 'scanning',
      directory: currentDir,
      projectsFound: context.projectsFound.length,
      directoriesScanned: context.directoriesScanned
    });
  }
}
```

---

## 7. Future Enhancements

### 7.1 Machine Learning-Based Detection

For projects with ambiguous indicators:
- Train a classifier on known projects
- Features: file count by extension, directory structure, keyword frequency
- Fallback to rule-based detection if confidence < threshold

### 7.2 Cloud Repository Detection

Extend to detect projects in cloud repositories:
- GitHub org/user repositories (via GitHub API)
- GitLab groups (via GitLab API)
- Bitbucket workspaces

### 7.3 Semantic Similarity for Relationships

Use NLP to detect relationships by analyzing README files:
- Extract project names mentioned
- Detect phrases like "uses", "replaces", "integrates with"
- Build relationship graph automatically

---

**Document created:** 2026-02-13
**Related documents:** SEED_DOCUMENT.md, TEAM_PLANNING.md, PROJECT_INVENTORY.md
