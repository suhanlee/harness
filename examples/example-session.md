# Example: Harness Engineering Session

## Mission

> "Implement a REST API health check endpoint with proper Kubernetes probe configuration"

---

## Round 1

### Planner Output

```markdown
## Execution Plan (Round 1)

### Mission
Implement a REST API health check endpoint with Kubernetes liveness/readiness probe configuration.

### Analysis
- Current state: Express app exists at src/app.ts with no health endpoint
- Related files: src/app.ts, k8s/deployment.yaml, k8s/values.yaml
- Constraints: Must not break existing routes

### Task List

#### Task 1: Create health check endpoint
- Description: Add GET /health and GET /ready endpoints to the Express app
- Target files: src/app.ts, src/routes/health.ts
- Acceptance criteria:
  - [ ] GET /health returns 200 with { status: "ok" }
  - [ ] GET /ready returns 200 when DB connection is alive
  - [ ] GET /ready returns 503 when DB is unreachable
- Dependencies: none

#### Task 2: Add Kubernetes probe configuration
- Description: Configure liveness and readiness probes in the Helm chart
- Target files: k8s/deployment.yaml, k8s/values.yaml
- Acceptance criteria:
  - [ ] livenessProbe configured with /health endpoint
  - [ ] readinessProbe configured with /ready endpoint
  - [ ] Appropriate initialDelaySeconds and periodSeconds set
- Dependencies: Task 1

#### Task 3: Add tests
- Description: Unit tests for health endpoints
- Target files: src/routes/__tests__/health.test.ts
- Acceptance criteria:
  - [ ] Test for 200 response on /health
  - [ ] Test for 200 response on /ready when DB is up
  - [ ] Test for 503 response on /ready when DB is down
- Dependencies: Task 1
```

### Generator Output

```markdown
## Execution Result (Round 1)

### Completed Tasks

#### Task 1: Create health check endpoint - Done
- Changed files:
  - src/routes/health.ts (created)
  - src/app.ts (modified - added health route import)
- Self-check:
  - [x] GET /health returns 200
  - [x] GET /ready returns 200 when DB connected
  - [x] GET /ready returns 503 when DB unreachable

#### Task 2: Add Kubernetes probe configuration - Done
- Changed files:
  - k8s/deployment.yaml (modified)
  - k8s/values.yaml (modified)
- Self-check:
  - [x] livenessProbe configured
  - [x] readinessProbe configured
  - [x] Timing values set

#### Task 3: Add tests - Done
- Changed files:
  - src/routes/__tests__/health.test.ts (created)
- Self-check:
  - [x] 3 test cases written

### All Changed Files
- src/routes/health.ts (created)
- src/routes/__tests__/health.test.ts (created)
- src/app.ts (modified)
- k8s/deployment.yaml (modified)
- k8s/values.yaml (modified)

### Issues Found
- None
```

### Evaluator Output

```markdown
## Evaluation Report (Round 1)

### Verdict: FAIL
### Score: 6/10

### Criteria Verification

| # | Criterion | Verdict | Evidence |
|---|-----------|---------|----------|
| 1 | GET /health returns 200 | Met | Endpoint exists, returns { status: "ok" } |
| 2 | GET /ready checks DB | Met | Uses db.ping() to verify connection |
| 3 | GET /ready returns 503 on DB failure | Met | try/catch returns 503 |
| 4 | livenessProbe on /health | Met | Correctly configured |
| 5 | readinessProbe on /ready | Met | Correctly configured |
| 6 | Probe timing appropriate | Unmet | initialDelaySeconds: 0 is too aggressive |
| 7 | Tests cover all cases | Partial | Missing edge case: timeout scenario |

### Quality Review

#### Code Quality: 7/10
- Health route is clean and well-structured
- Missing TypeScript types for response body

#### Security: 5/10
- /health endpoint exposes internal info (Node.js version, uptime)
- No rate limiting on health endpoints

#### Completeness: 6/10
- No graceful shutdown handling
- No timeout on DB ping in readiness check

### Improvement Feedback

#### [High] Health endpoint leaks server info
- Problem: Response includes process.version and process.uptime()
- Location: src/routes/health.ts:8-12
- Fix: Return only { status: "ok", timestamp: Date.now() }

#### [High] Missing readiness probe timeout
- Problem: DB ping has no timeout, could hang indefinitely
- Location: src/routes/health.ts:18
- Fix: Add timeout option to db.ping({ timeout: 3000 })

#### [Medium] Probe initialDelaySeconds too low
- Problem: initialDelaySeconds: 0 may cause false failures during startup
- Location: k8s/deployment.yaml:45
- Fix: Set initialDelaySeconds: 10 for liveness, 5 for readiness

#### [Medium] Missing timeout test case
- Problem: No test for DB ping timeout scenario
- Fix: Add test case mocking a slow DB connection

### What Went Well
1. Clean route structure with proper separation
2. Correct use of try/catch for readiness check
3. Values.yaml properly parameterized
```

---

## Round 2

### Planner Output (revised)

```markdown
## Execution Plan (Round 2)

### Feedback Integration
- [High] Server info leak → Remove internal details from /health response
- [High] DB ping timeout → Add 3s timeout to readiness check
- [Medium] Probe timing → Adjust initialDelaySeconds
- [Medium] Missing test → Add timeout test case

### Task List

#### Task 1: Secure health endpoint response
- Target: src/routes/health.ts
- Criteria: Only return { status, timestamp }, no internal info

#### Task 2: Add DB ping timeout
- Target: src/routes/health.ts
- Criteria: db.ping() has 3000ms timeout, returns 503 on timeout

#### Task 3: Fix probe timing
- Target: k8s/deployment.yaml, k8s/values.yaml
- Criteria: liveness initialDelay=10, readiness initialDelay=5

#### Task 4: Add timeout test
- Target: src/routes/__tests__/health.test.ts
- Criteria: Test verifies 503 when DB ping times out
```

### Generator Output

*(executes all 4 tasks)*

### Evaluator Output

```markdown
## Evaluation Report (Round 2)

### Verdict: PASS
### Score: 9/10

### Criteria Verification
All 7 original + 4 new criteria: Met

### Quality Review
- Code Quality: 9/10 - Clean, typed, well-structured
- Security: 8/10 - No info leakage, reasonable timeout
- Completeness: 9/10 - All cases covered

### What Went Well
1. All Round 1 feedback properly addressed
2. Timeout handling is robust
3. Tests cover normal, error, and timeout scenarios

### Optional Improvements (not required for PASS)
- Consider adding /metrics endpoint for Prometheus
- Document health check behavior in API docs
```

---

## Final Report

```markdown
## Harness Engineering Result

### Mission
Implement a REST API health check endpoint with Kubernetes probe configuration

### Summary
- Total rounds: 2
- Final verdict: PASS
- Final score: 9/10

### Round History
| Round | Planner | Generator | Evaluator | Score |
|-------|---------|-----------|-----------|-------|
| 1 | Initial plan (3 tasks) | Implemented | FAIL | 6/10 |
| 2 | Revised plan (4 fixes) | Improved | PASS | 9/10 |

### Changed Files
- src/routes/health.ts (created)
- src/routes/__tests__/health.test.ts (created)
- src/app.ts (modified)
- k8s/deployment.yaml (modified)
- k8s/values.yaml (modified)

### Key Decisions
1. Health endpoint returns minimal info (no server internals)
2. Readiness check has 3s timeout on DB ping
3. Probe timing: liveness 10s delay, readiness 5s delay
```
