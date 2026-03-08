# AWS-004: API Gateway
**Points:** 3 | **Priority:** Critical | **Fase:** 1 | **Deps:** AWS-002

**As a** developer building REST APIs
**I want** to master API Gateway configuration
**So that** I can expose Lambda functions as HTTP endpoints

## Acceptance Criteria

**AC1:** Given a Lambda function, When I create an API Gateway REST API, Then the function is accessible via HTTP with proper routing.
**AC2:** Given REST API vs HTTP API, When asked about differences, Then I can explain when to use each one.
**AC3:** Given CORS requirements, When I configure API Gateway, Then cross-origin requests work correctly.
**AC4:** Given multiple environments, When I use stages, Then I can deploy to dev/staging/prod independently.

## Study Topics
- REST API vs HTTP API (features, pricing, performance)
- Integration types (Lambda proxy, Lambda custom, HTTP, Mock)
- Resources, Methods, and routing
- Request/Response mapping templates
- Stages and stage variables
- CORS configuration
- API Keys and Usage Plans
- Throttling and rate limiting
- Custom domain names
- Request validation
- Gateway responses and error handling
- Caching

## Lab
1. Create REST API with Lambda proxy integration
2. Configure multiple routes (GET /items, POST /items, GET /items/{id})
3. Enable CORS
4. Create dev and prod stages
5. Test with curl/Postman
6. Create HTTP API and compare performance/features

## Resources
- Stephane Maarek course - API Gateway section
- AWS API Gateway documentation

## DoD
- [ ] REST API deployed with Lambda integration
- [ ] CORS configured and working
- [ ] Multiple stages (dev/prod)
- [ ] Understand REST vs HTTP API trade-offs
