---
name: code-analisys-intelligence-protocol
description: Establish a **mandatory implementation protocol** for AI coding agents to perform **semantic and graph-based code analysis before any traditional text search**. The objective is to replace inefficient file-by-file exploration (`grep`, `find`, `Read`, recursive scanning, etc.) with **symbol-aware** and **graph-aware** navigation that understands architecture, dependencies, call relationships, and code semantics.
author: RIMT
version: 1.0.0  
---
# skill: code-analisys-intelligence-protocol Skill (CAIP)


## Purpose

Establish a **mandatory implementation protocol** for AI coding agents to perform **semantic and graph-based code analysis before any traditional text search**.

The objective is to replace inefficient file-by-file exploration (`grep`, `find`, `Read`, recursive scanning, etc.) with **symbol-aware** and **graph-aware** navigation that understands architecture, dependencies, call relationships, and code semantics.

This protocol is mandatory for all code understanding, debugging, refactoring, impact analysis, feature development, and architecture review tasks.

---

# Core Principles

1. **Semantic understanding over text matching.**
2. **Graph traversal over directory traversal.**
3. **Symbol navigation over line navigation.**
4. **Relationship analysis before source reading.**
5. **Minimal context acquisition for maximum precision.**
6. **Read only what is necessary after semantic discovery.**
7. **Treat grep/read as fallback mechanisms, not primary discovery tools.**

---

# Mandatory Execution Order

```
                ┌────────────────────────┐
                │  User Coding Request   │
                └────────────┬───────────┘
                             │
                             ▼
              Is Graphify available for project?
                       │             │
                    YES              NO
                     │                │
                     ▼                ▼
        Execute Graphify Protocol     Skip
                     │
                     ▼
          Is Serena MCP available?
                     │
              YES         NO
               │           │
               ▼           ▼
      Use Serena tools   Use CodeGraph
               │           │
               └──────┬────┘
                      ▼
        Still unresolved or unavailable?
                      │
                  YES │
                      ▼
         Use Grep / Glob / Read as fallback
```

---

# Priority Hierarchy

## Priority 1 — Serena MCP (Preferred)

Always prefer Serena whenever available because it provides IDE-level semantic understanding through Language Server Protocol (LSP) capabilities rather than raw text search. It is designed for symbol-level navigation and refactoring. This substantially reduces unnecessary file reads and token consumption while improving precision. (Reference: Serena documentation and feature descriptions.)

### Preferred operations

* `find_symbol`
* `get_symbols_overview`
* `find_referencing_symbols`
* `search_for_pattern`
* `rename_symbol`
* `replace_symbol_body`
* `safe_delete_symbol`

### Typical uses

| Task                      | Serena Tool              |
| ------------------------- | ------------------------ |
| Locate class              | find_symbol              |
| Locate method             | find_symbol              |
| Find references           | find_referencing_symbols |
| Understand file structure | get_symbols_overview     |
| Rename symbol             | rename_symbol            |
| Replace implementation    | replace_symbol_body      |
| Delete safely             | safe_delete_symbol       |
| Regex search              | search_for_pattern       |

---

## Priority 2 — CodeGraph MCP

If Serena is unavailable, use CodeGraph.

CodeGraph exposes the repository as a persistent knowledge graph of symbols and relationships, enabling architectural reasoning, dependency traversal, impact analysis, and natural-language exploration before opening source files.

### Preferred operations

* `codegraph_explore`
* `codegraph_node`
* `codegraph_search`
* `codegraph_callers`

### Typical uses

| Task                    | CodeGraph Tool    |
| ----------------------- | ----------------- |
| Understand feature flow | codegraph_explore |
| Architecture questions  | codegraph_explore |
| Locate symbol           | codegraph_search  |
| View callers            | codegraph_callers |
| Inspect node            | codegraph_node    |

---

## Priority 3 — Traditional Search (Fallback Only)

Traditional tools may only be used when semantic tooling is unavailable.

Approved fallback tools:

* Grep
* Glob
* Read

These tools should never be the first choice if semantic or graph-aware tooling exists.

---

# Mandatory Graphify Protocol

When Graphify artifacts exist in the project, the following protocol is **non-optional**.

## Step 1 — Verify Graph Report

Confirm that:

```
graphify-out/GRAPH_REPORT.md
```

exists.

If missing:

* STOP execution.
* Inform the user that Graphify output is unavailable.
* Do not continue with source analysis.

---

## Step 2 — Read Graph Report

Read the report completely before opening any source code.

Review:

* God nodes
* Community clusters
* Dependency hubs
* Cross-module relationships
* Critical architectural observations

---

## Step 3 — Announce Findings

Explicitly identify:

* Top three god nodes
* Total number of detected communities
* Communities relevant to the current task

---

## Step 4 — Execute Graph Query

Run:

```
graphify query "<current task topic>"
```

This query is mandatory.

Its traversal output determines:

* relevant communities
* relevant symbols
* dependency paths
* prior planning nodes

Skipping this step is prohibited.

---

## Step 5 — Plan Using Graph Evidence

Before reading any source:

* identify affected graph nodes,
* identify impacted communities,
* identify dependency chains,
* justify the exploration plan using graph evidence.

---

## Step 6 — Read Only Relevant Files

Only after Graphify identifies relevant nodes may source files be opened.

Avoid broad project scanning.

---

# Semantic Search Policy

Before opening any file:

1. Search by symbol.
2. Search references.
3. Explore callers/callees.
4. Inspect architecture.
5. Read implementation only when necessary.

Never begin with recursive text search.

---

# Tool Selection Matrix

| Objective                 | Preferred Tool                  |
| ------------------------- | ------------------------------- |
| Understand architecture   | Graphify                        |
| Understand execution flow | CodeGraph Explore               |
| Find class                | Serena find_symbol              |
| Find method               | Serena find_symbol              |
| Find references           | Serena find_referencing_symbols |
| Inspect callers           | CodeGraph callers               |
| View file outline         | Serena get_symbols_overview     |
| Safe rename               | Serena rename_symbol            |
| Safe deletion             | Serena safe_delete_symbol       |
| Regex lookup              | Serena search_for_pattern       |
| Last-resort text search   | Grep                            |

---

# Required Workflow for Common Tasks

## Bug Investigation

1. Query Graphify.
2. Identify affected community.
3. Locate symbol with Serena.
4. Inspect references.
5. Read minimal implementation.
6. Diagnose root cause.

---

## Feature Development

1. Query Graphify.
2. Locate architectural community.
3. Discover symbols.
4. Analyze callers/callees.
5. Implement changes.
6. Verify ripple effects.

---

## Refactoring

1. Graph traversal.
2. Dependency impact review.
3. Reference analysis.
4. Symbol rename or replacement.
5. Safe deletion validation.

---

## Impact Analysis

1. Graph query.
2. Community identification.
3. Call graph inspection.
4. Reference enumeration.
5. Produce dependency report.

---

# Architecture Audit Procedure

## Step 1

Summarize architecture in ten concise points using graph-derived evidence.

## Step 2

Identify critical modules based on:

* god nodes,
* centrality,
* dependency concentration,
* graph connectivity.

For each module document:

* why it is critical,
* likely breakage if modified,
* hidden ripple effects.

## Step 3

Produce a prioritized audit ordered by technical risk rather than business features.

Highlight:

* orphan nodes,
* dead code,
* isolated communities.

## Step 4

Generate a stakeholder-friendly report including:

1. General architecture.
2. Technical risks.
3. Undocumented areas.
4. Critical dependencies.
5. Quick wins.

Every claim should be supported by graph-derived structural evidence.

---

# Forbidden Behaviors

The agent MUST NOT:

* Start with Grep when Serena or CodeGraph is available.
* Read entire directories without semantic discovery.
* Perform recursive file scans before graph exploration.
* Ignore Graphify when its artifacts exist.
* Skip the mandatory `graphify query`.
* Refactor symbols using plain text replacement when semantic refactoring exists.
* Open unrelated files "just in case."
* Use filename heuristics instead of symbol navigation.

---

# Compliance Checklist

Before completing any coding task, verify:

* [ ] Graphify report checked (if applicable).
* [ ] Graphify report read.
* [ ] Graph query executed.
* [ ] Relevant communities identified.
* [ ] Serena attempted first.
* [ ] CodeGraph used if Serena unavailable.
* [ ] Traditional search used only as fallback.
* [ ] Source files opened only after semantic discovery.
* [ ] Impact analysis completed before modifications.
* [ ] Refactoring performed using symbol-aware operations when available.

Failure to satisfy any mandatory item should be treated as protocol non-compliance.
