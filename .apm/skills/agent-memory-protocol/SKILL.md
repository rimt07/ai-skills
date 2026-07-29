---
name: agent-memory-protocol
description: Provides session and long-term memory management using Serena MCP tools. Replaces file-based memory (MEMORY.md, daily logs) with Serena-backed working memory and long-term vector memory. Defines session boot protocol, write policies, promotion criteria, and security boundaries using MCP tool calls.
keywords: memory, serena, working-memory, long-term-memory, mcp, session
requires:
  mcp: [serena]
risk: low
source: workspace
---

#Skill: agent-memory-protocol / MEMORY ARCHITECTURE SKILL (Serena MCP)

This skill provides structured cognitive persistence across sessions using
**Serena MCP tools** for memory management.

It organizes memory into:

- **Working Memory** → session-scoped state (topic-based organization)
- **Long-Term Memory** → cross-session curated intelligence (persistent, searchable)

All memory operations are performed through Serena MCP tool calls:
- `mcp_serena_write_memory` — persist facts and decisions
- `mcp_serena_read_memory` — retrieve by topic name
- `mcp_serena_list_memories` — discover available memories
- `mcp_serena_delete_memory` — remove obsolete memories
- `mcp_serena_rename_memory` — reorganize topics
- `mcp_serena_edit_memory` — update existing memories

No Redis server required. All memory is file-backed via Serena's `.serena/memories/` directory.

## 🔄 SESSION BOOT PROTOCOL (MANDATORY)

Before executing any domain logic, perform the following in order. All steps
are **silent** — no output to the user.

### Step 1 — Identify Session Context

Determine:
- `memory_topic`: unique identifier for this conversation (use format: `session/YYYY-MM-DD-context-slug`, e.g. `session/2026-02-25-ocp-api-design`)
- Session type: **MAIN** (direct chat) or **SHARED** (Discord, group, third-party)

### Step 2 — Load Working Memory (Session Context)

Call Serena MCP tool to retrieve current session working memory:

```
Tool: mcp_serena_read_memory
Args:
  memory_name: "session/continuity"
```

This loads the last session's open threads and context. If not found, the session is fresh.

Also check for **project-level memories** relevant to the current task:

```
Tool: mcp_serena_list_memories
Args:
  topic: "project"
```

This discovers available project memories (structure, conventions, decisions).

### Step 3 — Load Long-Term Memory (MAIN sessions only)

**Only if session type = MAIN:**

```
Tool: mcp_serena_list_memories
Args:
  topic: ""
```

This lists all available memories. Filter for topics matching the current domain (e.g., `architecture/`, `lessons-learned/`, `patterns/`).

Then selectively read relevant memories:

```
Tool: mcp_serena_read_memory
Args:
  memory_name: "architecture/hexagonal-patterns"
```

**NEVER load memories in SHARED sessions** — this is a security boundary. Only load `project/` and `session/` topics in shared contexts.

---

## 🧠 WORKING MEMORY MODEL (Session-Scoped)

**Maps to:** `.serena/memories/session/` directory.

**Scope:** One session. Persists by default across conversations.

**Write when:**
- A decision is made
- A constraint or risk is identified
- A pattern or lesson is discovered
- The user says *"remember this"*
- A hypothesis is formed or confirmed
- A tool use result is important for the conversation

### Write Pattern

```
Tool: mcp_serena_write_memory
Args:
  memory_name: "session/continuity"
  content: |
    # Session: 2026-04-01 — [Context]
    
    ## Open Threads
    - [Thread 1]: [Status]
    - [Thread 2]: [Status]
    
    ## Key Decisions
    - [Decision]: [Rationale]
    
    ## Constraints & Risks
    - [Constraint]: [Impact]
```

**Key distinction:**
- Session memories are topic-organized (e.g., `session/continuity`, `session/current-task`)
- Automatically persisted across conversations
- Searchable via `mcp_serena_list_memories`

### When to Update Session Memory

Update `session/continuity` at:
- End of significant work sessions
- When switching between major tasks
- When a decision affects future sessions
- When a blocker or risk emerges

---

## 📚 LONG-TERM MEMORY MODEL (Cross-Session, Persistent)

**Maps to:** `.serena/memories/` directory (organized by topic).

**Scope:** Cross-session, persistent, discoverable.

**Load only in MAIN sessions.**

### Promote when:

| Criterion | Example |
|-----------|---------|
| Recurring pattern | "User always wants early returns in handlers" |
| Governance rule | "Never use raw SQL — always use repo pattern" |
| Architectural standard | "All commands go through MediatR pipeline" |
| Anti-pattern detected | "Don't put business logic in controllers" |
| Cross-domain insight | "OCP prefers explicit error types over exceptions" |
| Lesson learned | "Breaking the idempotency key caused duplicate orders" |

### Write Pattern — Explicit Promotion

```
Tool: mcp_serena_write_memory
Args:
  memory_name: "architecture/hexagonal-patterns"
  content: |
    # Hexagonal Architecture Patterns
    
    ## Port & Adapter Separation
    - Ports define domain contracts
    - Adapters implement external integrations
    - Never mix adapter logic with domain logic
    
    ## Lessons Learned
    - [Lesson]: [Context and outcome]
```

### Memory Organization

Use topic-based naming:
- `project/` — project-specific facts (structure, conventions)
- `session/` — session-scoped continuity
- `architecture/` — architectural patterns and decisions
- `lessons-learned/` — validated insights from experience
- `patterns/` — reusable code and design patterns
- `anti-patterns/` — documented mistakes to avoid

### Search Pattern

```
Tool: mcp_serena_list_memories
Args:
  topic: "architecture"
```

Then read specific memories:

```
Tool: mcp_serena_read_memory
Args:
  memory_name: "architecture/hexagonal-patterns"
```

---

## 📝 WRITE-IT-DOWN POLICY

> Persistence > internal reasoning. If it matters → write it.

### Triggers → Session Memory

- Any decision made during the session
- Any constraint, risk, or blocker identified
- User says *"remember this"* or *"keep in mind"*
- A tool result that affects future steps
- Open threads that need continuation in next session

### Triggers → Long-Term Memory

- Systemic insight that will affect future sessions
- A repeated mistake now documented as an anti-pattern
- A governance clarification from the user
- An architectural lesson validated in practice
- A standard that should apply across all projects

**When in doubt:** write to session memory first — promote to long-term when the pattern repeats or the insight matures.

---

## 🛡 SECURITY BOUNDARY

| Rule | Details |
|------|---------|
| **Never load long-term memory in SHARED sessions** | Discord, group chats, third-party sessions must never receive personal curated memory |
| **Never expose memory search results publicly** | Don't echo raw memory content to shared channels |
| **Topic isolation** | Use `project/` for shared project facts, `session/` for continuity, other topics for personal insights |
| **Uncertain session type** | When in doubt → treat as SHARED, skip long-term memory load |

---

## 🔁 MEMORY LIFECYCLE — SESSION END

At the end of a significant session (or when explicitly asked), promote
valuable session memory to long-term:

1. Review the session's key decisions and insights
2. For insights that require **deliberate distillation** (not just raw facts), explicitly call `mcp_serena_write_memory` with a long-term topic
3. Do **not** copy raw logs — distill the essence

```
Tool: mcp_serena_write_memory
Args:
  memory_name: "lessons-learned/order-domain-2026-04"
  content: |
    # Lessons Learned — Order Domain (April 2026)
    
    ## Key Insight
    [Distilled insight from this session]
    
    ## Context
    [When and why this matters]
    
    ## Application
    [How to apply this in future work]
```

---

## 🧭 MEMORY AWARENESS PRINCIPLE

Agents are stateless. Serena reconstructs continuity.

The difference from pure file-based memory:

| Pure Files | Serena MCP |
|------------|-----------|
| Manual `.md` file writes | Structured MCP tool calls |
| Keyword grep search | Topic-based organization |
| No deduplication | Automatic organization by topic |
| Static, unversioned | Editable, renameable, deletable |
| No discovery | `list_memories` for exploration |

Cognitive durability is now backed by Serena. Always use MCP tools — never write `.md` files directly for memory unless Serena is unavailable.

---

## 🛠 QUICK REFERENCE — SERENA MCP TOOLS

| Intent | Tool | Key Args |
|--------|------|----------|
| Load session context | `mcp_serena_read_memory` | `memory_name: "session/continuity"` |
| List available memories | `mcp_serena_list_memories` | `topic: "project"` or `topic: ""` |
| Save session state | `mcp_serena_write_memory` | `memory_name`, `content` |
| Update existing memory | `mcp_serena_edit_memory` | `memory_name`, `needle`, `repl`, `mode` |
| Rename/reorganize | `mcp_serena_rename_memory` | `old_name`, `new_name` |
| Delete obsolete memory | `mcp_serena_delete_memory` | `memory_name` |