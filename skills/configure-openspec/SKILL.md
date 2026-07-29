---
name: configure-openspec
description: >
  Updates the OpenSpec config.yml to wire the project's documentation and AI agent
  specs into the OpenSpec context. Use this skill whenever the user asks to "configure
  OpenSpec", "update openspec config", "wire docs into OpenSpec", "link ai-specs to
  OpenSpec", or when an onboarding pipeline requests OpenSpec configuration. Also
  triggers when the user says OpenSpec is not referencing the right files, or that
  a new docs or ai-specs structure needs to be reflected in config.yml.
  Accepts optional parameters to override default folder paths if the project uses
  a non-standard layout.
author: rimt07 and basaar.24
version: 1.0.0
parameters:
  config_path:
    type: string
    default: openspec/config.yml
    description: >
      Path to the OpenSpec configuration file relative to the project root.
      Defaults to "openspec/config.yml".
  docs_folder:
    type: string
    default: docs
    description: >
      Folder containing the project's technical context documents.
      Defaults to "docs".
  ai_specs_folder:
    type: string
    default: ai-specs
    description: >
      Folder containing agent definitions and workflow skills.
      Defaults to "ai-specs".
---

# Configure OpenSpec Skill

Wires the project's documentation and AI agent specs into `{config_path}` so that
OpenSpec's context block points to the right sources of truth for every coding session.

## When this skill runs

- **On demand**: user asks to configure, update, or fix the OpenSpec config
- **Onboarding pipeline**: called after `contextualize-docs` has run and the
  `{docs_folder}/` contents have been populated with project-specific content

---

## Pre-flight checks

Before modifying anything:

1. Confirm `{config_path}` exists.
   - If it does not exist, stop and tell the user. Do not create it from scratch
     unless the user explicitly asks.
2. Confirm the following files exist. Report any that are missing before proceeding:
   - `{docs_folder}/base-standards.md`
   - `{docs_folder}/backend-standards.md`
   - `{docs_folder}/frontend-standards.md`
   - `{docs_folder}/documentation-standards.md`
   - `{docs_folder}/api-spec.yml`
   - `{docs_folder}/data-model.md`
   - `{ai_specs_folder}/agents/backend-developer.md`
   - `{ai_specs_folder}/agents/frontend-developer.md`
   - `{ai_specs_folder}/skills/` (directory)
3. Read the current `{config_path}` in full before making any changes.
   Preserve any existing keys that are unrelated to the `context` block.

---

## Configuration rules

Update `{config_path}` applying the following rules:

### Source of truth
- Set `{docs_folder}/base-standards.md` as the primary context source.
  All other documents are additive — they extend, never override, the base standards.

### Context documents to include
Wire all of these under the context block, in this order:

```
{docs_folder}/base-standards.md           ← single source of truth
{docs_folder}/backend-standards.md
{docs_folder}/frontend-standards.md
{docs_folder}/documentation-standards.md
{docs_folder}/api-spec.yml
{docs_folder}/data-model.md
```

### Agent adoption
Instruct the agent to adopt the appropriate role file depending on the work being done:

- Backend work → `{ai_specs_folder}/agents/backend-developer.md`
- Frontend work → `{ai_specs_folder}/agents/frontend-developer.md`

Both agent files should be referenced so the agent can switch roles within the
same session when the task spans both layers.

### Workflow skills
Reference `{ai_specs_folder}/skills/` as the source of workflow guidance.
The agent should consult skills from this directory when executing structured tasks.

### Path convention
All paths in `{config_path}` must be relative to the project root.
Do not use absolute paths or `./` prefixes.

---

## Output checklist

Before finishing, verify:

- [ ] `{config_path}` was not replaced — only the relevant sections were updated
- [ ] `{docs_folder}/base-standards.md` is marked as the single source of truth
- [ ] All six context documents are listed in the correct order
- [ ] Both agent files are referenced with their correct relative paths
- [ ] `{ai_specs_folder}/skills/` is referenced as workflow guidance
- [ ] No absolute paths exist anywhere in the updated config
- [ ] All pre-existing unrelated keys in `{config_path}` are preserved

Report back with a diff-style summary showing what changed.

---

## Onboarding pipeline usage

When called from an onboarding pipeline, this skill expects:

1. `contextualize-docs` skill to have already run — `{docs_folder}/` should contain
   project-specific content, not generic templates
2. `{ai_specs_folder}/agents/` and `{ai_specs_folder}/skills/` to be present

If either precondition is unmet, notify the pipeline orchestrator and wait.

Pipeline invocation example (in CLAUDE.md or orchestration prompt):

```
Run the configure-openspec skill.
```

Or with non-default paths:

```
Run the configure-openspec skill with docs_folder="documentation"
and ai_specs_folder="agent-specs".
```