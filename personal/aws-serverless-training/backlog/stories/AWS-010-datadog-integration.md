# AWS-010: Datadog Integration
**Points:** 3 | **Priority:** High | **Fase:** 2 | **Deps:** AWS-009

**As a** developer using Datadog for monitoring
**I want** to integrate Datadog with AWS Lambda and serverless stack
**So that** I can use Datadog for production observability (as required by the role)

## Acceptance Criteria

**AC1:** Given a Lambda function, When Datadog Lambda Extension is installed, Then metrics and traces appear in Datadog dashboard.
**AC2:** Given .NET instrumentation, When a request is processed, Then distributed traces show in Datadog APM.
**AC3:** Given Datadog, When I create a monitor (alert), Then I receive notification on Lambda errors or latency.

## Study Topics
- Datadog Lambda Extension (what it does, how it works)
- Datadog Forwarder vs Extension (modern approach)
- .NET Lambda instrumentation with dd-trace-dotnet
- Datadog APM for serverless (distributed tracing)
- Custom metrics from Lambda
- Datadog Log Management (Lambda log forwarding)
- Serverless View in Datadog
- Creating monitors and dashboards
- Datadog + SAM/CloudFormation integration (SAM macro or manual layers)
- Cost considerations (Datadog pricing for serverless)

## Lab
1. Create Datadog trial account (14 days free)
2. Install Datadog Lambda Extension via SAM layer
3. Configure DD_API_KEY and DD_SITE env vars
4. Add dd-trace-dotnet instrumentation
5. Generate traffic to CRUD API
6. Verify traces in Datadog APM
7. Create a simple Datadog dashboard
8. Create a monitor for Lambda errors

## Resources
- Datadog serverless monitoring docs
- Datadog .NET Lambda instrumentation guide
- https://docs.datadoghq.com/serverless/aws_lambda/

## DoD
- [ ] Datadog Extension installed on Lambda
- [ ] Traces visible in Datadog APM
- [ ] Logs forwarded to Datadog
- [ ] Monitor/alert configured
- [ ] Understand Extension vs Forwarder approach
