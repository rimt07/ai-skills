# Development Workflow — Platform Reservation API

A walkthrough of how work gets done in this repository, told through the lens of **JIRA-ID-123** (the Reservation Store foundation). It covers the Spec-Driven Development (SDD) approach powered by OpenSpec, the Kiro skills, custom sub-agents, and the automation hooks that keep the process consistent and compliant.

> Worked example throughout: **JIRA-ID-123 — Create endpoints feature** on branch `feature/JIRA-ID-123`, change `feature-create-endpoints`.

---

## 0. Prerequisites & one-time setup

Before the SDD workflow can run, the OpenSpec CLI, the Kiro skills, and the supporting code-intelligence tooling have to be installed and the project initialized. The full, runnable procedure lives in the PowerShell notebook [`init_project.ipynb`](https://github.com/rimt07/ai-skills/blob/main/init_project.ipynb) (rimt07/ai-skills). This section summarizes it; run the notebook for the authoritative, copy-pasteable cells.

### 0.1 Environment prerequisites

- **Windows with PowerShell 7+**
- **Jupyter Notebook** (to run the setup notebook). In VS Code, install the [Polyglot Notebooks extension](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.dotnet-interactive-vscode) so the `.NET (PowerShell)` kernel is available.
- **Internet access**

Minimum tool versions the notebook checks in **Stage 1 — dependency verification**:

| Tool | Minimum version |
|---|---|
| Python | 3.13.0 |
| Node.js | 20.0.0 |
| npm | 10.0.0 |
| Git | 2.40.0 |
| uv | 0.7.0 |

The notebook fails fast if any tool is missing from `PATH` or below the minimum.

### 0.2 Install the global tools (Stage 2)

```powershell
# Serena — semantic code intelligence MCP server
uv tool install -p 3.13 serena-agent

# Graphify — code/doc knowledge graph
uv tool install graphify
graphify install --platform windows

# Codeburn
npm install -g codeburn

# OpenSpec — the SDD engine (CLI)
npm install -g @fission-ai/openspec@latest

# OpenSpec UI
npm install -g openspecui

# CodeGraph — symbol graph MCP server
irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex

# Claude Code History Viewer (optional — inspect prior session history)
#   installed from the latest GitHub release (jhlee0409/claude-code-history-viewer)
```

The notebook guards each install (`Get-Command <tool>`) so re-runs are idempotent; set `$Force = $true` to force reinstalls.

### 0.3 Initialize the project (Stage 3)

Run from the repo root (`C:\dev\repo_folder`):

```powershell
# 3.1 Submodules (pulls dev-standards )
git submodule update --init --recursive

# 3.2 Serena — create/index the project
serena project create --name platform-reservation-api
#   fallback if create fails:  serena project index

# 3.3 CodeGraph — build the symbol graph
codegraph init -i

# 3.4 Graphify — extract graph + install the agent hook
graphify .
graphify hook install
graphify claude install    # CLAUDE.md + PreToolUse hook
graphify cursor install    # rule to read GRAPH_REPORT.md
```

### 0.4 Initialize OpenSpec + install the skills

Run these **directly in the terminal** from the repo root:

```powershell
# Initialize OpenSpec for Kiro (--tools is optional)
openspec init --tools kiro

# Custom workflow requires configuring the profile (Workflow Patterns / Expanded Mode)
openspec config profile

# Pull the latest OpenSpec templates/instructions
openspec update
```

Then install the shared skills straight from the git repo with the `skills` tool. This is what populates `.kiro/skills/` and the specialist skills used across the workflow:

```powershell
npx skills add rimt07/ai-skills --skill '*' -y -a kiro-cli -g
```

The skill set installed this way includes: `adversarial-review`, `code-auditing`, `commit`, `enrich-us`, `explain`, `meta-prompt`, `owasp-security-audit`, `run-parallel-tasks`, `show-spec-working`, `sync-agent-symlinks`, `update-docs`, `using-git-worktrees`, and `writing-skills` — alongside the `openspec-*` skills that drive the SDD lifecycle described below.

### 0.5 Verify the install

```powershell
foreach ($tool in @("serena","graphify","codeburn","openspec","openspecui","codegraph")) {
    if (Get-Command $tool -ErrorAction SilentlyContinue) { "OK $tool" } else { "MISSING $tool" }
}
```

Once every tool resolves and `openspec init` has created the `openspec/` scaffold, the project is ready for the spec-first workflow.

---

## 1. The big picture

Development here is **spec-first**. No production code is written until an idea has been captured as a set of reviewable artifacts (proposal → design → tasks). Those artifacts live in `openspec/`, are generated and advanced through **OpenSpec CLI** commands, and are driven by **Kiro skills**. Custom **sub-agents** provide specialist expertise (architecture, domain, testing, review, cleanup), and **hooks** enforce guardrails and inject context automatically on every turn.

```
        ┌──────────────── Kiro (Claude) ────────────────┐
        │                                                │
 idea → │  Skills ──▶ OpenSpec CLI ──▶ artifacts (specs) │ ──▶ implementation ──▶ verify ──▶ archive
        │    ▲              │                             │
        │    │         sub-agents (architect, domain,    │
        │  hooks         tester, reviewer, cleaner)       │
        │  (context +                                     │
        │   guardrails)                                   │
        └────────────────────────────────────────────────┘
```

The layers that make this work:

| Layer | Where it lives | Purpose |
|---|---|---|
| **SDD artifacts** | `openspec/changes/<change>/` | Proposal, design, delta specs, tasks, reports |
| **OpenSpec skills** | `.kiro/skills/openspec-*/` | Step-by-step playbooks that drive the OpenSpec CLI |
| **Custom sub-agents** | `.kiro/agents/*.md` | Specialist reviewers/implementers invoked on demand |
| **Hooks** | `.kiro/hooks/*.kiro.hook` | Automatic context injection + compliance gates |
| **Steering** | `.kiro/steering/*.md` | Always-on and conditional rules (project context, architecture, testing, deployment) |

---

## 2. Spec-Driven Development with OpenSpec

Every change is a directory under `openspec/changes/`. For JIRA-ID-123 that directory is `feature-create-endpoints-and-data-mapping/` and it contains:

```
openspec/changes/feature-create-endpoints-and-data-mapping/
├── .openspec.yaml          # schema: spec-driven, created: 2026-06-23
├── proposal.md             # Why + What Changes + Capabilities + Impact
├── design.md               # How — architectural decisions (D1–D14)
├── specs/
│   └── reservation-operations/spec.md   # delta spec — requirements & scenarios
├── tasks.md                # 21 numbered task groups, 100+ checkboxes
└── reports/                # evidence produced during implementation
    ├── 2026-07-13-step-19-unit-test-verification.md
    └── 2026-07-13-step-20-integration-testing.md
```

The `.openspec.yaml` marks the workflow schema (`spec-driven`), which dictates the artifact build order: **proposal → design → tasks** must all be `done` before implementation (`apply`) can begin.

### 2.1 The artifact lifecycle

```
new/propose ──▶ proposal.md ──▶ design.md ──▶ tasks.md ──▶ apply ──▶ verify ──▶ (sync) ──▶ archive
   │                                              │                                          │
   └── scaffold change dir                        └── implement task-by-task,                └── move to
       + .openspec.yaml                               tick [ ] → [x]                              changes/archive/
```

### 2.2 OpenSpec commands used (and what each does)

The skills wrap these CLI calls. The commands you will see in a session:

| Command | Role in the workflow |
|---|---|
| `openspec new change "<name>"` | Scaffolds the change directory + `.openspec.yaml` |
| `openspec status --change "<name>" --json` | Reports schema, artifact statuses, `applyRequires`, resolved paths |
| `openspec instructions <artifact-id> --change "<name>" --json` | Returns the template, rules, context, and output path for one artifact |
| `openspec instructions apply --change "<name>" --json` | Returns `contextFiles` + task progress for implementation |
| `openspec list --json` | Lists active/archived changes for selection |
| `openspec schemas --json` | Lists available workflow schemas |

For JIRA-ID-123 the flow was: scaffold the change → author `proposal.md` (why the skeletal stubs had to become a real Reservation Store) → author `design.md` (decisions D1–D14) → decompose into `tasks.md` (21 groups from *Domain value objects* through *Update technical documentation*) → implement → verify → report.

---

## 3. The Kiro skills that drive OpenSpec

The `.kiro/skills/openspec-*/` folder contains twelve skills. Each `SKILL.md` is an executable playbook Kiro follows. They map directly onto the SDD lifecycle:

| Skill | When it runs | What it does |
|---|---|---|
| `openspec-new-change` | Starting fresh | Scaffolds the change, shows the first artifact template, then **stops** for direction |
| `openspec-propose` | Fast start | Creates the change **and** generates all artifacts (proposal, design, tasks) in one pass until apply-ready |
| `openspec-explore` | Thinking phase | Investigate ideas / clarify requirements before committing to a proposal |
| `openspec-continue-change` | Mid-flight | Creates the next missing artifact in dependency order |
| `openspec-ff-change` | Fast-forward | Generates all remaining artifacts needed for implementation |
| `openspec-apply-change` | Implementation | Reads `contextFiles`, works tasks one by one, ticks `[ ] → [x]`, pauses on blockers |
| `openspec-loop` | Bulk implementation | Sequential delegation through task proposals |
| `openspec-verify-change` | Pre-archive | Scores **Completeness / Correctness / Coherence**; emits CRITICAL/WARNING/SUGGESTION findings |
| `openspec-sync-specs` | Pre/at archive | Folds delta specs into the main `openspec/specs/` |
| `openspec-archive-change` | Done | Moves the change to `changes/archive/YYYY-MM-DD-<name>` |
| `openspec-bulk-archive-change` | Cleanup | Archives several completed changes at once |
| `openspec-onboard` | Learning | Guided walkthrough of a full cycle |

Key behaviors baked into the skills:

- **They never assume repo-local paths** — they read `planningHome`, `changeRoot`, and `artifactPaths` from `openspec status --json`.
- **`context` and `rules` are constraints for the agent, not file content** — they steer what gets written but never get copied into the artifact.
- **`apply` is guardrailed**: read context files first, keep changes minimal and scoped per task, update the checkbox immediately, and pause on ambiguity rather than guessing.
- **`verify` before `archive`**: JIRA-ID-123 produced explicit evidence in `reports/` — Step 19 (build + unit tests) and Step 20 (integration tests) — which is exactly the kind of completeness evidence the verify skill checks for.

### 3.1 How JIRA-ID-123 moved through the skills

1. **Propose** — `proposal.md` framed the problem: skeletal stubs couldn't handle real reservation flows, so the story delivers domain entities, the Reservation Store (MongoDB/DocumentDB schema + 7 indexes), the SAP OAA adapter skeleton, the CQRS pipeline, operational-mode infrastructure (Valkey), and the  response envelope.
2. **Design** — `design.md` recorded decisions D1–D14 (identity model, `oaaExternalId` never exposed, idempotency strategy, Polly policies, fail-open Valkey fallback, etc.).
3. **Tasks** — `tasks.md` broke the work into 21 groups, each a checklist. Notably groups 18–21 are **mandatory quality gates**: review existing tests, run unit tests + build, run integration tests, and update technical docs.
4. **Apply** — implemented layer by layer (domain → application → adapters → API), ticking boxes as it went. All 21 groups are `[x]`.
5. **Verify + evidence** — Step 19 report: `dotnet build` 0 errors, **59 tests, 0 failures**. Step 20 report: 4/4 WebApplicationFactory integration tests pass; Docker-based scenarios documented for when the daemon is available.

---

## 4. Custom sub-agents

Five specialist agents are defined in `.kiro/agents/` (each with a `.md` persona + `.json` config, `inclusion: manual` — invoked on demand). They divide the work by expertise:

| Agent | Model | Specialty |
|---|---|---|
| `solution-architect-agent` | claude-sonnet-4.5 | Hexagonal architecture design & validation — dependency direction, ports/adapters, resilience, observability |
| `reservation-api-specialist` | claude-sonnet-4 | Domain expert — reservation lifecycle, identity model (`externalCartId` vs `oaaExternalId`), SAP OAA integration, idempotency |
| `unit-tester-agent` | claude-sonnet-4 | xUnit/NUnit testing strategy per layer, `Should_[Expected]_When_[Condition]` naming, coverage targets |
| `code-review-agent` | claude-sonnet-4 | Evidence-based review across 9 phases (architecture, security, async, resilience, quality, tests, config, impact) |
| `refactor-cleaner-agent` | claude-sonnet-4 | Safe cleanup — removes dead code while protecting domain logic, ports, and DI-invoked handlers |

They are cross-linked via `related:` frontmatter so a review can hand off to the tester or architect. In JIRA-ID-123 the division shows up directly:

- The **specialist** governs rules like *`oaaExternalId` never appears in a response DTO* — verified in the Step 20 report.
- The **architect** enforces *dependencies point inward* — domain has zero infrastructure references; ports in Application, implementations in Adapters.
- The **tester** shapes the test layout (`Reservation.Domain.Unit`, `Reservation.Application.Unit`, `Reservation.API.Unit`, `Reservation.API.Integration`) and the 59-test suite.
- The **reviewer** runs `git diff main...HEAD`, reads every changed file, and reports findings with evidence — no speculation.

---

## 5. Hooks — the automation layer

Five hooks in `.kiro/hooks/` fire automatically on IDE events. They fall into two groups: **context injection** and **compliance gates**.

| Hook | Trigger | Action | Purpose |
|---|---|---|---|
| `inject-git-context` | `promptSubmit` | runCommand | Injects current branch + last 5 commits + uncommitted changes into context |
| `memory-boot-protocol` | `promptSubmit` | askAgent | Reminds the agent to silently load Serena MCP memories (session continuity) before responding |
| `context-mode-pre` | `preToolUse` (`*`) | runCommand | `context-mode hook kiro pretooluse` — context-window protection before every tool call |
| `context-mode-post` | `postToolUse` (`*`) | runCommand | `context-mode hook kiro posttooluse` — context-window protection after every tool call |
| `pr-format-compliance` | `postToolUse` (`shell`) | askAgent | After git/PR shell commands, validates branch name, commit message, and PR title against standards |

How they showed up in the JIRA-ID-123 session:

- **Git context** is why the branch `feature/JIRA-ID-123` and recent commits (`362370e feat(JIRA-ID-123): Add failure tracking…`, `9979fca JIRA-ID-123, Implement the reservation api core features`) are known without asking.
- **Memory boot** runs the Serena MCP load protocol at the start of the conversation, silently, so prior session threads are available.
- **Context-mode pre/post** wrap every tool call to keep the working window healthy on long, multi-file changes like this one.
- **PR-format compliance** is the deterministic gate that enforces the convention: branch `feature/TICKET-description`, commit messages referencing the Jira ticket, PR titles like `[JIRA-ID-123]: …`. The commit history already follows it.

There is also a **steering rule** (`submodule-update-rule.md`) that asks for `git submodule update --remote --merge` at session start to keep the guidelines (`.kiro/standards/`) current.

---

## 6. Steering — always-on rules

`.kiro/steering/` supplies the standing context that every session inherits:

- `project-context.md` — the canonical domain model, tech stack, folder map, mapper naming convention, and code-intelligence strategy (Serena → CodeGraph → grep).
- `architecture-rules.md`, `development-rules.md`, `testing-rules.md`, `deployment-rules.md`, `messaging-rules.md`, `spec-workflow-rules.md` — topic rules, some always-on, some conditionally loaded when matching files are opened.
- `submodule-update-rule.md` — keeps external guidelines fresh.

Together these mean an agent starts every JIRA-ID-123 turn already knowing the hexagonal boundaries, the `oaaExternalId` secrecy rule, the mapper naming table, and the test conventions — without being told again.

---

## 7. End-to-end: JIRA-ID-123 as it actually ran

```
1. Session starts
   └─ hooks: inject git context (feature/JIRA-ID-123) + memory boot (Serena MCP)
   └─ steering: project-context + architecture/testing rules loaded

2. Plan (SDD)
   └─ skill openspec-propose → openspec new change "feature-create-endpoints-and-data-mapping"
   └─ proposal.md  (why the Reservation Store foundation is needed)
   └─ design.md    (decisions D1–D14)
   └─ tasks.md     (21 groups / 100+ checkboxes)

3. Implement (SDD)
   └─ skill openspec-apply-change → work tasks 0..21, tick [ ]→[x]
      · Domain: enums, ReservationResult, OperationState, ReservationEntity/Item
      · Application: ports, commands/queries, handlers (stubs + OperationMode fully impl.)
      · Adapters: SAP OAA (XML + error table), DocumentDB (docs + repo + indexes), Valkey
      · API: controllers (501 stubs + OperationMode + Health), request/response mappers
   └─ sub-agents on demand: architect / domain specialist / tester / reviewer

4. Verify (quality gates in tasks 18–21)
   └─ Step 19 report: dotnet build 0 errors; 59 unit/integration tests, 0 failures
   └─ Step 20 report: 4/4 WebApplicationFactory integration tests pass
   └─ hook pr-format-compliance validates commits/branch on each git command

5. Commit
   └─ feat(JIRA-ID-123): implement reservation store foundations and CQRS pipeline
   └─ feat(JIRA-ID-123): Add failure tracking and fix SAP OAA error handling

6. (Next) verify-change → sync-specs → archive-change
```

---

## 8. Quick reference

**Start a new change**
```bash
openspec new change "<kebab-name>"          # or use skill: openspec-propose
openspec status --change "<name>" --json
```

**Implement**
```bash
openspec instructions apply --change "<name>" --json   # skill: openspec-apply-change
# work tasks, tick [ ] → [x] in tasks.md
```

**Verify & archive**
```bash
# skill: openspec-verify-change  → produces Completeness/Correctness/Coherence report
# skill: openspec-sync-specs     → fold delta specs into openspec/specs/
# skill: openspec-archive-change → mv change → changes/archive/YYYY-MM-DD-<name>
```

**Invoke a specialist** — reference the agent by name (`solution-architect-agent`, `reservation-api-specialist`, `unit-tester-agent`, `code-review-agent`, `refactor-cleaner-agent`).

**Conventions that hold everywhere**
- Branch: `feature/ORDER-XXX-description` · PR title: `[ORDER-XXX]: …` · commits reference the ticket
- Hexagonal boundaries: no HTTP types in domain/application; ports inward, adapters outward
- `oaaExternalId` is internal — never in any API response
- Tests: `Should_[Expected]_When_[Condition]`; verify before archive
