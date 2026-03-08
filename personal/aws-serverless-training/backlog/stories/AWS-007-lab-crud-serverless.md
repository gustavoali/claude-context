# AWS-007: Lab - CRUD API Serverless
**Points:** 3 | **Priority:** Critical | **Fase:** 1 | **Deps:** AWS-003, AWS-004, AWS-005, AWS-006

**As a** developer
**I want** to build a complete CRUD API using the serverless stack
**So that** I validate end-to-end knowledge of Lambda + API GW + DynamoDB + SAM

## Acceptance Criteria

**AC1:** Given the API, When I send CRUD requests (POST, GET, PUT, DELETE), Then items are created, read, updated, and deleted in DynamoDB.
**AC2:** Given the SAM template, When I run `sam deploy`, Then the entire stack (Lambda functions, API Gateway, DynamoDB table) is provisioned.
**AC3:** Given the API, When I test with curl/Postman, Then all endpoints return proper HTTP status codes and JSON responses.
**AC4:** Given error scenarios (item not found, validation errors), When they occur, Then the API returns appropriate error responses.

## Description

Build a "Tasks" or "Products" CRUD API:
- POST /items - Create item
- GET /items - List items
- GET /items/{id} - Get item by ID
- PUT /items/{id} - Update item
- DELETE /items/{id} - Delete item

## Tech Stack
- .NET 8 Lambda functions (one per operation or single handler with routing)
- API Gateway REST API with Lambda proxy integration
- DynamoDB table with proper key design
- SAM template defining all resources
- Structured logging

## Lab Steps
1. Design DynamoDB table schema for Items
2. Create SAM template with all resources
3. Implement Lambda handler(s) in .NET 8
4. Test locally with `sam local start-api`
5. Deploy with `sam deploy`
6. Test all CRUD operations with curl
7. Verify CloudWatch logs
8. Clean up with `sam delete`

## DoD
- [ ] All 5 endpoints working
- [ ] DynamoDB operations correct
- [ ] SAM template deploys cleanly
- [ ] Error handling for common cases
- [ ] CloudWatch logs visible
- [ ] Can demo and explain the full flow
