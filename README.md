# Harness Engineering

**3-Agent Pipeline Pattern for Claude Code**

An agent orchestration pattern where three specialized agents — Planner, Generator, and Evaluator — collaborate in a pipeline, iterating in rounds until the mission is accomplished.

```
Planner(opus) → Generator(sonnet) → Evaluator(opus)
    ↑                                      │
    └──────────── feedback ────────────────┘
                Round 1 → 2 → ... → N (until mission complete)
```

## Why Harness Engineering?

When a single agent plans, executes, and verifies its own work, it introduces **bias** and **blind spots**.

| Problem | Cause | Harness Solution |
|---------|-------|-----------------|
| Lenient self-evaluation | Executor = Verifier | Role separation (Generator ≠ Evaluator) |
| One-way progress without feedback | No feedback loop | Structured Evaluator → Planner feedback |
| Patching without plan revision | Implicit retry | Explicit re-planning by Planner based on feedback |
| Ambiguous completion criteria | No definition | Measurable acceptance criteria + scoring system |

## Agent Roles

| Agent | Role | Model | Core Principle |
|-------|------|-------|----------------|
| **Planner** | Analyze mission, create execution plan, revise based on feedback | opus | Does NOT write code |
| **Generator** | Execute the plan (code, config, docs) | sonnet | Does NOT evaluate, follows plan only |
| **Evaluator** | Verify output, issue PASS/FAIL verdict, provide feedback | opus | Does NOT modify code |

## Installation

### Option 1: Claude Code Plugin Marketplace (Recommended)

Install directly from GitHub inside Claude Code:

```bash
# 1. Add marketplace
/plugin marketplace add suhanlee/harness

# 2. Install plugin
/plugin install harness@harness-engineering

# 3. Reload plugins
/reload-plugins
```

The `/harness` command is ready to use after installation.

### Option 2: Install Script

```bash
curl -fsSL https://raw.githubusercontent.com/suhanlee/harness/main/install.sh | bash
```

### Option 3: Manual File Copy

```bash
# From your project root
mkdir -p .claude/commands .claude/skills
cp -r harness/.claude/commands/harness.md .claude/commands/
cp -r harness/.claude/skills/harness-* .claude/skills/
```

### Option 4: Git Submodule

```bash
git submodule add https://github.com/suhanlee/harness.git .harness
# Then copy or symlink files into .claude/
```

## Usage

### Autopilot Mode (Default)

Just provide the mission — Harness auto-analyzes the task and determines the optimal configuration:

```bash
/harness Implement a data collection pipeline for the budget-eats service
```

Autopilot will:
1. **Analyze** the mission scope (files affected, complexity, work areas)
2. **Classify** the size (S / M / L / XL)
3. **Auto-configure** rounds, pass threshold, and agent counts
4. **Execute** immediately without waiting for confirmation

```
## Autopilot Analysis

Mission: Implement data collection pipeline
Size: M (Medium) — ~8 files, 2 work areas
Estimated token budget: ~150K

Auto-configured:
- Max rounds: 3
- Pass threshold: 8/10
- Agents: 1 Planner, 1 Generator, 1 Evaluator

Starting Round 1...
```

#### Autopilot Size Classification

| Size | Files | Complexity | max_rounds | threshold | Planners | Generators | Evaluators |
|------|-------|------------|-----------|-----------|----------|------------|------------|
| **S** | 1-3 | Single concern | 2 | 7 | 1 | 1 | 1 |
| **M** | 4-10 | Multiple concerns | 3 | 8 | 1 | 1 | 1 |
| **L** | 11-25 | Cross-cutting | 5 | 8 | 1 | 2 | 1 |
| **XL** | 25+ | System-wide | 7 | 8 | 1 | 3 | 2 |

### Manual Mode

Use `--manual` or specify `--rounds`/`--threshold` to override autopilot:

```bash
# Explicit manual mode
/harness --manual --rounds 3 Implement user authentication

# Specifying --rounds implies manual mode
/harness --rounds 7 --threshold 9 Build the payment API

# Override agent counts
/harness --generators 3 Refactor the auth module

# Custom model configuration
/harness --manual --rounds 3 --planner-model sonnet Fix the deployment pipeline
```

### All Options

| Option | Description | Default |
|--------|-------------|---------|
| `--manual` | Use manual mode (skip auto-analysis) | off (autopilot) |
| `--rounds N` | Maximum iteration count (implies manual) | 5 |
| `--threshold N` | Minimum score for PASS, 1-10 (implies manual) | 8 |
| `--planner-model MODEL` | Model for Planner agent | opus |
| `--generator-model MODEL` | Model for Generator agent | sonnet |
| `--evaluator-model MODEL` | Model for Evaluator agent | opus |
| `--planners N` | Number of parallel Planner agents | 1 |
| `--generators N` | Number of parallel Generator agents | 1 |
| `--evaluators N` | Number of parallel Evaluator agents | 1 |

### Parallel Agents

When multiple agents of the same role are configured:

- **Multiple Generators** — Planner's task list is partitioned by work area; Generators run in parallel
- **Multiple Evaluators** — Each reviews a different aspect (correctness vs. quality); scores are averaged
- **Multiple Planners** — Each produces an independent plan; plans are merged into consensus

### Add to CLAUDE.md (Optional)

Add the following to your project's `CLAUDE.md` so Claude Code automatically recognizes the pattern:

```markdown
## Agent Execution Pattern: Harness Engineering

For complex tasks, apply the **Harness Engineering** pattern.
Three specialized agents collaborate in a pipeline, iterating until mission complete.

Planner(opus) → Generator(sonnet) → Evaluator(opus) → [feedback] → Planner → ...

Termination: Evaluator issues PASS verdict or max rounds reached.
Default mode: autopilot (auto-determines rounds and agent counts based on task size).
```

## Execution Flow

### Round 1 (Initial)

```
Mission
  │
  ▼
┌──────────┐
│ Planner  │  Analyze mission → Break into tasks → Define acceptance criteria
└────┬─────┘
     │ Execution plan
     ▼
┌──────────┐
│Generator │  Write code/config/docs per plan
└────┬─────┘
     │ Output
     ▼
┌──────────┐
│Evaluator │  Verify against criteria → Score
└────┬─────┘
     │
     ▼
  PASS(8+) → Done
  FAIL(<8) → Round 2
```

### Round 2+ (Iteration)

```
Evaluator feedback
  │
  ▼
┌──────────┐
│ Planner  │  Integrate feedback → Revise plan
└────┬─────┘
     │ Revised plan
     ▼
┌──────────┐
│Generator │  Execute improvements
└────┬─────┘
     │ Improved output
     ▼
┌──────────┐
│Evaluator │  Re-verify → Re-score
└────┬─────┘
     │
     ▼
  PASS → Done  /  FAIL → Round 3...
```

## When to Use

### Good Fit

- Complex feature implementation (many files changed)
- Quality-critical tasks (security, performance)
- Ambiguous requirements needing iterative refinement
- Tasks involving architectural changes

### Not a Good Fit

- Simple bug fixes (1-2 files)
- Configuration value changes
- Documentation edits
- Small tasks with clear instructions

## Comparison with Other Patterns

| Aspect | Single Agent | Ralph Loop | Pipeline | **Harness** |
|--------|-------------|-----------|----------|-------------|
| Agent count | 1 | 1 (+verifier) | N (chain) | 3 (fixed roles) |
| Feedback loop | None | Verifier→retry | None | Evaluator→Planner |
| Plan revision | None | Implicit | None | Explicit re-planning |
| Role separation | None | Partial | Per-stage | Strict separation |
| Quality convergence | Low | Medium | Low | High |
| Auto-scaling | No | No | No | Yes (autopilot) |

## File Structure

```
harness/
├── README.md                              # This document
├── LICENSE                                # MIT License
├── install.sh                             # Installation script
├── .claude-plugin/
│   ├── marketplace.json                   # Claude Code marketplace manifest
│   └── plugin.json                        # Plugin metadata
├── .claude/
│   ├── commands/
│   │   └── harness.md                     # /harness command (orchestrator)
│   └── skills/
│       ├── harness-planner/SKILL.md       # Planner agent skill
│       ├── harness-generator/SKILL.md     # Generator agent skill
│       └── harness-evaluator/SKILL.md     # Evaluator agent skill
├── docs/
│   └── harness-engineering.md             # Detailed design document
└── examples/
    └── example-session.md                 # Example session walkthrough
```

## License

MIT
