---
name: openspec-enrich-extended-spec
description: Use when the user wants to create an enriched L4 specification document combining requirements and high-level design for a feature, following the OCP Confluence L4 format with mermaid diagrams, glossary, numbered requirements, architecture views, and decision tables.
license: MIT
compatibility: Requires openspec CLI and Confluence MCP access.
metadata:
  author: ocp-engineering
  version: "2.0"
---

Create an enriched L4 specification document that combines Requirements and High-Level Design into a single comprehensive markdown file, following the OCP Confluence L4 format.

This skill produces a `docs/{TICKET}-{feature-name}-requirements-and-design-L4.md` file suitable for direct publication to Confluence.

---

**Input**: A completed OpenSpec change (with proposal.md and design.md) OR a feature description with enough context to write requirements and design.

**Output Modes**:
- **Combined** (default): Single file with both Requirements + Design → `docs/{TICKET}-{feature-name}-requirements-and-design-L4.md`
- **Split**: Two separate files → `docs/{TICKET}-{feature-name}-requirements-L4.md` + `docs/{TICKET}-{feature-name}-high-level-design-L4.md`

**Format References (live Confluence examples)**:
- [Order Event Orchestration — Requirements (L4)](https://arcteryx.atlassian.net/wiki/spaces/OPE/pages/7599718486)
- [Order Event Orchestration — High-Level Design (L4)](https://arcteryx.atlassian.net/wiki/spaces/OPE/pages/7660273683)

**Templates** (local references — use as structural guide):
- Combined: #[[file:assets/templates/combined-requirements-and-design-L4.md]]
- Requirements only: #[[file:assets/templates/requirements-L4.md]]
- High-Level Design only: #[[file:assets/templates/high-level-design-L4.md]]

---

## Steps

1. **Gather context**

   Read the OpenSpec change artifacts if they exist:
   ```bash
   openspec status --change "<name>" --json
   ```
   Read `proposal.md`, `design.md`, and `specs/**/*.md` from the change directory.

   If no OpenSpec change exists, gather context from:
   - The user's description
   - Relevant Confluence pages (fetch via Atlassian MCP)
   - Existing codebase (domain model, ports, adapters)
   - Solution review pages (if referenced)

2. **Select template**

   Based on user preference or feature complexity:
   - **Combined template** → for features that benefit from a single document (most common)
   - **Split templates** → for large features where Requirements and Design are reviewed by different audiences

   Load the appropriate template from `assets/templates/`:
   - Combined: `assets/templates/combined-requirements-and-design-L4.md`
   - Requirements: `assets/templates/requirements-L4.md`
   - Design: `assets/templates/high-level-design-L4.md`

3. **Identify canonical data mapping pages**

   For external system integrations, find canonical data mapping reference pages:
   - Example: [Reservation API - Data Mapping Reference - SAP OAA](https://arcteryx.atlassian.net/wiki/spaces/OPE/pages/7677116500)

   The L4 doc should **reference** (not duplicate) canonical mapping pages, including only a summary table with a callout linking to the full reference.

4. **Create the L4 document**

   Follow the template structure exactly. Replace all `{placeholder}` tokens with feature-specific content. Remove sections marked `(if applicable)` that don't apply. Add sections if the feature demands them.

   Write to:
   - Combined: `docs/{TICKET}-{feature-kebab-name}-requirements-and-design-L4.md`
   - Split: `docs/{TICKET}-{feature-kebab-name}-requirements-L4.md` + `docs/{TICKET}-{feature-kebab-name}-high-level-design-L4.md`

5. **Validate against quality checklist**

   Run the quality checklist (below) before presenting. Fix any gaps.

6. **Show the result**

   Confirm file(s) created, word count, section count, diagram count, requirement count.

---

## Template Usage Rules

### Placeholder Tokens

All templates use `{curly-brace}` tokens for variable content. Replace ALL of them:
- `{Feature Name}` → e.g., "Soft Reservation Lifecycle"
- `{TICKET-ID}` → e.g., "ORDER-352"
- `{service-name}` → e.g., "Reservation.Api"
- `{YYYY-MM-DD}` → current date

### Conditional Sections

Sections marked `(if applicable)` in templates:
- **Include** if the feature has that concern (messaging topology, migration seam, strategy pattern)
- **Remove entirely** if not applicable — don't leave empty sections

### HTML Comments

Templates contain `<!-- HTML comments -->` with writing guidance. These are:
- **For the agent only** — they guide content generation
- **Remove from final output** — the published document should have no HTML comments

### Diagram Requirements

Every L4 document MUST include:
- **Minimum 3 mermaid diagrams** (High-Level Data Flow + Processing Pipeline + Architecture View)
- **Maximum 8 mermaid diagrams** (don't over-diagram simple features)
- Use the diagram types from templates as a starting point
- Add feature-specific diagrams (state machines, sequence diagrams) as needed

### Requirement Numbering

- Sequential: Requirement 1, Requirement 2, ... Requirement N
- **Minimum 5 requirements** for any L4-worthy feature
- **Maximum ~15 requirements** — if more, split into multiple L4 docs
- One atomic concern per requirement
- All acceptance criteria use WHEN/THE + SHALL/MUST

---

## Document Structure Quick Reference

### Requirements L4 (Sections)

```
1. Metadata table
2. Introduction (with Scope Boundary)
3. Data Flow Diagrams (High-Level + Pipeline + Domain-Specific + Migration Seam)
4. Glossary
5. Requirements (Requirement 1..N with User Story + Acceptance Criteria)
```

### High-Level Design L4 (Sections)

```
1. Metadata table
2. Overview (architecture choices as bullets)
3. Hexagonal Architecture View (mermaid)
4. Queue/Messaging Topology (mermaid, if applicable)
5. Strategy Resolution Flow (mermaid, if applicable)
6. Retry and Exhaustion Flow (mermaid, if applicable)
7. Components and Interfaces (tables per layer)
8. Strategy Resolution Table (if applicable)
9. Error Handling (failure matrix table)
10. Key Design Decisions (decision table)
11. Technology Stack (table)
12. Open Questions (if any)
13. References
```

### Combined L4 (Sections)

```
1. Metadata table
2. Introduction (with Scope Boundary)
3. Data Flow Diagrams
4. Glossary
5. Requirements (numbered, with User Story + AC)
6. High-Level Design
   6a. Overview
   6b. Hexagonal Architecture View
   6c. Topology diagrams
   6d. Components and Interfaces
   6e. Strategy/Resolution tables
   6f. Error Handling
   6g. Key Design Decisions
   6h. Technology Stack
7. Open Questions
8. References
```

---

## Section Writing Guidelines

### Introduction
- 2-3 paragraphs, no more
- First paragraph: WHAT (service name, feature purpose, platform role)
- Second paragraph: HOW (patterns, processing model, key integrations)
- Third paragraph: CONTEXT (related features, dependencies, prerequisites)
- Final: **Scope Boundary** — explicit IN/OUT with references

### Data Flow Diagrams
- `flowchart LR` for system-level overview (left-to-right shows data direction)
- `flowchart TD` for pipeline/sequential steps (top-down shows order)
- `stateDiagram-v2` for entity lifecycle
- `sequenceDiagram` for multi-system interactions (use sparingly)
- Label ALL nodes descriptively (not step1/step2)
- Show ALL error paths (every branch must terminate)

### Glossary
- Every domain term used in the document
- Composite concepts with their composition (e.g., "Composite key: OrderNumber + Status + Timestamp")
- Pattern names with what they mean in THIS context
- Alphabetical order

### Requirements
- WHEN/THE format for acceptance criteria (normative language)
- SHALL/MUST — not should/may (those are too weak for L4)
- One concern per requirement (testable in isolation)
- Reference design decisions: (DA-N), (DL-N), (NFR-N)
- Categories to consider (not all required):
  1. Inbound processing / Ingestion
  2. Routing / Strategy resolution
  3. Business logic / State transitions
  4. Output / Event emission / Persistence
  5. Idempotency / Deduplication
  6. External integration (with full error handling)
  7. Migration / Backward compatibility
  8. Pipeline / Execution model
  9. Observability / Monitoring
  10. Extensibility / Multi-tenancy
  11. Concurrency safety
  12. Resilience / Graceful degradation

### Components Tables
- One table per architectural layer (Adapters In, Application, Domain, Ports Out, Adapters Out)
- Bold component names
- One sentence per responsibility (max)
- Include interface names (IOrderMessageRepository, not just "repo")

### Error Handling Table
- Cover ALL failure points end-to-end
- Differentiate: Immediate retry (Polly) vs. Broker retry (NACK) vs. Exhaustion
- Include sustained vs. transient failure differentiation
- Add constraint notes (e.g., "enforcementMaxRetries < generalMaxRetries")

### Design Decisions
- WHAT was decided (category)
- WHICH option was chosen (with brief description)
- WHY (rationale — benefits + rejected alternatives when non-obvious)

### Technology Stack
- Specific versions (.NET 10.0, not just ".NET")
- Library names (Ocp.Cqrs, not just "CQRS framework")
- Include architecture patterns as a row

---

## Quality Checklist

Before presenting the document, verify ALL items:

**Structure:**
- [ ] Metadata table at top (Ticket, Service, Status, Author, Date)
- [ ] Introduction with explicit Scope Boundary
- [ ] All placeholder tokens replaced (no remaining `{...}`)
- [ ] No HTML comments in final output
- [ ] Conditional sections removed if not applicable

**Diagrams:**
- [ ] At least 3 mermaid diagrams present
- [ ] High-Level Data Flow (flowchart LR) showing system boundaries
- [ ] Processing Pipeline (flowchart TD) with ALL error paths
- [ ] Hexagonal Architecture View (flowchart LR) with all layers
- [ ] All diagram nodes labeled descriptively
- [ ] No orphan nodes (every node connects to something)

**Requirements:**
- [ ] Numbered sequentially (Requirement 1, 2, 3...)
- [ ] Each has User Story + Acceptance Criteria
- [ ] SHALL/MUST used (not should/may)
- [ ] WHEN/THE format for criteria
- [ ] Minimum 5 requirements
- [ ] Each requirement is atomic (one concern)
- [ ] Error paths covered (not just happy path)

**Design:**
- [ ] Component tables per architectural layer
- [ ] Error Handling failure matrix (complete)
- [ ] Key Design Decisions table with rationale
- [ ] Technology Stack table with versions
- [ ] Strategy Resolution Table (if strategy pattern used)

**Content Quality:**
- [ ] Glossary with all domain terms
- [ ] Open Questions table (or explicitly removed if none)
- [ ] References section with Confluence links
- [ ] No duplicate content with canonical mapping pages (reference only)
- [ ] Word count appropriate (Requirements: 1500-2500, Design: 1500-2500, Combined: 2500-4000)

---

## Common Mistakes

| Mistake | Fix |
| --- | --- |
| Leaving `{placeholder}` tokens in output | Search for `{` before finalizing |
| Leaving HTML comments in output | Remove ALL `<!-- ... -->` blocks |
| Duplicating data mapping tables from canonical reference | Use callout + link, include only summary |
| Missing error paths in pipeline diagram | Every branch must show failure handling |
| Vague acceptance criteria ("system should work") | Use WHEN/THEN with specific conditions and outcomes |
| Missing scope boundary | Always state what's IN and OUT explicitly |
| No state transition diagram for entities with lifecycle | Add stateDiagram-v2 |
| Design decisions without rationale | Always explain WHY, not just WHAT |
| Mermaid wrapped in markdown code blocks | Use ` ```mermaid ` directly |
| Too many requirements (20+) | Split into multiple L4 docs or combine related ones |
| Requirements not atomic | Split "ingestion and validation" into separate requirements |
| Using "should" instead of "SHALL" | L4 is normative — use SHALL/MUST |
| Empty conditional sections left in | Remove entire section if not applicable |
| Missing port interface names | Always use I-prefixed interface names in component tables |

---

## When NOT to Use

- Bug fixes (no L4 needed)
- Trivial changes (config, dependency bumps)
- Changes without external system integration or new capabilities
- When a simpler OpenSpec proposal + tasks is sufficient

## When to Use

- New feature with external system integration (SAP OAA, RabbitMQ, ArcBus, etc.)
- Feature requiring cross-team alignment (documented requirements + design)
- Feature intended for Confluence publication for stakeholder review
- Complex state machines or data flows needing visual documentation
- Any ORDER-XXX feature ticket that benefits from L4-level specification
- Features with pipeline/strategy patterns that need clear routing documentation

---

## Example Invocations

**From an OpenSpec change:**
```
Create an L4 spec for the feature-order-352 change using the combined template.
```

**From a Jira ticket:**
```
Enrich ORDER-352 into a full L4 requirements and design document.
```

**Split mode:**
```
Create separate Requirements L4 and High-Level Design L4 documents for ORDER-353.
```

**From a Confluence solution review:**
```
Take the solution review at [URL] and produce a formal L4 spec from it.
```
