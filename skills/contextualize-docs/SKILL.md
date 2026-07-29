---
name: contextualize-docs
description: >
  Customizes a project's technical context documents (by default in docs/) to reflect
  the real stack, architecture, coding conventions, domain terminology, API endpoints,
  and data entities of the current project. Use this skill whenever the user asks to
  "customize docs", "update technical documents", "adapt context documents to this
  project", "set up project documentation", or when an onboarding pipeline requests
  document customization. Also triggers when the user says the docs/ folder (or any
  named folder) has generic or template content that needs to reflect the real project.
  Accepts an optional `folder` parameter (default: "docs") to target a different directory.
author: rimt07 and basaar.24
version: 1.0.0
parameters:
  folder:
    type: string
    default: docs
    description: >
      The folder containing the technical context documents to customize.
      Defaults to "docs". Pass a different name if your project uses a
      different convention (e.g., "documentation", "context", "ai-docs").
---

# Customize Docs Skill

Customizes all technical context documents inside `{folder}/` to reflect this project's
real stack, patterns, conventions, and domain — making them immediately useful for AI agents.

## When this skill runs

- **On demand**: user asks to customize, update, or adapt the docs folder
- **Onboarding pipeline**: called automatically as part of project onboarding after
  Serena indexing and Graphify graph generation are complete

---

## Pre-flight checks

Before making any changes:

1. Confirm the target folder exists: `{folder}/`
   - If it does not exist, stop and tell the user. Do not create it from scratch.
2. List all files currently inside `{folder}/` and present them to the user.
3. Read every file before modifying anything — understand the existing structure first.
4. If `graphify-out/GRAPH_REPORT.md` exists, read it. Use god nodes, communities, and
   dependency edges to inform architecture descriptions and critical dependency sections.
5. If Serena is active, use it to query real symbols, namespaces, and entities rather
   than inferring them from file names alone.

---

## Customization rules

Apply these rules to every file inside `{folder}/`:

### General

- Keep the same file names — do not rename, add, or remove files.
- Replace all generic/template content with project-specific facts.
- Keep everything in English.
- Make all guidance implementation-ready for AI agents: concrete, unambiguous, actionable.
- Ensure cross-file consistency — terminology, component names, and conventions must
  match across all documents.

### Backend standards

- Reflect the actual backend language, framework, and version in use.
- Document real architectural patterns (CQRS, Clean Architecture, repository pattern, etc.)
  only if the project actually uses them.
- Name real namespaces, projects, and layers as they exist in the codebase.

### Frontend standards

- Reflect the actual frontend framework, state management library, and component conventions.
- Use real folder structure and naming conventions observed in the codebase.

### Documentation standards

- Reflect how this team actually documents code (XML docs, JSDoc, inline comments, ADRs, etc.).

### API spec (`{folder}/api-spec.yml`)

- Replace placeholder endpoints with real routes discovered from the codebase.
- Use actual HTTP methods, path parameters, request bodies, and response shapes.
- Group endpoints by real domain boundaries, not generic categories.

### Data model (`{folder}/data-model.md`)

- Replace placeholder entities with real domain entities and their actual fields.
- Reflect real relationships (one-to-many, many-to-many) as they exist in the schema.
- Use the same naming convention the codebase uses (PascalCase, snake_case, etc.).

---

## Output checklist

Before finishing, verify:

- [ ] No file was renamed, added, or deleted inside `{folder}/`
- [ ] No generic/template language remains (search for words like "example", "placeholder",
      "your project", "TBD", "TODO" and replace them all)
- [ ] `{folder}/api-spec.yml` reflects real endpoints
- [ ] `{folder}/data-model.md` reflects real entities
- [ ] All cross-references between files are internally consistent
- [ ] Guidance is concrete enough for an AI agent to act on without further clarification

Report back with a summary of what changed in each file.

---

## Onboarding pipeline usage

When called from an onboarding pipeline, this skill expects the following to already be complete:

1. Serena onboarding and index built
2. Graphify graph generated (`graphify-out/GRAPH_REPORT.md` present)

If either is missing, notify the pipeline orchestrator and wait — do not proceed with
generic content that will need to be redone after indexing.

Pipeline invocation example (in CLAUDE.md or orchestration prompt):

```
Run the customize-docs skill targeting the "{folder}" folder.
```
