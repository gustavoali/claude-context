# AWS-008: Messaging Patterns (SQS/SNS/EventBridge)
**Points:** 3 | **Priority:** High | **Fase:** 2 | **Deps:** AWS-007

**As a** developer building event-driven systems
**I want** to understand AWS messaging services
**So that** I can design decoupled, resilient architectures

## Acceptance Criteria

**AC1:** Given SQS, SNS, and EventBridge, When asked about differences, Then I can explain when to use each one with concrete examples.
**AC2:** Given an SQS queue, When a message is sent, Then a Lambda function processes it via event source mapping.
**AC3:** Given an SNS topic, When a message is published, Then multiple subscribers (Lambda, SQS, email) receive it.

## Study Topics
- SQS (Standard vs FIFO, visibility timeout, DLQ, long polling)
- SNS (topics, subscriptions, fan-out pattern, message filtering)
- EventBridge (event bus, rules, patterns, scheduled events)
- SQS + SNS fan-out pattern
- Lambda event source mappings (SQS, SNS triggers)
- Step Functions basics (Standard vs Express)
- Comparison: SQS vs SNS vs EventBridge vs Kinesis
- Error handling and retry strategies
- Dead Letter Queues

## Lab
1. Create SQS queue + Lambda consumer
2. Create SNS topic with Lambda + SQS subscribers
3. Create EventBridge rule triggering Lambda on schedule
4. Implement fan-out: SNS -> multiple SQS queues
5. Configure DLQ for failed messages

## Resources
- Stephane Maarek course - SQS/SNS/EventBridge sections
- AWS messaging comparison whitepaper

## DoD
- [ ] SQS -> Lambda working
- [ ] SNS fan-out working
- [ ] EventBridge scheduled rule working
- [ ] Can explain when to use each service
- [ ] DLQ configured
