# AWS-003: Lambda .NET 8
**Points:** 5 | **Priority:** Critical | **Fase:** 1 | **Deps:** AWS-002

**As a** .NET developer
**I want** to master Lambda with .NET 8 runtime
**So that** I can build serverless functions efficiently

## Acceptance Criteria

**AC1:** Given a .NET 8 Lambda project, When I deploy it, Then it executes successfully and returns a valid response.
**AC2:** Given Lambda cold starts, When asked about optimization techniques, Then I can explain and implement at least 3 strategies (SnapStart, trimming, reduced memory).
**AC3:** Given environment variables and configuration, When I need runtime config, Then I use env vars and/or Parameter Store correctly.
**AC4:** Given a Lambda function, When I test locally, Then I can use SAM local invoke or the Lambda test tool.

## Study Topics
- Lambda execution model (handler, context, event)
- .NET 8 runtime on Lambda (managed runtime vs container)
- Cold starts: causes, measurement, mitigation
  - SnapStart for .NET (if available)
  - ReadyToRun compilation
  - Trimming and AOT considerations
  - Memory allocation impact on CPU
- Lambda Layers (.NET shared libraries)
- Environment variables and configuration
- Lambda Destinations and Dead Letter Queues
- Concurrency (reserved vs provisioned)
- Lambda pricing model (requests + duration + memory)
- Logging with ILambdaContext.Logger
- .NET Lambda tools (`dotnet lambda` CLI)
- Lambda function URLs vs API Gateway

## Lab
1. Install Amazon.Lambda.Tools (`dotnet tool install -g Amazon.Lambda.Tools`)
2. Create Lambda from template (`dotnet new lambda.EmptyFunction`)
3. Implement a handler that processes an API Gateway event
4. Deploy to AWS
5. Test with different memory configurations (128MB, 256MB, 512MB)
6. Measure cold start vs warm invocation times
7. Add environment variables, read from handler
8. Implement structured logging

## Resources
- Stephane Maarek course - Lambda section
- AWS Lambda .NET documentation
- https://github.com/aws/aws-lambda-dotnet

## DoD
- [ ] Lambda deployed and working
- [ ] Cold start measured and optimization applied
- [ ] Environment variables used correctly
- [ ] Can explain Lambda pricing model
- [ ] Structured logging implemented
