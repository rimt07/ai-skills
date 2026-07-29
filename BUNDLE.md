# AI Skills Collection Bundle

name: AI Skills Collection - Comprehensive Agent Skills Bundle
description: A comprehensive collection of 40+ specialized AI agent skills for software development, project management, and workflow automation. Provides reusable artifacts (skills, agents, hooks, instructions) combined into structured workflows for coding agents — driving idea → exploration → specification → implementation → verification → delivery with deterministic guardrails and multi-platform compatibility through APM (Agent Package Manager).

authors:
  - Roberto Meza <rimt07@gmail.com>

owner: rimt07
sdlc_phase: Full SDLC Coverage
support_level: Community Supported
project_deployments: 
    - APM-Compatible Platforms
    - Claude Code
    - GitHub Copilot
    - Cursor
    - Codex
    - Gemini Code
    - Windsurf
    - Kiro CLI
    - OpenCode

use_cases: 
    - OpenSpec Workflow Management
    - Code Analysis & Intelligence
    - Test-Driven Development
    - Security Auditing & Hardening
    - Performance Optimization
    - API & Interface Design
    - Documentation & ADRs
    - Git Workflow & Versioning
    - Incremental Implementation
    - Planning & Task Breakdown
    - Code Review & Quality Assurance
    - Debugging & Error Recovery
    - Frontend UI Engineering
    - CI/CD & Automation
    - Browser Testing with DevTools
    - Deprecation & Migration Management
    - Context Engineering
    - Agent Memory Protocol
    - User Story Enrichment
    - Parallel Task Execution
    - Shipping & Launch Preparation
    - Source-Driven Development
    - Spec-Driven Development
    - Meta-Prompt Engineering
    - Adversarial Review & Verification

## Core Workflows

### 1. OpenSpec Workflow (Primary)
Complete specification-driven change management from idea to delivery:
- **openspec-new-change**: Initialize structured change process
- **openspec-explore**: Collaborative idea exploration and requirements clarification
- **openspec-propose**: Generate comprehensive change proposals with all artifacts
- **openspec-apply-change**: Systematic task implementation
- **openspec-verify-change**: Implementation validation against specifications
- **openspec-archive-change**: Finalize and archive completed changes

### 2. Development Intelligence Workflow
Semantic code understanding and quality assurance:
- **code-analisys-intelligence-protocol**: AST-based semantic analysis
- **debugging-and-error-recovery**: Systematic root-cause analysis
- **test-driven-development**: TDD methodology implementation
- **code-review-and-quality**: Multi-axis quality assessment
- **security-and-hardening**: Vulnerability assessment and mitigation

### 3. Project Management Workflow
Structured planning and delivery management:
- **planning-and-task-breakdown**: Work decomposition and estimation
- **incremental-implementation**: Staged delivery methodology
- **run-parallel-tasks**: Multi-stream parallel execution
- **shipping-and-launch**: Production readiness validation

## Platform Integration

This bundle integrates seamlessly with:

### APM (Agent Package Manager) - Recommended
```bash
apm install rimt07/ai-skills
```

### Legacy Skills CLI
```bash
npx skills add rimt07/ai-skills --skill '*' -y -a kiro-cli -g
```

## Bundle Architecture

```
ai-skills/
├── apm.yml                    # APM package manifest
├── .apm/                      # APM source directory
│   ├── skills/               # 40+ specialized skills
│   ├── agents/               # Agent definitions
│   ├── hooks/                # Lifecycle hooks
│   ├── instructions/         # Always-on rules
│   ├── prompts/              # Reusable prompts
│   └── context/              # Shared context
├── skills/                   # Legacy skills directory
├── agents/                   # Agent role definitions
└── docs/                     # Comprehensive documentation
```

## Quality Guardrails

- **Deterministic Workflows**: Structured artifact progression prevents hallucination
- **Multi-Agent Verification**: Independent review and validation cycles
- **Source-Driven Development**: Authoritative documentation grounding
- **Incremental Delivery**: Risk mitigation through staged implementation
- **Security-First**: OWASP compliance and hardening protocols

## Compatibility Matrix

| Platform | Installation Method | Compatibility |
|----------|-------------------|---------------|
| Kiro CLI | APM / Skills CLI | ✅ Full |
| Claude Code | APM | ✅ Full |
| Cursor | APM | ✅ Full |
| GitHub Copilot | APM | ✅ Full |
| Windsurf | APM | ✅ Full |
| Gemini Code | APM | ✅ Full |
| Codex | APM | ✅ Full |
| OpenCode | APM | ✅ Full |

## License

MIT License - Comprehensive agent skills collection for accelerated development workflows.