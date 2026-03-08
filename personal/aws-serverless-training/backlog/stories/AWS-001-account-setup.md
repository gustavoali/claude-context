# AWS-001: Account Setup + Billing Alerts
**Points:** 1 | **Priority:** Critical | **Fase:** 1

**As a** developer preparing for an AWS role
**I want** a properly configured AWS account with billing protection
**So that** I can safely practice without unexpected charges

## Acceptance Criteria

**AC1:** Given a new or existing AWS account, When I configure billing alerts, Then I receive email notifications at $5 and $10 thresholds.
**AC2:** Given the account, When I enable MFA on root account, Then root access requires a second factor.
**AC3:** Given the account, When I install AWS CLI v2, Then `aws sts get-caller-identity` returns my account info.

## Study Topics
- AWS Free Tier limits (12 months vs always free)
- Billing dashboard and Cost Explorer
- Budget alerts configuration
- AWS CLI v2 installation and `aws configure`
- MFA setup on root account

## Lab
1. Create/verify AWS account
2. Enable MFA on root
3. Set up billing alert at $5 USD
4. Install AWS CLI v2
5. Configure credentials with `aws configure`
6. Verify with `aws sts get-caller-identity`

## Resources
- https://aws.amazon.com/free/
- AWS CLI install docs

## DoD
- [ ] Account active with MFA
- [ ] Billing alert at $5
- [ ] AWS CLI working locally
