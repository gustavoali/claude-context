# AWS-011: GitLab CI/CD + SAM Pipeline
**Points:** 3 | **Priority:** High | **Fase:** 2 | **Deps:** AWS-006

**As a** developer deploying serverless apps
**I want** to automate deployment with GitLab CI/CD and SAM
**So that** I can deliver changes safely to multiple environments

## Acceptance Criteria

**AC1:** Given a GitLab repository, When I push to develop, Then SAM deploys to dev environment automatically.
**AC2:** Given a merge to main, When the pipeline runs, Then SAM deploys to prod with manual approval gate.
**AC3:** Given the pipeline, When it fails, Then I can diagnose from GitLab CI logs.

## Study Topics
- GitLab CI/CD basics (.gitlab-ci.yml, stages, jobs, artifacts)
- GitLab CI variables and secrets management
- SAM deploy in CI/CD (sam build, sam package, sam deploy)
- Multi-stage deployment (dev, staging, prod)
- samconfig.toml with multiple environments
- AWS credentials in CI/CD (IAM user vs OIDC federation)
- Pipeline best practices (caching, parallel jobs)
- Rollback strategies with SAM/CloudFormation
- GitLab environments and deployment tracking

## Lab
1. Create GitLab repository (or use existing)
2. Create `.gitlab-ci.yml` with stages: test, build, deploy-dev, deploy-prod
3. Configure AWS credentials as CI/CD variables
4. Implement SAM build + deploy in pipeline
5. Create samconfig.toml with dev and prod configurations
6. Test pipeline: push to develop -> auto-deploy to dev
7. Test pipeline: merge to main -> manual approval -> deploy to prod
8. Test rollback scenario

## Resources
- GitLab CI/CD documentation
- AWS SAM CI/CD deployment guide
- GitLab + AWS integration docs

## DoD
- [ ] Pipeline deploying to dev on push
- [ ] Pipeline deploying to prod with approval gate
- [ ] Multiple stages in samconfig.toml
- [ ] Credentials managed securely
- [ ] Can explain pipeline to interviewer
