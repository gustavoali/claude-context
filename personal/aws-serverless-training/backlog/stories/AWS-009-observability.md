# AWS-009: Observability (CloudWatch / X-Ray)
**Points:** 3 | **Priority:** High | **Fase:** 2 | **Deps:** AWS-007

**As a** developer operating serverless applications
**I want** to master CloudWatch and X-Ray
**So that** I can monitor, debug, and optimize my applications

## Acceptance Criteria

**AC1:** Given a Lambda function, When it executes, Then I can find structured logs in CloudWatch Logs and query them with Log Insights.
**AC2:** Given X-Ray tracing enabled, When a request flows through API GW -> Lambda -> DynamoDB, Then I see the full trace in the X-Ray console.
**AC3:** Given CloudWatch metrics, When I create a custom alarm, Then I receive notification when error rate exceeds threshold.

## Study Topics
- CloudWatch Logs (log groups, log streams, retention)
- CloudWatch Logs Insights (query syntax)
- CloudWatch Metrics (standard vs custom, dimensions)
- CloudWatch Alarms (threshold, anomaly detection)
- CloudWatch Dashboards
- X-Ray (traces, segments, subsegments, annotations, metadata)
- X-Ray SDK for .NET
- X-Ray integration with Lambda, API Gateway, DynamoDB
- Lambda PowerTools for .NET (structured logging, tracing)
- Embedded Metric Format (EMF)

## Lab
1. Enable X-Ray on Lambda and API Gateway (SAM template)
2. Add X-Ray SDK to .NET Lambda
3. Trace a request through the full CRUD API stack
4. Write CloudWatch Logs Insights queries
5. Create custom CloudWatch metric from Lambda
6. Create alarm on error rate
7. Build a simple CloudWatch Dashboard

## Resources
- Stephane Maarek course - Monitoring section
- AWS X-Ray documentation
- Lambda PowerTools .NET docs

## DoD
- [ ] X-Ray traces visible for full request flow
- [ ] CloudWatch Logs Insights queries working
- [ ] Custom alarm configured
- [ ] Dashboard created
- [ ] Structured logging implemented
