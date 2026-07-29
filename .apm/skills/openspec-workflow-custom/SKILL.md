---
name: openspec-workflow-custom
description: OpenSpec Workflow — Specification-Driven Change Management (Enhanced). change management workflow that guides you from idea → exploration → proposal → design → tasks → implementation → verification → archive
version: 1.0.0  
---
# OpenSpec Workflow — Specification-Driven Change Management (Enhanced)

## 🎯 Core Philosophy

**"Write specifications BEFORE coding. Get approval at each phase. Then implement with confidence."**

OpenSpec is a specification-driven change management workflow that guides you from idea → exploration → proposal → design → tasks → implementation → verification → archive. Every code change needs a proposal first. Code comes after.

### Fundamental Principles

1. **No proposal, no changes** — Never modify code without a matching proposal
2. **No proposal, no edits** — Before editing any file, confirm a change directory exists under `openspec/changes/`
3. **Explore before committing** — Discuss freely, then freeze decisions progressively
4. **Freeze progressively** — Each artifact batch is reviewed and frozen before the next (via @openspec-reviewer)
5. **Agent executes tests** — The coding agent MUST run all tests itself, never delegate to the user
6. **Archive when complete** — Preserve all artifacts for traceability

---

## 🔄 The Unified Workflow

```
EXPLORE (optional)
  └─ Discuss, investigate, build explore-brief.md
      └─ PROPOSE
           └─ Create proposal.md
               └─ [REVIEW by @openspec-reviewer] ✅
                   └─ DESIGN
                        └─ Create design.md, specs/, tasks.md (3 batches)
                            └─ [REVIEW by @openspec-reviewer per batch] ✅
                                └─ APPLY
                                     └─ Implement tasks
                                         └─ [Execute tests - agent only] ✅
                                             └─ VERIFY
                                                  └─ Check implementation matches specs
                                                      └─ ARCHIVE
                                                           └─ Done ✅
```

---

## 🧰 The `openspec-*` Skill Catalog

| Skill | Purpose | When to Use |
|---|---|---|
| `openspec-explore` | Enter thinking-partner mode | User wants to discuss / brainstorm |
| `openspec-new-change` | Scaffold a new change | Starting a brand-new feature/fix |
| `openspec-continue-change` | Create the **next** artifact | Stepping through artifacts one by one |
| `openspec-ff-change` | Fast-forward through all artifacts | Create everything needed for apply in one go |
| `openspec-apply-change` | Implement tasks from `tasks.md` | Coding phase |

### Underlying CLI Commands (used internally by skills)

| Command | Purpose |
|---|---|
| `openspec new change "<name>"` | Scaffold a change directory |
| `openspec list --json` | List active changes |
| `openspec schemas --json` | List available workflow schemas |
| `openspec status --change "<name>" --json` | Get artifact status, paths, next steps |
| `openspec instructions <artifact-id> --change "<name>" --json` | Get template + rules for an artifact |

---

## 📖 Phase 0: EXPLORE (Optional but Recommended)

**Skill:** `openspec-explore`
**Trigger:** User says _"let's think about it"_, _"let's discuss"_, or _"explore"_

### Purpose
Free-form discussion — no coding, no file edits, no proposals yet. Just talk through the problem. This is a **stance**, not a workflow: curious, visual, adaptive, patient, grounded in the real codebase.

### Stance Principles
- 🧠 **Curious, not prescriptive** — ask questions that emerge naturally
- 🧵 **Open threads, not interrogations** — surface multiple directions
- 🎨 **Visual** — use ASCII diagrams liberally
- 🔀 **Adaptive** — pivot when new information emerges
- 🕰️ **Patient** — let the shape of the problem emerge
- 🌍 **Grounded** — explore the actual codebase, not just theory

### What You Might Do
- Explore the problem space (challenge assumptions, reframe, find analogies)
- Investigate the codebase (map architecture, find integration points, surface complexity)
- Compare options (brainstorm approaches, build comparison tables, sketch tradeoffs)
- Visualize with ASCII diagrams (state machines, data flows, dependency graphs)
- Surface risks and unknowns (gaps in understanding, suggested spikes)

### OpenSpec Awareness During Explore

**At the start, check context:**
```bash
openspec list --json
```

**When no change exists:** think freely. When insights crystallize, offer:
> "This feels solid enough to start a change. Want me to create a proposal?"

**When a change exists:** resolve and read existing artifacts, run `openspec status --change "<name>" --json`, reference `changeRoot`, `artifactPaths`, and `actionContext` naturally in conversation.

### Capture Decisions When Made

| Insight Type | Where to Capture |
|---|---|
| New requirement discovered | `specs/<capability>/spec.md` |
| Requirement changed | `specs/<capability>/spec.md` |
| Design decision made | `design.md` |
| Scope changed | `proposal.md` |
| New work identified | `tasks.md` |
| Assumption invalidated | Relevant artifact |

> 💡 **Offer to capture, don't auto-capture.** The user decides.

### Exit Criteria → Produce `explore-brief.md`

When the discussion feels solid and you're about to move to propose, write **half a page max** at:
```
openspec/changes/<change-name>/explore-brief.md
```

### Mandatory Contents of `explore-brief.md`

This brief serves as the **checklist baseline** for all artifact reviews. Include:

- ✅ **Alternatives rejected** — list each approach discussed and _why_ it was rejected
- ✅ **Full labels / dimensions / mapping tables** — list everything, no "e.g." (e.g., all state labels, all enum values, all mappings)
- ✅ **Key cross-module data flows** — who calls who, what parameters get passed, error flows
- ✅ **Known open questions** — unresolved items that will be addressed in artifacts

> 💡 @openspec-reviewer will check every artifact batch against this brief to ensure nothing was missed during transcription.

### Hard Rules for Explore Mode
- 🚫 **No coding** — do not create proposals, do not edit code files, do not write tests
- ✅ **Creating OpenSpec artifacts is allowed** — that's capturing thinking, not implementing
- ✅ **Reading files, searching code, and investigating is allowed**

---

## 📝 Phase 1: PROPOSE (Start a New Change)

**Skill:** `openspec-new-change`
**CLI:** `openspec new change "<name>"`
**Output:** `openspec/changes/<change-name>/proposal.md` (≤ 800 words)

### Step-by-Step

1. **If no clear input provided**, ask what they want to build:
 > "What change do you want to work on? Describe what you want to build or fix."

2. **Derive a kebab-case name** from the description (e.g., "add user authentication" → `add-user-auth`)

3. **Determine the workflow schema:**
 - Use the default schema (omit `--schema`) unless the user explicitly requests a different workflow
 - If user says "show workflows" → run `openspec schemas --json` and let them choose
 - Otherwise: omit `--schema`

4. **Create the change directory:**
 ```bash
   openspec new change "<name>"
   ```

5. **Show artifact status:**
 ```bash
   openspec status --change "<name>" --json
   ```
 Use the returned `planningHome`, `changeRoot`, `artifactPaths`, and `nextSteps`.

6. **Get instructions for the first artifact** (typically `proposal`):
 ```bash
   openspec instructions <first-artifact-id> --change "<name>"
   ```

7. **STOP and wait for user direction** — do NOT create any artifacts yet.

### What Every Proposal Must Include
| Artifact | Purpose |
|---|---|
| `proposal.md` | Why the change is needed + what's in scope |
| `design.md` | The design approach |
| `tasks.md` | Concrete task checklist |
| `.openspec.yaml` | Change metadata |

### Proposal Template
```markdown
# Proposal: <change-name>

## Problem
<What is broken or missing?>

## Solution
<High-level approach>

## Impact
- <Business impact 1>
- <Business impact 2>

## Scope
### In Scope
- ...
### Out of Scope
- ...

## Capabilities
- <capability-1> (will need specs/<capability-1>/spec.md)
- <capability-2> (will need specs/<capability-2>/spec.md)

## Risks & Open Questions
- ...
```

---

## 🏗️ Phase 2: DESIGN (Artifacts Creation with Review)

You have **two paths** to create the remaining artifacts:

### Path A: Step-by-Step (Recommended for complex changes)
**Skill:** `openspec-continue-change`

Creates **ONE artifact per invocation** in dependency order, with review between batches.

### Path B: Fast-Forward (For well-understood changes)
**Skill:** `openspec-ff-change`

Creates **ALL artifacts needed for apply** in one go, then review.

---

## 🔍 The Review Flow (Both Paths)

### Batch Creation Order (STRICT)

Create and review in this exact order — **never skip or reorder**:

| Batch | Artifact(s) | Review Against | Frozen After |
|---|---|---|---|
| **2a** | `proposal.md` | `explore-brief.md` | Pass 2a review |
| **2b** | `design.md` | frozen `proposal.md` + `explore-brief.md` | Pass 2b review |
| **2c** | `specs/*.md` | frozen `proposal.md` + `design.md` + `explore-brief.md` | Pass 2c review |
| **2d** | `tasks.md` | ALL previously frozen artifacts + `explore-brief.md` | Pass 2d review |

### The Review Checklist (for ALL Batches)

Before calling @openspec-reviewer, the main agent MUST read `explore-brief.md` and go through this checklist to ensure the artifact batch covers all commitments:

- ✅ **Alternatives rejected** — does the artifact explain why each rejected approach wasn't chosen?
- ✅ **Full labels/dimensions/mappings** — are ALL labels, states, mappings from the brief present (no gaps)?
- ✅ **Cross-module data flows** — are all data flows documented (who calls who, params, error handling)?
- ✅ **Open questions** — are they resolved in artifacts or marked as ongoing risks?

> 💡 This checklist prevents gaps during artifact creation and speeds up reviews.

### Calling @openspec-reviewer

**When:** Immediately after creating a batch.

**How to call:**

1. **State what's frozen and what's new:**
   - "Batch 2a (proposal.md): First batch, no prior artifacts frozen yet."
   - "Batch 2b (design.md): Frozen artifacts: proposal.md. New artifact this round: design.md."

2. **Attach explore-brief.md** as the baseline (always).

3. **Attach all relevant artifacts:**
   - Frozen artifacts (for consistency checks)
   - Newly created artifacts (what's being reviewed)

**Example call:**
```
Calling @openspec-reviewer for Batch 2a.

Baseline: explore-brief.md
Newly created: proposal.md
No previously frozen artifacts.

Please review against the brief.
```

### What @openspec-reviewer Returns

A `review-log.md` entry with findings:

```markdown
## proposal Round 1 — 2026-06-25 14:30

### 🔴 Fixed
- (nothing yet, first round)

### 🟡 Addressed
- (minor notes)

### 🔴 Outstanding
- <serious issue 1>
- <serious issue 2>

---
```

### Passing vs. Failing

**PASSING (Batch Freezes):**
- After review, `### 🔴 Outstanding` section is **empty or doesn't exist**
- Batch is immediately frozen
- Move to next batch

**FAILING (Fix Loop):**
- After review, `### 🔴 Outstanding` section has issues
- Main agent fixes them (touching ONLY current batch, never frozen artifacts)
- Main agent calls @openspec-reviewer again
- Repeat until passing

**Hard Cap:** If same batch fails after 5 review rounds, hand off to user with three options (force freeze, rollback, or add round).

---

## 📋 Phase 3: TASKS (Mandatory Steps Enforcement)

**Skill:** `openspec-continue-change` (or `openspec-ff-change`)
**Output:** `tasks.md`
**Granularity:** Each task 2–4 hours max (200–400 LOC)

### ⚠️ MANDATORY: Read `openspec/config.yaml` FIRST

Before creating or updating any `tasks.md`, you MUST read `openspec/config.yaml` to understand:
- Layer-specific mandatory steps
- Branch naming conventions
- Task sizing guidelines
- Testing and documentation requirements

### Mandatory Steps Structure (MUST appear in every `tasks.md`)

```markdown
## 0. Setup: Create Feature Branch (MANDATORY - FIRST STEP)
- [ ] 0.1 Create branch `feature/<change-name>` or `feature/<ticket-id>` from main
- [ ] 0.2 Verify branch creation

## 1..N-4. Layer Implementation Tasks
<Domain → Application → Adapter → Deployment → Presentation>

## N-3. Review and Update Existing Unit Tests (MANDATORY)

## N-2. Run Unit Tests and Verify Database State (MANDATORY)
- [ ] N-2.1 Capture pre-test baseline
- [ ] N-2.2 Run targeted unit tests
- [ ] N-2.3 Run broader required suite
- [ ] N-2.4 Verify post-test state, restore if needed
- [ ] N-2.5 Create report: `specs/<change-name>/reports/YYYY-MM-DD-step-N-2-unit-test-verification.md`
- [ ] N-2.6 Mark complete only after tests pass AND report exists

## N-1. Manual Integration Testing (MANDATORY - AGENT MUST EXECUTE)
- [ ] N-1.1 Ensure services are running
- [ ] N-1.2 Test API endpoints via curl
- [ ] N-1.3 Verify request/response formats + status codes
- [ ] N-1.4 Test CREATE/UPDATE/DELETE with state restoration
- [ ] N-1.5 Test error scenarios and edge cases
- [ ] N-1.6 Document scenarios + outcomes
- [ ] N-1.7 Verify data integrity

## N+1. Update Technical Documentation (MANDATORY - FINAL STEP)
```

### Verification Checklist Before Finalizing `tasks.md`
- [ ] Step 0 (Create Feature Branch) is FIRST
- [ ] All mandatory steps from `config.yaml` included
- [ ] Steps numbered sequentially (0, 1, 2, ..., N)
- [ ] Mandatory steps labeled `(MANDATORY)`
- [ ] Branch naming follows `feature/[name]` convention
- [ ] Test verification steps include proper report path + naming
- [ ] Manual testing steps state **"AGENT MUST EXECUTE"**
- [ ] Tasks include state/data restoration for mutations
- [ ] E2E/UI steps included if frontend changes involved
- [ ] Documentation update is final step

---

## ⚙️ Phase 4: IMPLEMENTATION

**Skill:** `openspec-apply-change`
**Prerequisite:** All artifacts created and frozen (proposal, design, specs, tasks)

### How `openspec-apply-change` Works

1. **Select the change:**
 - If a name is provided, use it
 - Otherwise infer from conversation context
 - If ambiguous, run `openspec list --json` and let the user select
 - Always announce: "Using change: `<name>`"

2. **Check status to understand the schema:**
 ```bash
   openspec status --change "<name>" --json
   ```
 Parse `schemaName`, `planningHome`, `changeRoot`, `actionContext`, and identify which artifact contains the tasks.

3. **Get apply instructions:**
 ```bash
   openspec instructions apply --change "<name>" --json
   ```
 Returns:
 - `contextFiles`: artifact ID → array of concrete file paths
 - Progress (total, complete, remaining)
 - Task list with status
 - Dynamic instruction based on current state

4. **Handle states:**
 - `state: "blocked"` (missing artifacts) → suggest `openspec-continue-change`
 - `state: "all_done"` → congratulate, suggest archive
 - Otherwise → proceed to implementation

5. **Workspace guard:** If `actionContext.mode: "workspace-planning"` and `allowedEditRoots` is empty → explain that full workspace apply is not supported. Treat linked repos as read-only context. STOP before editing files.

6. **Read context files** (proposal, specs, design, tasks).

7. **Show current progress** and dynamic instruction from CLI.

8. **Implement tasks (loop until done or blocked):**
 - Show which task is being worked on
 - Make the code changes required (minimal and focused)
 - Mark task complete in the tasks file: `- [ ]` → `- [x]`
 - Continue to next task
 - **Pause if:** task is unclear, implementation reveals a design issue, error/blocker encountered, user interrupts

### Execution Rules
1. **Implement one task at a time** — each task = separate PR
2. **Never merge multiple tasks in one PR**
3. **Reference project skills** from `.kiro/skills/` and agents from `.kiro/agents/`
4. **Keep going through tasks until done or blocked**
5. **Update task checkbox immediately after completing each task**
6. **Pause on errors, blockers, or unclear requirements — don't guess**

### 🧪 Mandatory Test Execution (Agent MUST Do Itself)

#### Step N-2: Unit Tests + DB Verification
**Agent Responsibility:** Execute tests, validate DB integrity, produce report.

**Report Template** → `specs/<change-name>/reports/YYYY-MM-DD-step-N-2-unit-test-verification.md`
```markdown
# Step N-2 Report — Unit Tests and Database Verification

- **Date:** YYYY-MM-DD
- **Change:** <change-name>
- **Agent:** <agent-name>

## Commands Executed
- `<command 1>`
- `<command 2>`

## Unit Test Results
- Targeted tests: X passed, Y failed, Z skipped
- Full suite: X passed, Y failed, Z skipped
- Runtime: <duration>
- Notes: <flaky tests, retries, exceptions>

## Database State Verification
- Pre-test baseline:
  - <metric/table>: <value>
- Post-test validation:
  - <metric/table>: <value>
- State restored: Yes/No
- Restoration actions: <actions>

## Outcome
- Status: PASS/FAIL
- Blocking issues: <none or list>
```

#### Step N-1: Manual Endpoint Testing with `curl`
**Agent MUST execute all curl commands — NEVER delegate to user.**

| Operation | curl Pattern | Restore Action |
|---|---|---|
| **GET** | `curl -X GET <url> <headers>` | None (read-only) |
| **POST** | `curl -X POST <url> -H "Content-Type: application/json" -d '<body>'` | DELETE created record |
| **PUT/PATCH** | `curl -X PUT <url> -H "Content-Type: application/json" -d '<body>'` | Revert to original values |
| **DELETE** | `curl -X DELETE <url>` | Recreate deleted record |

**Must also test:** invalid data (400/422), non-existent resources (404), unauthorized access (401/403).

---

## 🔍 Phase 5: VERIFY

**Purpose:** Confirm implementation matches the proposal + design + specs.

- Run /adversarial-review, do the verification pass before archiving an OpenSpec change
- Run /code-auditing, do the verification of systematic code quality audits.

### Verification Checklist
- [ ] All acceptance criteria from `requirements.md` pass
- [ ] No architectural violations
- [ ] All unit tests green
- [ ] All manual endpoint tests pass
- [ ] Documentation updated

---

## 📦 Phase 6: ARCHIVE

**Purpose:** Mark the change as complete and preserve artifacts.

### What Happens
- Marks change as complete
- Moves all artifacts to `openspec/changes/<change-name>/archived/`
- Preserves metadata for reference

---

## 🧊 Freeze & Unfreeze Rules (Critical)

### Freeze
Once a batch of artifacts passes @openspec-reviewer review → **frozen**. All subsequent reviews use frozen artifacts as baseline.

### Soft Freeze — Declarative Additions Allowed
After freezing, you may append **declarative content** without unfreezing:
- ✅ Adding missing mapping tables / keyword lists / complete enumerations
- ✅ Fixing typos
- ✅ Adding missing scenarios or examples
- ✅ Adding boundary condition descriptions

**The Test:** _Would this change cause an implementer to write different code?_
- **No** → declarative (allowed)
- **Yes** → decision-level (forbidden without unfreeze)

### Decision-Level Changes (Require Full Unfreeze)
- ❌ Changing algorithms
- ❌ Changing label semantics
- ❌ Changing module responsibility boundaries
- ❌ Adding/removing capabilities

### Unfreeze
If a later review finds a frozen artifact needs a decision-level change:
1. **Unfreeze** that artifact AND all artifacts that came after it
2. **Re-review in batches** starting from the unfreeze point

### Change Isolation
When fixing review issues:
- Only modify current batch + unfrozen files
- For frozen artifacts: only declarative additions allowed
- Never touch decision-level content in frozen artifacts

---

## 🚨 When Things Go Wrong — STOP Immediately

Stop and notify the user if ANY of these happen:
- 🚨 Code is being modified without a proposal
- 🚨 Files are being edited in explore mode
- 🚨 Files outside the current proposal's scope are being modified
- 🚨 Agent tries to delegate testing to the user
- 🚨 Tasks created without reading `openspec/config.yaml`
- 🚨 Name is invalid (not kebab-case) → ask for a valid name
- 🚨 Change with that name already exists → suggest continuing that change instead
- 🚨 A batch has been reviewed 5+ times and still isn't passing → hand off to user with options

---

## 🧩 Common Patterns

### Pattern 1: New API Endpoint or Feature (Step-by-Step)
```bash
openspec-explore                                    # optional: discuss first
openspec-new-change add-new-endpoint                # scaffold + show first artifact
openspec-continue-change                            # create proposal.md → review
openspec-continue-change                            # create specs/ → review
openspec-continue-change                            # create design.md → review
openspec-continue-change                            # create tasks.md → review
openspec-apply-change                               # implement tasks
# verify → archive
```

### Pattern 2: New Feature (Fast-Forward)
```bash
openspec-new-change add-new-endpoint                # scaffold
openspec-ff-change add-new-endpoint                 # create all artifacts → review each batch
openspec-apply-change                               # implement tasks
# verify → archive
```

### Pattern 3: Bug Fix
> ⚠️ **Exception:** Bug fixes don't need a full proposal — this hard rule applies to **feature changes only**.

```bash
openspec-new-change fix-bug-description
openspec-continue-change                            # (repeat until tasks done)
openspec-apply-change
# verify → archive
```

### Pattern 4: Refactoring / Technical Debt
```bash
openspec-new-change refactor-component
openspec-continue-change                            # (repeat until tasks done)
openspec-apply-change
# verify → archive
```

### Pattern 5: Resume an Existing Change
```bash
openspec-continue-change                            # will prompt to select from recent changes
openspec-apply-change                               # if tasks already exist
```

---

## 📚 Available Commands & Skills

### Skills (`openspec-*`)

| Skill | Purpose | Creates/Does |
|---|---|---|
| `openspec-explore` | Enter thinking-partner mode | `explore-brief.md` (optional) |
| `openspec-new-change` | Scaffold a new change | Change directory + first artifact instructions |
| `openspec-continue-change` | Create the NEXT artifact | One artifact per invocation + review checkpoint |
| `openspec-ff-change` | Fast-forward all artifacts | All apply-required artifacts + review each batch |
| `openspec-apply-change` | Implement tasks | Code + tests + reports |

### CLI Commands

| Command | Purpose |
|---|---|
| `openspec new change "<name>"` | Scaffold a change |
| `openspec list --json` | List active changes |
| `openspec schemas --json` | List available schemas |
| `openspec status --change "<name>" --json` | Get artifact status + paths |
| `openspec instructions <id> --change "<name>" --json` | Get artifact template + rules |

---

## 🗂️ Key Files Referenced During Workflow

OpenSpec automatically loads context from:

| Path | Purpose |
|---|---|
| `.kiro/steering/project-context.md` | Project setup |
| `openspec/config.yaml` | Layer-specific mandatory steps |
| `.kiro/external/architecture/` | Architecture patterns |
| `.kiro/external/coding-standards/` | Coding standards |
| `.kiro/external/testing/` | Testing standards |
| `.kiro/agents/` | Project-specific agents |
| `.kiro/skills/` | Project-specific skills |

---

## ✅ Success Criteria (End-to-End)

| Phase | Criteria |
|---|---|
| **Explore** | Brief covers alternatives, mappings, data flows, open questions |
| **Propose** | Proposal passes review (via @openspec-reviewer) |
| **Design** | Design + specs pass review (via @openspec-reviewer) |
| **Tasks** | 2–4 hour chunks, each with tests, passes review (via @openspec-reviewer) |
| **Implementation** | All tests pass, agent executed tests, code reviewed, no architectural violations |
| **Verify** | Implementation matches proposal + design |
| **Archive** | All artifacts saved, change complete |

## 📖 Additional Documentation

- **`openspec-review-protocol.md`** — Detailed guide for @openspec-reviewer integration, review checklist, batch review order, and passing criteria.

---

> 💡 **Remember:** Every code change needs a proposal first. Code comes after. The agent executes all tests. Never delegate. Freeze progressively via reviews. Archive everything.