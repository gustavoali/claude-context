# AWS-012: Security (Cognito / KMS / Secrets Manager)
**Points:** 3 | **Priority:** High | **Fase:** 2 | **Deps:** AWS-007

**As a** developer building secure serverless apps
**I want** to understand AWS security services
**So that** I can implement authentication, encryption, and secrets management

## Acceptance Criteria

**AC1:** Given Cognito, When I create a User Pool, Then users can sign up, sign in, and get JWT tokens.
**AC2:** Given an API Gateway, When I add Cognito authorizer, Then only authenticated requests are allowed.
**AC3:** Given secrets, When I store them in Secrets Manager or Parameter Store, Then Lambda retrieves them at runtime without hardcoding.

## Study Topics
- Cognito User Pools (sign up, sign in, MFA, JWT tokens)
- Cognito Identity Pools (federated identities, temporary AWS credentials)
- User Pools vs Identity Pools (when to use each)
- API Gateway authorizers (Cognito, Lambda, IAM)
- KMS (CMK, key policies, envelope encryption)
- KMS integration with other services (S3, DynamoDB, Lambda env vars)
- Secrets Manager vs Parameter Store
  - Secrets Manager: rotation, cost ($0.40/secret/month)
  - Parameter Store: free tier, hierarchical, no rotation
- Lambda environment variable encryption with KMS
- STS and temporary credentials

## Lab
1. Create Cognito User Pool with email sign-up
2. Configure app client
3. Sign up and sign in via AWS CLI or SDK
4. Add Cognito authorizer to API Gateway
5. Test authenticated and unauthenticated requests
6. Store a secret in Secrets Manager
7. Read secret from Lambda at runtime
8. Store config in Parameter Store, read from Lambda

## Resources
- Stephane Maarek course - Security section
- AWS Cognito documentation
- AWS KMS best practices

## DoD
- [ ] Cognito User Pool working
- [ ] API Gateway auth with Cognito
- [ ] Secrets Manager integration
- [ ] Parameter Store integration
- [ ] Understand KMS concepts
