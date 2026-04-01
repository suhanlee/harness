# Harness Engineering - Design Document

## Concept

Harness Engineering is an agent orchestration pattern where **three specialized agents** collaborate in a pipeline, iterating in rounds until a mission is accomplished.

The key insight: when a single agent plans, executes, and verifies its own work, it introduces **bias** (leniency toward its own output) and **blind spots** (missing what it didn't consider). By separating these roles and adding a structured feedback loop, quality converges with each round.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                      Mission                         │
│                                                      │
│   ┌──────────┐   ┌──────────┐   ┌──────────┐       │
│   │ Planner  │ → │ Generator│ → │ Evaluator│       │
│   │ (Plan)   │   │ (Execute)│   │ (Verify) │       │
│   └──────────┘   └──────────┘   └──────────┘       │
│        ↑                              │              │
│        └───────── feedback ───────────┘              │
│                                                      │
│               Round 1 → 2 → 3 → ... → N             │
│               (until mission complete)               │
└─────────────────────────────────────────────────────┘
```

## Agent Responsibilities

### Planner (opus)

**Does:**
- Analyze mission scope and constraints
- Explore codebase to understand current state
- Break work into ordered, dependency-aware tasks
- Define measurable acceptance criteria per task
- Revise plans based on Evaluator feedback (Round 2+)

**Does NOT:**
- Write code
- Create or modify files
- Make quality judgments

### Generator (sonnet)

**Does:**
- Execute tasks in the order defined by Planner
- Write code, configuration, documentation
- Run basic checks (syntax, template rendering)
- Record issues discovered during execution

**Does NOT:**
- Evaluate its own work quality
- Perform work beyond the plan
- Modify the plan

### Evaluator (opus)

**Does:**
- Verify each acceptance criterion with evidence
- Review code quality, security, completeness
- Score the result (1-10)
- Produce actionable improvement feedback
- Issue PASS/FAIL verdict

**Does NOT:**
- Write or modify code
- Revise the plan
- Execute tasks

## Data Flow Between Agents

### Planner → Generator

The Planner hands off a structured plan:

```markdown
## Execution Plan (Round N)

### Mission
[original mission]

### Task List
1. [task] - criteria: ..., target files: ...
2. [task] - criteria: ..., depends on: Task 1

### Constraints
- ...
```

### Generator → Evaluator

The Generator reports what was done:

```markdown
## Execution Result (Round N)

### Completed Tasks
1. [task] - files changed: ..., self-check: ...

### All Changed Files
- path/to/file (created/modified/deleted)

### Issues Found
- ...
```

### Evaluator → Planner (next round)

The Evaluator provides structured feedback:

```markdown
## Evaluation Report (Round N)

### Verdict: FAIL
### Score: 6/10

### Criteria Met/Unmet
- [criterion]: Met/Unmet - evidence

### Improvement Feedback
1. [Critical] what to fix and how
2. [High] what to fix and how

### What Went Well
1. keep this as-is
```

## Round Lifecycle

### Round 1 (Initial)

1. **Planner** receives the mission, explores the codebase, produces initial plan
2. **Generator** receives the plan, executes all tasks, reports results
3. **Evaluator** receives mission + plan + results, evaluates against criteria

### Round 2+ (Iteration)

1. **Planner** receives Evaluator feedback, revises plan (adds tasks, modifies criteria)
2. **Generator** receives revised plan, performs improvement work
3. **Evaluator** re-evaluates, may issue PASS or produce further feedback

### Termination

| Condition | Trigger | Action |
|-----------|---------|--------|
| PASS | Evaluator score >= threshold (default 8) | Mission complete |
| MAX_ROUNDS | Round exceeds limit (default 5) | Report current state |
| BLOCKED | Unresolvable issue | Ask user for guidance |

## State Management

Each round's state can be tracked as:

```json
{
  "mode": "harness",
  "mission": "mission description",
  "current_round": 2,
  "max_rounds": 5,
  "status": "in_progress",
  "rounds": [
    {
      "round": 1,
      "planner": { "status": "completed", "task_count": 4 },
      "generator": { "status": "completed", "files_changed": 3 },
      "evaluator": { "status": "completed", "verdict": "FAIL", "score": 6 }
    }
  ]
}
```

## Configuration

| Parameter | Default | Description |
|-----------|---------|-------------|
| `max_rounds` | 5 | Maximum iteration count |
| `pass_threshold` | 8 | Minimum score for PASS (1-10) |
| `planner_model` | opus | Model for Planner agent |
| `generator_model` | sonnet | Model for Generator agent |
| `evaluator_model` | opus | Model for Evaluator agent |

### Tuning Guidelines

- **Simple tasks**: `max_rounds: 3`, `pass_threshold: 7`
- **Complex tasks**: `max_rounds: 7`, `pass_threshold: 8`
- **High-stakes tasks**: `max_rounds: 5`, `pass_threshold: 9`
- **Cost optimization**: `planner_model: sonnet` (slightly less thorough planning)

## Comparison with Other Patterns

| Aspect | Single Agent | Ralph Loop | Pipeline | **Harness** |
|--------|-------------|-----------|----------|-------------|
| Agent count | 1 | 1 (+verifier) | N (chain) | 3 (fixed roles) |
| Feedback loop | None | Verifier→retry | None (one-way) | Evaluator→Planner |
| Plan revision | None | Implicit | None | Explicit re-planning |
| Role separation | None | Partial | Per-stage | Strict (plan/exec/eval) |
| Quality convergence | Low | Medium | Low | High |
| Cost per round | Low | Low | Medium | High (3 agents) |
| Best for | Simple tasks | Goal completion | Sequential transforms | Complex, quality-critical |
