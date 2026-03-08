# AWS-013: Lab - Pipeline Completo
**Points:** 3 | **Priority:** High | **Fase:** 2 | **Deps:** AWS-008, AWS-009, AWS-010, AWS-011, AWS-012

**As a** developer
**I want** to build a complete production-like pipeline
**So that** I validate end-to-end knowledge of the full serverless stack

## Acceptance Criteria

**AC1:** Given the complete stack, When I push code, Then it deploys automatically with all services integrated.
**AC2:** Given Datadog monitoring, When the app runs, Then traces, metrics, and logs are visible.
**AC3:** Given authentication, When accessing the API, Then Cognito JWT validation is enforced.
**AC4:** Given async processing, When an event occurs, Then it flows through SQS/SNS correctly.

## Description

Extend the CRUD API from AWS-007 into a production-like application:
- GitLab CI/CD pipeline with multi-stage deploy
- Cognito authentication on API Gateway
- SQS queue for async processing (e.g., notifications on item changes)
- Datadog monitoring (traces, logs, custom metrics)
- CloudWatch alarms as backup monitoring
- Proper error handling with DLQ

## Lab Steps
1. Take CRUD API from AWS-007
2. Add Cognito authorizer
3. Add SQS queue triggered on item creation (via DynamoDB Streams or direct)
4. Add Datadog Lambda Extension
5. Create GitLab CI/CD pipeline
6. Deploy to dev and prod stages
7. Generate traffic and verify in Datadog
8. Verify alarm triggers on simulated errors
9. Document architecture diagram

## DoD
- [ ] Full stack deployed via GitLab CI/CD
- [ ] Authentication working
- [ ] Async messaging working
- [ ] Datadog monitoring active
- [ ] Architecture diagram documented
- [ ] Can walk through entire flow in interview setting
