# OpenSpec Review Protocol — @openspec-reviewer Agent Integration

> **Purpose:** Ensure every artifact batch is reviewed before freezing. Define when, how, and what to check.
> **Owner:** Main agent (orchestrator) + @openspec-reviewer agent
> **Audience:** Both Claude instances involved in the workflow

---

## 🎯 Core Rule

**Every artifact batch must be reviewed before freezing.**

No batch is frozen without @openspec-reviewer passing it. No exceptions.

---

## 📋 When to Call @openspec-reviewer

Call the reviewer **immediately after creating a batch**, before moving to the next batch.

| Phase | Batch | Trigger | Created Artifacts |
|---|---|---|---|
| **PROPOSE** | 2a | After `proposal.md` written | `proposal.md` |
| | 2b | After `design.md` written | `design.md` |
| | 2c | After `specs/` written | `specs/*.md` |
| | 2d | After `tasks.md` written | `tasks.md` |
| **APPLY** | (apply) | After code + tests complete | Code changes + test reports |

---

## ✅ What to Attach When Calling

### BEFORE First Batch (2a)

**Attach:**
1. `explore-brief.md` (if it exists) — **ALWAYS include this as the baseline**
2. If no brief exists → summarize key context from explore phase:
   - What approaches were discussed
   - What got rejected and why
   - Key design commitments made during exploration

**Tell the reviewer:**
> "Batch 2a (proposal.md): Starting fresh. No artifacts frozen yet. Attached explore-brief.md as baseline."

### BEFORE Batch 2b, 2c, 2d

**Attach:**
1. `explore-brief.md` (for reference)
2. All **previously frozen artifacts** (e.g., when reviewing 2b, attach frozen `proposal.md`)
3. **Newly created artifacts in this batch** (e.g., when reviewing 2b, attach newly-created `design.md`)

**Tell the reviewer:**
> "Batch 2b (design.md): Frozen artifacts: proposal.md. New artifacts this round: design.md."

> "Batch 2c (specs/): Frozen artifacts: proposal.md, design.md. New artifacts this round: specs/order-creation-spec.md, specs/order-update-spec.md."

---

## 🔍 The Baseline Checklist (for ALL Reviews)

**@openspec-reviewer checks explore-brief.md (or explore context) against the artifacts being reviewed:**

### Section 1: Alternatives Rejected
**Check:** Were all rejected alternatives from the brief addressed in the proposal/design?
- If an alternative was rejected in explore, does the new artifact explain why it wasn't chosen?
- Are there any new approaches that contradict the rejection rationale?

### Section 2: Full Labels, Dimensions, Mapping Tables
**Check:** Do the artifacts contain the complete mapping tables from the brief?
- State labels (e.g., BACKLOG_GATE, MAINTENANCE, NORMAL) — all present?
- Dimension mappings (e.g., Order Status → Service State transitions) — all present?
- Keyword lists, enum definitions — all present?
- **NO "e.g." allowed** — list everything out

### Section 3: Key Cross-Module Data Flows
**Check:** Are all data flows from the brief reflected in design or specs?
- Who calls who? (Service A → Service B)
- What parameters get passed?
- How do error cases flow?

### Section 4: Known Open Questions
**Check:** Were open questions resolved or explicitly addressed?
- If resolved: is the resolution documented in the artifacts?
- If still open: is it listed in Risks/Open Questions section?

---

## 🔴 What the Reviewer Reports Back

### review-log.md Entry Format

Append to `openspec/changes/<change-name>/review-log.md` after each review:

```markdown
## <batch-name> Round N — YYYY-MM-DD HH:MM

### 🔴 Fixed
- <what was fixed in this round>
- <what was fixed in this round>

### 🟡 Addressed
- <what was addressed but not critical>
- <what was addressed but not critical>

### 🔴 Outstanding
- <what still needs fixing next round>
- <what still needs fixing next round>

---
```

**Example:**

```markdown
## proposal Round 1 — 2026-06-25 14:30

### 🔴 Fixed
- Added missing business impact statements (revenue impact, timeline)

### 🟡 Addressed
- Scope language tightened, but could be even more specific
- Risk section exists but is thin (not blocking)

### 🔴 Outstanding
- Three capabilities listed in proposal but not all explained in design draft (deferring to design batch)

---
```

---

## ✅ Passing Criteria (Single-Round Pass Rule)

**A batch PASSES if:**
- After the current review round, the `### 🔴 Outstanding` section in `review-log.md` **does NOT exist OR is empty**

**What this means:**
- If there are no 🔴 (serious) issues in the current round → batch is **frozen immediately**
- Move to next batch
- **No need for two consecutive clean rounds** — current result is final

**Why this rule?**
If there are no serious issues after review, the artifacts are in good shape. The latest review result is authoritative. Asking for a second confirmation round wastes time.

---

## 🔄 Fix Loop (When Issues Exist)

If there ARE 🔴 issues in the review:

1. **Main agent reads review-log.md** → identifies outstanding issues
2. **Main agent fixes ONLY the current batch** (never touch frozen artifacts)
3. **Main agent calls @openspec-reviewer again** with the same batch
4. **Go back to ✅ Passing Criteria** → check if now passing

**Keep looping until:**
- Batch passes (outstanding section empty), OR
- Hit hard cap (see below)

---

## 🚨 Hard Cap: MAX_ROUNDS = 5

**If the same batch has been reviewed 5 times and still hasn't passed:**

Stop looping and hand off to human:

```
❌ Batch <batch-name> hasn't passed after 5 review rounds.

Outstanding serious issues:
- <issue 1>
- <issue 2>
- <issue 3>

Please choose:
A. Force freeze, ignore outstanding issues, move to next batch
B. Roll back the design and rethink this batch's approach
C. Add one more review round (exception)
```

**Round counting rule:**
- A round counts **only** when @openspec-reviewer is called AND a `review-log.md` entry is produced
- Pure fix operations (without review) don't count as rounds

---

## 🧊 Freeze & Unfreeze During Reviews

### Freeze Point
Once a batch's review shows **no outstanding issues** (empty 🔴 section):
- Batch is **frozen**
- All subsequent reviews must use frozen artifacts as baseline
- Main agent cannot touch frozen artifacts anymore

### Soft Freeze (Declarative Additions Only)
After freezing, the main agent **can** append declarative content without unfreezing:

**Allowed (declarative):**
- ✅ Adding missing mapping tables / keyword lists / complete enumerations
- ✅ Fixing typos
- ✅ Adding missing scenarios or examples
- ✅ Adding boundary condition descriptions

**The Test:** _Would this change cause an implementer to write different code?_
- **No** (just filling in details) → declarative, allowed
- **Yes** (changes algorithm, semantics, responsibilities) → decision-level, blocked

### Decision-Level Changes (Full Unfreeze Required)
If a later review finds that a frozen artifact needs a **decision-level change**:
- ❌ Changing algorithms
- ❌ Changing label semantics
- ❌ Changing module responsibility boundaries
- ❌ Adding/removing capabilities

**Action:** Unfreeze that artifact AND all artifacts that came after it, then re-review in batches starting from the unfreeze point.

---

## 🔄 Batch Review Order (STRICT)

**Never skip or reorder batches.** Always review in this sequence:

```
proposal.md (batch 2a) ──▶ REVIEW ──▶ FREEZE
                                       ↓
                                    design.md (batch 2b) ──▶ REVIEW ──▶ FREEZE
                                                           ↓
                                                        specs/*.md (batch 2c) ──▶ REVIEW ──▶ FREEZE
                                                                              ↓
                                                                           tasks.md (batch 2d) ──▶ REVIEW ──▶ READY FOR APPLY
```

---

## 📝 How to Record Issues in review-log.md

### Format Guidelines

**🔴 Fixed (Serious issues resolved this round)**
- Use past tense ("Added...", "Changed...", "Clarified...")
- Be specific: reference the artifact and the section that was fixed
- Example: "Added state machine diagram to design.md showing transition rules"

**🟡 Addressed (Non-critical observations)**
- Issues that don't block progress but are worth noting
- Example: "Scope language tightened, but could be even more specific in acceptance criteria"

**🔴 Outstanding (Still needs work)**
- Issues the main agent will fix in the next round
- Example: "Error handling strategy incomplete — needs retry logic + circuit breaker details"
- If outstanding section is empty → batch passes

---

## 🛑 Stopping Conditions (Main Agent Actions)

The main agent **STOPS and asks for help** if ANY of these happen:

1. **After 5 review rounds, batch still has 🔴 outstanding issues**
   - Offer the three options (force freeze, rollback, add round)
   - Wait for user choice

2. **Review reveals a frozen artifact needs decision-level change**
   - Unfreeze that artifact + all downstream artifacts
   - Tell user: "Unfreezing proposal.md, design.md, and specs/ to address [issue]. Re-reviewing from batch 2a."

3. **Review result is unclear or contradictory**
   - Ask @openspec-reviewer to clarify
   - Don't guess what the feedback means

4. **Same issue keeps appearing across rounds**
   - Ask user: "This issue has appeared in 3 consecutive rounds. Should we pivot the approach?"

---

## 🎯 Quick Reference: When to Call @openspec-reviewer

| Scenario | Action |
|---|---|
| Just finished writing `proposal.md` | Call @openspec-reviewer with explore-brief.md |
| Just finished writing `design.md` | Call @openspec-reviewer with explore-brief.md + frozen proposal.md |
| Just finished writing `specs/` | Call @openspec-reviewer with explore-brief.md + frozen proposal.md + frozen design.md |
| Just finished writing `tasks.md` | Call @openspec-reviewer with all frozen artifacts + explore-brief.md |
| Review has 🔴 Outstanding issues | Fix them, then call @openspec-reviewer again |
| Review has no Outstanding issues | Freeze batch, move to next batch |
| Same batch reviewed 5 times, still failing | Hand off to user with three options |

---

## 💡 Tips for Smooth Reviews

### For the Main Agent

1. **Always attach explore-brief.md** — it's the north star for consistency
2. **Read review-log.md before fixing** — use it as your checklist
3. **Fix only the current batch** — never touch frozen artifacts
4. **Call @openspec-reviewer the same day** — don't let feedback go stale
5. **Append review-log.md entries incrementally** — one entry per review round

### For @openspec-reviewer

1. **Check against explore-brief.md first** — is everything from the brief covered?
2. **Be specific** — say _what_ is missing and _where_ it should go
3. **Distinguish 🔴 (blocking) from 🟡 (nice-to-have)**
4. **If outstanding section is empty, say so explicitly** — don't leave it ambiguous
5. **Reuse review-log.md format** — consistency helps tracking

---

## 🧩 Example Workflow: proposal.md Review

```
Main Agent:
  "Created proposal.md. Calling @openspec-reviewer..."
  → Attaches: explore-brief.md + newly-created proposal.md

@openspec-reviewer:
  Checks proposal against explore-brief:
  - Alternatives: ✅ covered
  - Mappings: ❌ missing state labels
  - Data flows: ✅ covered
  - Open questions: ✅ addressed
  
  Appends review-log.md:
  
  ## proposal Round 1 — 2026-06-25 14:30
  ### 🔴 Fixed
  - (nothing yet, this is first review)
  ### 🟡 Addressed
  - Impact section is thin
  ### 🔴 Outstanding
  - Missing state labels in scope section
  - Risk section needs detail

Main Agent:
  Reads review-log.md, sees Outstanding issues
  → Fixes proposal.md (adds state labels, expands risks)
  → Calls @openspec-reviewer again

@openspec-reviewer:
  Reviews updated proposal.md
  
  Appends review-log.md:
  
  ## proposal Round 2 — 2026-06-25 15:00
  ### 🔴 Fixed
  - Added all five state labels to scope section
  - Risk section now covers deployment + integration risks
  ### 🟡 Addressed
  - (none)
  ### 🔴 Outstanding
  - (empty)

Main Agent:
  Sees empty Outstanding section → proposal.md is FROZEN
  → Moves to batch 2b (design.md)
```

---

## 🚀 Summary

**The Protocol in One Page:**

1. **Create artifacts in a batch** (e.g., proposal.md)
2. **Call @openspec-reviewer** with explore-brief.md + frozen artifacts + new batch
3. **Check review-log.md** for 🔴 Outstanding issues
4. **If Outstanding is empty** → freeze batch, move to next batch
5. **If Outstanding has issues** → fix them, call @openspec-reviewer again, repeat step 3
6. **If 5+ reviews and still failing** → hand off to user with options

**Key guarantees:**
- ✅ Every batch is reviewed before freezing
- ✅ explore-brief.md is always the baseline for consistency
- ✅ Frozen artifacts are protected (only declarative additions allowed)
- ✅ Main agent knows exactly when to stop and ask for help