# AWS-005: DynamoDB Fundamentals
**Points:** 5 | **Priority:** Critical | **Fase:** 1 | **Deps:** AWS-002

**As a** developer working with NoSQL databases
**I want** to master DynamoDB data modeling and operations
**So that** I can design efficient serverless data layers

## Acceptance Criteria

**AC1:** Given a use case, When I design a DynamoDB table, Then I choose partition key and sort key that support all access patterns.
**AC2:** Given a query requirement not covered by the primary key, When I create a GSI, Then the query is efficient without full table scan.
**AC3:** Given the single-table design pattern, When asked about it, Then I can explain pros/cons and implement a basic example.
**AC4:** Given read/write capacity, When I choose between on-demand and provisioned, Then I can justify the decision based on workload.

## Study Topics
- DynamoDB data model (tables, items, attributes)
- Primary key design (partition key, composite key)
- Secondary indexes (GSI, LSI)
- Single-table design pattern (Rick Houlihan style)
- Read/Write capacity (on-demand vs provisioned, RCU/WCU)
- Query vs Scan (performance implications)
- DynamoDB Streams
- TTL (Time to Live)
- Transactions (TransactWriteItems, TransactGetItems)
- DAX (DynamoDB Accelerator) - caching
- Conditional writes and optimistic locking
- Batch operations (BatchWriteItem, BatchGetItem)
- .NET SDK: AWSSDK.DynamoDBv2 (low-level, Document, Object Persistence)
- PartiQL for DynamoDB

## Lab
1. Create a DynamoDB table with composite primary key
2. Insert items using .NET SDK
3. Query by partition key + sort key conditions
4. Create a GSI for an alternate access pattern
5. Implement a simple single-table design (e.g., Users + Orders)
6. Use DynamoDB Streams to trigger a Lambda
7. Test on-demand vs provisioned capacity

## Resources
- Stephane Maarek course - DynamoDB section
- Alex DeBrie - "The DynamoDB Book" (reference)
- Rick Houlihan re:Invent talks on single-table design
- AWS DynamoDB best practices documentation

## DoD
- [ ] Table created with proper key design
- [ ] CRUD operations via .NET SDK
- [ ] GSI created and queried
- [ ] Single-table design example implemented
- [ ] Can explain capacity modes and pricing
