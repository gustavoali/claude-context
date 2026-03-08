# AWS-006: SAM CLI
**Points:** 3 | **Priority:** Critical | **Fase:** 1 | **Deps:** AWS-003

**As a** serverless developer
**I want** to master AWS SAM for infrastructure as code
**So that** I can define, test, and deploy serverless apps reproducibly

## Acceptance Criteria

**AC1:** Given a SAM template, When I run `sam build && sam deploy`, Then the stack deploys successfully to AWS.
**AC2:** Given a Lambda function, When I run `sam local invoke`, Then I can test locally without deploying.
**AC3:** Given a SAM template, When I define Lambda + API Gateway + DynamoDB, Then all resources are created with correct permissions.

## Study Topics
- SAM template anatomy (Transform, Globals, Resources)
- SAM resource types (AWS::Serverless::Function, Api, SimpleTable, etc.)
- SAM CLI commands (init, build, deploy, local invoke, local start-api, logs)
- samconfig.toml configuration
- SAM vs CloudFormation (SAM is a superset/macro)
- SAM policy templates (simplified IAM)
- Nested stacks and cross-stack references
- SAM Accelerate (`sam sync`) for rapid iteration
- Environment variables and parameter overrides
- SAM local testing with Docker

## Lab
1. Install SAM CLI
2. `sam init` with .NET 8 template
3. Modify template to add API Gateway event
4. `sam local invoke` to test locally
5. `sam local start-api` to test HTTP locally
6. `sam build && sam deploy --guided` to deploy
7. Add DynamoDB table to template with proper permissions
8. Add environment variable passing table name to Lambda

## Resources
- AWS SAM documentation
- SAM .NET examples on GitHub
- Stephane Maarek course - CloudFormation/SAM section

## DoD
- [ ] SAM CLI installed and working
- [ ] Template with Lambda + API GW + DynamoDB
- [ ] Local testing working
- [ ] Deployed stack to AWS
- [ ] Understand SAM vs CloudFormation
