# AWS-002: IAM Fundamentals
**Points:** 2 | **Priority:** Critical | **Fase:** 1 | **Deps:** AWS-001

**As a** developer
**I want** to understand IAM roles, policies, and best practices
**So that** I can configure secure access for Lambda and other services

## Acceptance Criteria

**AC1:** Given the AWS account, When I create an IAM user for development, Then the user has programmatic access with least-privilege policy.
**AC2:** Given IAM concepts, When asked in interview about roles vs policies vs users, Then I can explain clearly with examples.
**AC3:** Given a Lambda function scenario, When I define its execution role, Then I can write a policy document with correct Resource ARNs.

## Study Topics
- IAM Users, Groups, Roles, Policies
- Policy document structure (Effect, Action, Resource, Condition)
- AWS managed policies vs customer managed vs inline
- IAM best practices (least privilege, no root for daily use)
- Service roles (Lambda execution role, API Gateway role)
- STS AssumeRole and cross-account access
- Policy simulator

## Lab
1. Create IAM admin user (not root) for daily use
2. Create a custom policy allowing S3 read-only on a specific bucket
3. Create a role for Lambda with DynamoDB access
4. Test with IAM Policy Simulator
5. Verify least privilege works (denied on unauthorized actions)

## Resources
- Stephane Maarek course - IAM section
- AWS IAM best practices documentation

## DoD
- [ ] IAM user created for dev work
- [ ] Custom policy written and tested
- [ ] Lambda execution role created
- [ ] Can explain IAM model clearly
