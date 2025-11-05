Template: Continuación de Proyecto Existente
De Proyecto A Medio Terminar a Producto Completo
Objetivo: Evaluar, planificar y completar un proyecto de software existente usando los 11 agentes especializados de Claude Code.

Tabla de Contenidos

Fase 0: Discovery & Assessment
Fase 1: Planning & Prioritization
Fase 2: Stabilization
Fase 3: Completion
Fase 4: Quality & Testing
Fase 5: Launch Preparation
Fase 6: Production & Handover


FASE 0: Discovery & Assessment
Duración: 1-2 semanas
Objetivo: Entender el estado actual del proyecto
Paso 0.1: Evaluación Técnica Inicial
Comandos:
bash# Arquitecto evalúa arquitectura existente
Use the software-architect sub-agent to analyze the current 
project architecture. Review:
- Codebase structure (folders, modules, layers)
- Technology stack (frameworks, libraries, versions)
- Architecture patterns used
- Integration points and dependencies
- Scalability and maintainability concerns

Output a comprehensive architecture assessment document to 
/docs/assessment/architecture-review.md including:
- Current state diagram
- Identified issues and technical debt
- Recommendations for improvement
- Risk areas that need attention
bash# Database Expert revisa schema y queries
Use the database-expert sub-agent to analyze the database:
- Review schema design in existing migrations
- Check for missing indexes
- Identify slow queries (review logs if available)
- Assess data integrity constraints
- Check for potential scaling issues

Output database assessment to /docs/assessment/database-review.md 
including:
- Schema diagram (current state)
- Performance issues identified
- Missing indexes or constraints
- Recommendations for optimization
bash# Code Reviewer evalúa calidad del código
Use the code-reviewer sub-agent to perform code quality audit:
- Review code structure and organization
- Check for common code smells
- Assess test coverage (current state)
- Review security vulnerabilities (common patterns)
- Check for duplicated code

Output code quality report to /docs/assessment/code-quality-report.md 
with:
- Quality score by module
- Critical issues (P0/P1)
- Technical debt items
- Recommended refactoring priorities
bash# DevOps evalúa infraestructura
Use the devops-engineer sub-agent to assess current infrastructure:
- Review deployment setup (if exists)
- Check CI/CD pipelines (current state)
- Assess monitoring and logging
- Review environment configurations
- Check for infrastructure as code

Output infrastructure assessment to /docs/assessment/infrastructure-review.md
bash# Test Engineer evalúa testing
Use the test-engineer sub-agent to assess test coverage:
- Review existing tests (unit, integration, e2e)
- Calculate current coverage percentage
- Identify untested critical paths
- Review test quality and maintainability
- Check for flaky tests

Output test assessment to /docs/assessment/test-coverage-report.md
Paso 0.2: Evaluación de Negocio
bash# Stakeholder define objetivos de negocio
Use the stakeholder sub-agent to document business context:
- Why was this project started?
- What business problem does it solve?
- What's the target market/users?
- What's the expected ROI?
- What's the urgency for completion?
- What features are absolutely critical?
- What's the available budget to complete?

Create business context document at /docs/business/business-context.md
bash# Product Owner identifica features completadas/faltantes
Use the product-owner sub-agent to inventory features:
- Review existing codebase and identify completed features
- Map completed features to original requirements (if available)
- Identify partially implemented features
- List missing critical features
- Assess which features are production-ready

Create feature inventory at /docs/product/feature-inventory.md with:
- ✅ Completed features
- 🔄 Partially implemented (% complete)
- 📝 Not started but critical
- ❌ Not started and can be deferred
Paso 0.3: Consolidación de Assessment
bash# Project Manager consolida evaluaciones
Use the project-manager sub-agent to create consolidated 
assessment report from all evaluations in /docs/assessment/:
- Executive summary of current state
- Critical blockers for production
- Estimated effort to complete
- Risk assessment
- Recommended approach (continue, rewrite, pivot)

Create consolidated report at /docs/assessment/PROJECT-ASSESSMENT.md
Decisión GO/NO-GO
bash# Stakeholder decide si continuar o no
Use the stakeholder sub-agent to review 
/docs/assessment/PROJECT-ASSESSMENT.md and make decision:

Options:
1. ✅ Continue - Worth completing as-is
2. 🔄 Continue with refactoring - Needs significant rework
3. 🔀 Pivot - Change direction but keep some components
4. ❌ Stop - Not viable, cut losses

Document decision and rationale in /docs/business/go-no-go-decision.md
⚠️ CHECKPOINT: Si la decisión es STOP, el proyecto termina aquí.

FASE 1: Planning & Prioritization
Duración: 1 semana
Objetivo: Crear plan para completar el proyecto
Paso 1.1: Definir MVP y Fases
bash# Product Owner define MVP
Use the product-owner sub-agent to define MVP based on:
- Feature inventory from /docs/product/feature-inventory.md
- Business priorities from stakeholder
- Technical constraints from architecture review

Create MVP definition at /docs/product/mvp-definition.md including:
- Must-have features for MVP
- Acceptance criteria for MVP launch
- Features deferred to post-MVP
- Success metrics for MVP

Use MoSCoW prioritization:
- MUST: Critical for launch
- SHOULD: Important but not blocking
- COULD: Nice to have
- WON'T: Explicitly deferred
bash# Software Architect crea plan de refactoring
Use the software-architect sub-agent to create refactoring 
roadmap based on /docs/assessment/architecture-review.md:
- Critical technical debt that blocks production
- Recommended architecture improvements
- Migration strategy (if needed)
- Phases for implementing improvements

Create refactoring roadmap at /docs/technical/refactoring-roadmap.md
bash# Project Manager crea plan maestro
Use the project-manager sub-agent to create master project plan:
- Combine MVP requirements and refactoring needs
- Define phases with milestones
- Estimate timeline (realistic)
- Resource requirements
- Budget estimate
- Risk register

Create master plan at /docs/project-management/master-plan.md with:
- Phase 1: Stabilization (critical fixes)
- Phase 2: Core MVP Features
- Phase 3: Quality & Testing
- Phase 4: Launch Prep
Paso 1.2: Priorización y Roadmap
bash# Product Owner crea backlog priorizado
Use the product-owner sub-agent to create prioritized backlog:
- Import incomplete features from feature inventory
- Add technical debt items (critical ones)
- Create user stories with acceptance criteria
- Estimate story points with RICE score
- Organize into epics

Create product backlog at /docs/product/backlog.md
bash# Stakeholder valida prioridades
Use the stakeholder sub-agent to review and adjust priorities 
in /docs/product/backlog.md:
- Validate business value ranking
- Confirm resource allocation
- Approve timeline and budget
- Set success criteria

Document approval in /docs/business/backlog-approval.md
Paso 1.3: Team Setup
bash# Project Manager define equipo y recursos
Use the project-manager sub-agent to create resource plan:
- Define team composition needed
- Identify skill gaps
- Create RACI matrix
- Plan onboarding for new team members (if any)
- Set up communication channels

Create resource plan at /docs/project-management/resource-plan.md

FASE 2: Stabilization
Duración: 2-4 semanas
Objetivo: Hacer el código existente estable y mantenible
Paso 2.1: Critical Bug Fixes
bash# Code Reviewer identifica bugs críticos
Use the code-reviewer sub-agent to review codebase for critical 
issues (P0/P1):
- Security vulnerabilities
- Data loss risks
- Breaking bugs
- Performance bottlenecks

Prioritize issues in /docs/technical/critical-issues.md
bash# Developers implementan fixes
Use the backend-python-developer (or appropriate developer agent) 
to fix critical issues from /docs/technical/critical-issues.md:
- Fix P0 issues first (blocking)
- Then P1 issues (high priority)
- Document each fix
- Add tests to prevent regression

For each issue fixed, update /docs/technical/critical-issues.md 
with status
Paso 2.2: Technical Debt Reduction
bash# Software Architect prioriza deuda técnica crítica
Use the software-architect sub-agent to prioritize technical 
debt items from refactoring roadmap:
- Select items that block production
- Items that enable future features
- Items that reduce development friction

Create tech debt sprint plan at 
/docs/technical/tech-debt-sprint-plan.md
bash# Developers implementan refactoring
Use appropriate developer agents to implement refactoring:
- Extract duplicated code into reusable components
- Improve code organization and structure
- Add missing abstractions
- Update dependencies to secure versions

Track progress in /docs/technical/tech-debt-sprint-plan.md
Paso 2.3: Database Optimization
bash# Database Expert optimiza database
Use the database-expert sub-agent to implement critical 
database improvements:
- Add missing indexes
- Fix schema issues
- Optimize slow queries
- Add constraints for data integrity

Create migration scripts and document changes in 
/docs/technical/database-migrations.md
Paso 2.4: Testing Foundation
bash# Test Engineer establece base de testing
Use the test-engineer sub-agent to create testing foundation:
- Set up testing framework (if not exists)
- Create test utilities and fixtures
- Write tests for critical paths (even if no tests existed)
- Set up coverage reporting
- Target: minimum 60% coverage before Phase 3

Create testing strategy at /docs/qa/testing-strategy.md
Paso 2.5: CI/CD Setup
bash# DevOps Engineer crea CI/CD pipeline
Use the devops-engineer sub-agent to set up automation:
- Create CI pipeline (build, test, lint)
- Set up staging environment
- Configure deployment automation
- Set up basic monitoring

Document CI/CD setup at /docs/devops/ci-cd-setup.md
Paso 2.6: Sprint Reviews (Stabilization)
bash# Project Manager coordina review semanal
Use the project-manager sub-agent to run weekly reviews 
during stabilization:
- Track progress on critical fixes
- Update risk register
- Adjust priorities if needed
- Report to stakeholders

Create weekly status reports in 
/docs/project-management/status-reports/

FASE 3: Completion
Duración: 4-8 semanas
Objetivo: Completar features faltantes para MVP
Paso 3.1: Sprint Planning
bash# Product Owner + Project Manager planean sprints
Use the product-owner sub-agent to plan Sprint 1:
- Select user stories from backlog (top priority)
- Consider team velocity (if known) or estimate conservative
- Ensure stories are refined with clear acceptance criteria

Use the project-manager sub-agent to:
- Assign resources to stories
- Identify dependencies
- Set sprint goals
- Schedule ceremonies (daily standup, review, retro)

Create sprint plan at /docs/sprints/sprint-01-plan.md
Paso 3.2: Feature Implementation (Iterative)
Para cada sprint (repetir 4-6 veces):
A. Design & Architecture
bash# Software Architect revisa design de nueva feature
Use the software-architect sub-agent to review design for 
[Feature Name] story from current sprint:
- Ensure alignment with existing architecture
- Identify integration points
- Flag potential issues
- Recommend approach

Create design doc at /docs/technical/designs/[feature-name]-design.md
B. Database Changes
bash# Database Expert diseña cambios de schema
Use the database-expert sub-agent to design database changes 
for [Feature Name]:
- New tables or columns needed
- Indexes required
- Data migration strategy
- Performance considerations

Create migration at /db/migrations/[timestamp]_[feature_name].sql
C. Backend Development
bash# Backend Developer implementa API
Use the backend-python-developer (or backend-net-developer) 
sub-agent to implement backend for [Feature Name] following 
/docs/technical/designs/[feature-name]-design.md:
- Implement business logic
- Create API endpoints
- Add input validation
- Implement error handling
- Write unit tests (target >80% coverage)

Implement in appropriate service/module
D. Frontend Development
bash# Frontend Developer implementa UI
Use the frontend-react-developer (or frontend-angular-developer) 
sub-agent to implement UI for [Feature Name]:
- Create components following design mockups
- Integrate with backend API
- Add form validation
- Implement error states and loading states
- Write component tests

Implement in appropriate feature folder
E. Code Review
bash# Code Reviewer revisa implementación
Use the code-reviewer sub-agent to review code for [Feature Name]:
- Check code quality and best practices
- Verify all acceptance criteria are met
- Check test coverage
- Identify potential issues
- Provide actionable feedback

Create review comments and approve/request changes
F. Testing
bash# Test Engineer crea tests end-to-end
Use the test-engineer sub-agent to create comprehensive tests 
for [Feature Name]:
- Integration tests (API)
- End-to-end tests (user flows)
- Performance tests (if applicable)
- Security tests (if sensitive feature)

Create tests in /tests/integration/ and /tests/e2e/
G. Sprint Review
bash# Product Owner + Stakeholder revisan sprint
Use the product-owner sub-agent to prepare sprint review:
- Demo script for completed features
- Metrics achieved
- Blockers encountered

Use the stakeholder sub-agent to review sprint deliverables:
- Validate acceptance criteria are met
- Provide feedback
- Accept or request changes
- Adjust priorities if needed

Document feedback in /docs/sprints/sprint-[N]-review.md
H. Sprint Retrospective
bash# Project Manager facilita retrospective
Use the project-manager sub-agent to run sprint retrospective:
- What went well?
- What could be improved?
- Action items for next sprint
- Update process if needed

Document in /docs/sprints/sprint-[N]-retrospective.md
Paso 3.3: Progreso y Ajustes
bash# Project Manager monitorea progreso
Use the project-manager sub-agent every 2 weeks to:
- Update project plan with actual vs planned
- Adjust timeline if needed
- Escalate blockers
- Report to stakeholders

Create bi-weekly reports in 
/docs/project-management/status-reports/biweekly-[date].md
bash# Product Owner ajusta backlog
Use the product-owner sub-agent to refine backlog continuously:
- Re-prioritize based on learnings
- Add/remove stories as needed
- Update estimates based on velocity
- Prepare upcoming sprint stories

Update /docs/product/backlog.md regularly

FASE 4: Quality & Testing
Duración: 2-3 semanas
Objetivo: Alcanzar calidad de producción
Paso 4.1: Comprehensive Testing
bash# Test Engineer crea suite completa de tests
Use the test-engineer sub-agent to create comprehensive test suite:
- Unit tests for all services/modules (target >80%)
- Integration tests for all APIs
- End-to-end tests for critical user journeys
- Performance tests (load testing)
- Security tests (OWASP Top 10)

Organize tests in /tests/ folder structure
bash# Test Engineer ejecuta tests y reporta
Use the test-engineer sub-agent to run all tests and create 
test report:
- Execute full test suite
- Document pass/fail results
- Calculate coverage metrics
- Identify gaps in testing
- Create bug tickets for failures

Create test report at /docs/qa/test-execution-report.md
Paso 4.2: Bug Fixing Sprint
bash# Project Manager planea bug fixing sprint
Use the project-manager sub-agent to plan dedicated bug fixing 
sprint:
- Prioritize bugs by severity (P0 > P1 > P2 > P3)
- Allocate team to fix bugs
- Set target: zero P0/P1 bugs
- Schedule regression testing

Create bug fixing plan at /docs/sprints/bug-fixing-sprint.md
bash# Developers fix bugs
Use appropriate developer agents to fix bugs:
- Fix P0 and P1 bugs first
- Add regression tests for each bug
- Document root cause
- Update documentation if needed

Track bug fixes in /docs/qa/bug-tracking.md
Paso 4.3: Code Quality Review
bash# Code Reviewer hace review final
Use the code-reviewer sub-agent to do final code quality review:
- Review all modules for quality
- Check for code smells
- Verify best practices followed
- Ensure consistent coding style
- Check for security vulnerabilities

Create final quality report at /docs/qa/final-quality-review.md
Paso 4.4: Performance Testing
bash# Test Engineer ejecuta performance tests
Use the test-engineer sub-agent to conduct performance testing:
- Load testing (simulate expected traffic)
- Stress testing (find breaking point)
- Soak testing (sustained load)
- Measure response times, throughput
- Identify bottlenecks

Create performance report at /docs/qa/performance-test-report.md
bash# Database Expert optimiza si es necesario
If performance issues identified, use the database-expert 
sub-agent to optimize:
- Add indexes
- Optimize queries
- Configure connection pooling
- Scale database if needed

Document optimizations in /docs/technical/performance-optimizations.md
Paso 4.5: Security Review
bash# Code Reviewer hace security audit
Use the code-reviewer sub-agent to conduct security review:
- Check for SQL injection vulnerabilities
- Verify input validation
- Check authentication/authorization
- Review sensitive data handling
- Check for XSS vulnerabilities
- Review dependency vulnerabilities

Create security audit report at /docs/qa/security-audit-report.md

FASE 5: Launch Preparation
Duración: 2-3 semanas
Objetivo: Preparar para producción
Paso 5.1: Infrastructure Setup
bash# DevOps Engineer configura producción
Use the devops-engineer sub-agent to set up production infrastructure:
- Provision production servers/cloud resources
- Configure load balancer
- Set up database (primary + replicas)
- Configure CDN
- Set up SSL certificates
- Configure firewalls and security groups

Document infrastructure at /docs/devops/production-infrastructure.md
bash# DevOps Engineer configura monitoring
Use the devops-engineer sub-agent to set up monitoring:
- Application performance monitoring (APM)
- Error tracking and logging
- Infrastructure monitoring
- Alerting rules
- Dashboards for key metrics

Document monitoring setup at /docs/devops/monitoring-setup.md
Paso 5.2: Deployment Pipeline
bash# DevOps Engineer crea production pipeline
Use the devops-engineer sub-agent to create production 
deployment pipeline:
- Automated deployment to production
- Blue-green deployment strategy (or canary)
- Rollback procedure
- Database migration automation
- Smoke tests after deployment

Document deployment process at /docs/devops/deployment-process.md
Paso 5.3: Documentation
bash# Product Owner crea user documentation
Use the product-owner sub-agent to create end-user documentation:
- User guides for main features
- FAQ section
- Getting started guide
- Video tutorials (scripts)
- Help center content

Create documentation at /docs/user-documentation/
bash# Software Architect crea technical documentation
Use the software-architect sub-agent to create technical docs:
- Architecture documentation
- API documentation (OpenAPI/Swagger)
- Database schema documentation
- Deployment guide
- Troubleshooting guide

Create documentation at /docs/technical-documentation/
bash# DevOps Engineer crea runbook
Use the devops-engineer sub-agent to create operations runbook:
- Deployment procedures
- Monitoring and alerting guide
- Incident response procedures
- Backup and restore procedures
- Disaster recovery plan

Create runbook at /docs/devops/operations-runbook.md
Paso 5.4: UAT (User Acceptance Testing)
bash# Product Owner planea UAT
Use the product-owner sub-agent to plan user acceptance testing:
- Define UAT scenarios (critical user journeys)
- Recruit beta users or stakeholders
- Create UAT checklist
- Schedule UAT period (1-2 weeks)
- Define acceptance criteria

Create UAT plan at /docs/qa/uat-plan.md
bash# Stakeholder participa en UAT
Use the stakeholder sub-agent to conduct UAT:
- Test all critical features
- Provide feedback on usability
- Verify business requirements are met
- Identify any show-stoppers
- Make go/no-go recommendation

Document UAT results at /docs/qa/uat-results.md
Paso 5.5: Launch Plan
bash# Project Manager crea launch plan
Use the project-manager sub-agent to create detailed launch plan:
- Launch date and time
- Launch checklist (pre-launch, launch, post-launch)
- Team assignments
- Communication plan
- Rollback criteria and procedure
- Support plan (who's on-call)

Create launch plan at /docs/project-management/launch-plan.md
bash# Stakeholder aprueba go-live
Use the stakeholder sub-agent to make final go/no-go decision:
- Review UAT results
- Review risk register
- Confirm readiness
- Approve launch date
- Set success criteria for launch week

Document decision at /docs/business/go-live-approval.md

FASE 6: Production & Handover
Duración: 2-4 semanas
Objetivo: Launch y estabilización
Paso 6.1: Production Launch
bash# DevOps Engineer ejecuta deployment
Use the devops-engineer sub-agent to deploy to production:
- Execute deployment pipeline
- Run smoke tests
- Monitor for errors
- Watch key metrics (response time, error rate, traffic)
- Be ready to rollback if issues

Document launch in /docs/devops/launch-log.md
bash# Project Manager coordina launch
Use the project-manager sub-agent to coordinate launch day:
- Run launch checklist
- Coordinate team communications
- Monitor progress
- Escalate issues if needed
- Update stakeholders

Create launch day log at 
/docs/project-management/launch-day-log.md
Paso 6.2: Post-Launch Monitoring
bash# DevOps Engineer monitorea producción (Primeros 7 días)
Use the devops-engineer sub-agent to monitor production closely:
- Watch error rates, response times
- Monitor system resources
- Check logs for issues
- Respond to alerts quickly
- Create daily monitoring reports

Daily reports at /docs/devops/post-launch-monitoring/day-[N].md
bash# Project Manager coordina daily war room (Primera semana)
Use the project-manager sub-agent to run daily check-ins:
- Review metrics from past 24 hours
- Identify issues or concerns
- Coordinate fixes if needed
- Update stakeholders

Daily summaries at 
/docs/project-management/launch-week-daily-[N].md
Paso 6.3: Issue Resolution
bash# Si hay issues post-launch
Use appropriate developer agents to fix production issues:
- Prioritize by severity and user impact
- Deploy hotfixes following process
- Add regression tests
- Document root cause

Track in /docs/post-launch/production-issues.md
Paso 6.4: Success Metrics Validation
bash# Product Owner valida métricas (After 2-4 weeks)
Use the product-owner sub-agent to validate success metrics:
- Compare actual vs target metrics
- Analyze user behavior and adoption
- Identify areas for improvement
- Plan next iteration

Create metrics report at /docs/product/launch-metrics-report.md
bash# Stakeholder valida ROI
Use the stakeholder sub-agent to validate business outcomes:
- Measure actual vs expected business value
- Calculate ROI achieved
- Identify any gaps
- Decide on next steps (enhancements, new features)

Document business results at 
/docs/business/business-results-report.md
Paso 6.5: Project Closure
bash# Project Manager cierra proyecto
Use the project-manager sub-agent to close project:
- Conduct lessons learned session
- Document successes and challenges
- Archive project documentation
- Celebrate team success
- Create handover documentation for maintenance team

Create closure report at /docs/project-management/project-closure-report.md
bash# Stakeholder aprueba cierre
Use the stakeholder sub-agent to approve project closure:
- Review final deliverables
- Confirm all objectives met
- Approve final budget
- Sign off on project completion
- Provide feedback for future projects

Document approval at /docs/business/project-sign-off.md

QUICK REFERENCE: Command Cheat Sheet
Discovery Phase
bash# Full assessment (run all)
Use the software-architect sub-agent to assess architecture
Use the database-expert sub-agent to assess database
Use the code-reviewer sub-agent to assess code quality
Use the devops-engineer sub-agent to assess infrastructure
Use the test-engineer sub-agent to assess test coverage
Use the stakeholder sub-agent to define business context
Use the product-owner sub-agent to inventory features
Use the project-manager sub-agent to consolidate assessment
Planning Phase
bash# Create project plan
Use the product-owner sub-agent to define MVP
Use the software-architect sub-agent to create refactoring roadmap
Use the project-manager sub-agent to create master plan
Use the product-owner sub-agent to create backlog
Use the stakeholder sub-agent to approve plan
Implementation Phase (Per Sprint)
bash# Sprint cycle
Use the product-owner + project-manager to plan sprint
Use the software-architect to review designs
Use the database-expert to design schema changes
Use the backend-[python/net]-developer to implement backend
Use the frontend-[react/angular]-developer to implement frontend
Use the code-reviewer to review code
Use the test-engineer to create tests
Use the product-owner + stakeholder to review sprint
Use the project-manager to run retrospective
Quality Phase
bash# Achieve production quality
Use the test-engineer to create comprehensive test suite
Use the test-engineer to execute tests and report
Use the project-manager to plan bug fixing sprint
Use the code-reviewer to do final quality review
Use the test-engineer to conduct performance testing
Use the code-reviewer to conduct security audit
Launch Phase
bash# Prepare and launch
Use the devops-engineer to set up production infrastructure
Use the devops-engineer to configure monitoring
Use the devops-engineer to create deployment pipeline
Use the product-owner to create documentation
Use the product-owner to plan UAT
Use the stakeholder to conduct UAT
Use the project-manager to create launch plan
Use the stakeholder to approve go-live
Use the devops-engineer to deploy to production
Use the project-manager to coordinate launch

TEMPLATES DE DOCUMENTOS
Los documentos clave que deberías crear:
Business Documents (Stakeholder)

/docs/business/business-context.md
/docs/business/go-no-go-decision.md
/docs/business/backlog-approval.md
/docs/business/go-live-approval.md
/docs/business/business-results-report.md

Project Management (PM)

/docs/project-management/master-plan.md
/docs/project-management/resource-plan.md
/docs/project-management/status-reports/
/docs/project-management/launch-plan.md
/docs/project-management/project-closure-report.md

Product (PO)

/docs/product/feature-inventory.md
/docs/product/mvp-definition.md
/docs/product/backlog.md
/docs/product/launch-metrics-report.md

Technical (Architect, Database, Developers)

/docs/technical/architecture-review.md
/docs/technical/database-migrations.md
/docs/technical/refactoring-roadmap.md
/docs/technical/designs/

QA (Test Engineer)

/docs/qa/testing-strategy.md
/docs/qa/test-coverage-report.md
/docs/qa/test-execution-report.md
/docs/qa/uat-plan.md
/docs/qa/security-audit-report.md

DevOps

/docs/devops/infrastructure-review.md
/docs/devops/ci-cd-setup.md
/docs/devops/production-infrastructure.md
/docs/devops/operations-runbook.md

Sprints

/docs/sprints/sprint-[N]-plan.md
/docs/sprints/sprint-[N]-review.md
/docs/sprints/sprint-[N]-retrospective.md


AJUSTES SEGÚN TAMAÑO DEL PROYECTO
Proyecto Pequeño (1-2 meses)

Combina Fase 2 y 3 (Stabilization + Completion)
Sprints de 1 semana
UAT más corto (3-5 días)
Launch en día laborable con rollback rápido

Proyecto Mediano (3-4 meses)

Sigue el template completo
Sprints de 2 semanas
UAT de 1 semana
Phased rollout (beta users first)

Proyecto Grande (6+ meses)

Divide Fase 3 en sub-fases por módulo
Considera múltiples MVPs
Sprints de 2 semanas
UAT de 2 semanas con beta program
Staged rollout (region by region, customer tier)


MÉTRICAS DE ÉXITO
Track estas métricas a lo largo del proyecto:
Technical Metrics

Code coverage: Target >80%
Bug density: <5 bugs per 1000 lines
Technical debt ratio: <30%
Build success rate: >95%
Deployment frequency: Weekly (at least)

Process Metrics

Sprint velocity: Track and stabilize
Sprint commitment: >80% completion
Bug escape rate: <10% to production
Time to resolve P0: <4 hours
Time to resolve P1: <24 hours

Business Metrics

Time to market: On schedule ±10%
Budget variance: Within ±10%
Feature completion: 100% of MVP
User satisfaction: >8/10
ROI: Positive within 6 months


COMMON PITFALLS & HOW TO AVOID
❌ Pitfall: Trying to rewrite everything
✅ Solution: Use Stabilization phase to fix critical issues only, defer nice-to-haves
❌ Pitfall: Underestimating technical debt
✅ Solution: Dedicated sprints for tech debt, allocate 20% of capacity
❌ Pitfall: Skipping testing to save time
✅ Solution: Automate tests from day 1, treat test failures as blockers
❌ Pitfall: No clear MVP definition
✅ Solution: Use MoSCoW method, get stakeholder sign-off on MVP scope
❌ Pitfall: Poor communication between teams
✅ Solution: Daily standups, weekly reviews, shared documentation
❌ Pitfall: Launching without UAT
✅ Solution: Mandatory UAT phase with real users, no shortcuts
❌ Pitfall: No rollback plan
✅ Solution: Test rollback procedure in staging before launch

Este template te proporciona una estructura completa y probada para llevar un proyecto existente a producción usando todos los agentes de Claude Code de manera coordinada.