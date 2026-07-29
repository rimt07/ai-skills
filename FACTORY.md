# AI Skills Collection Factory

## Overview

**Name:** AI Skills Collection  
**Version:** 1.0.0  
**Repository:** https://github.com/rimt07/ai-skills  
**Type:** Comprehensive AI Agent Skills Bundle  
**Support Level:** Community Support  

## Description

A comprehensive collection of 40+ AI agent skills for software development, project management, and workflow automation. This repository provides specialized skills that work across multiple AI agent platforms including Claude, Cursor, Copilot, Codex, Gemini, Windsurf, Kiro, and OpenCode.

## Author

- **Roberto Ivan Meza Trillo** - Lead AI Skills Developer & Repository Maintainer

## Repository Objective

The primary objective of this repository is to provide a comprehensive, cross-platform collection of AI agent skills that accelerate software development workflows. The repository aims to:

1. **Standardize AI-assisted development** across different platforms and tools
2. **Reduce development friction** through intelligent automation and guidance
3. **Improve code quality** through systematic analysis and review processes
4. **Accelerate team productivity** with structured workflows and methodologies
5. **Enable cross-platform compatibility** with APM and LEAP marketplace support

## Core Skills Categories

### 1. OpenSpec & Workflow Management
- `openspec-workflow-custom` - Complete SDLC workflow management
- `openspec-new-change` - Start new specification-driven changes
- `openspec-continue-change` - Progress through workflow artifacts
- `openspec-apply-change` - Implementation task management
- `openspec-verify-change` - Validation and verification
- `openspec-archive-change` - Change completion and archival

### 2. Code Analysis & Intelligence
- `code-analisys-intelligence-protocol` - Semantic code analysis with AST parsing
- `debugging-and-error-recovery` - Systematic debugging methodologies
- `code-review-and-quality` - Multi-axis code quality assessment
- `code-simplification` - Code clarity and maintainability improvements

### 3. Development Practices
- `test-driven-development` - TDD implementation and guidance
- `incremental-implementation` - Staged delivery methodology
- `git-workflow-and-versioning` - Git best practices and workflows
- `using-git-worktrees` - Isolated workspace management

### 4. Security & Quality
- `owasp-security-audit` - Security vulnerability assessment
- `security-and-hardening` - Code hardening best practices
- `adversarial-review` - Independent verification processes

### 5. Documentation & Communication
- `writing-skills` - Technical writing optimization
- `documentation-and-adrs` - Architecture decision records
- `explain` - Concept explanation and knowledge transfer
- `update-docs` - Documentation maintenance automation

### 6. Project Management
- `planning-and-task-breakdown` - Structured work decomposition
- `performance-optimization` - System performance improvements
- `shipping-and-launch` - Production deployment preparation

### 7. Specialized Tools
- `agent-memory-protocol` - AI agent memory management
- `meta-prompt` - Prompt engineering optimization
- `enrich-us` - User story enhancement
- `commit` - Standardized commit practices

## Installation Methods

### APM (Recommended)
```bash
# Install complete collection
apm install rimt07/ai-skills

# Install specific skills
apm install rimt07/ai-skills --skill openspec-workflow-custom
```

### LEAP Marketplace (EPAM Internal)
```bash
# Install via LEAP
leap install ai-skills

# Install with enterprise configuration
leap install ai-skills --config enterprise
```

### Legacy Skills CLI
```bash
# Legacy installation method (still supported)
npx skills add rimt07/ai-skills --skill '*' -y -a kiro-cli -g
```

## Platform Compatibility

| Platform | Status | Features |
|----------|--------|----------|
| Claude Code | ✅ Full Support | All skills, agents, instructions |
| GitHub Copilot | ✅ Full Support | Instructions, skills integration |
| Cursor | ✅ Full Support | Rules, skills, agents |
| Codex | ✅ Full Support | Skills, prompts, agents |
| Gemini Code | ✅ Full Support | Skills and instruction integration |
| Windsurf | ✅ Full Support | Complete skill deployment |
| Kiro CLI | ✅ Full Support | Native skills integration |
| OpenCode | ✅ Full Support | Skills and agent support |

## Repository Structure

```
rimt07/ai-skills/
├── apm.yml                    # APM package manifest
├── .apm/                      # APM source directory
│   ├── skills/               # 40+ AI agent skills
│   ├── agents/               # Agent definitions
│   ├── hooks/                # Lifecycle hooks
│   ├── instructions/         # Always-on rules
│   ├── prompts/              # Reusable prompts
│   └── context/              # Shared context
├── leap.yml                  # LEAP marketplace configuration
├── leap-bundle.yml           # LEAP bundle specification
├── package.json              # Package metadata
├── skills/                   # Legacy skills (compatibility)
├── agents/                   # Legacy agents (compatibility)
├── docs/                     # Documentation
│   ├── LEAP_INTEGRATION.md   # LEAP usage guide
│   └── MIGRATION.md          # Migration from legacy
├── examples/                 # Usage examples
│   └── APM_USAGE.md          # APM usage guide
├── README.md                 # Main documentation
├── CONTRIBUTING.md           # Contribution guidelines
├── LICENSE                   # MIT license
└── .gitignore               # APM-aware ignore patterns
```

## Key Features

### Cross-Platform Compatibility
- Works with all major AI agent platforms
- Consistent skill behavior across different tools
- Unified installation and management

### Enterprise Integration
- LEAP marketplace compatibility for EPAM users
- Enterprise security and compliance features
- Team collaboration and knowledge sharing

### Backward Compatibility
- Supports legacy `npx skills add` installation
- Maintains existing skill interfaces
- Smooth migration path for existing users

### Comprehensive Coverage
- Complete SDLC workflow support
- Security and quality assurance tools
- Documentation and communication aids
- Project management utilities

## Usage Benefits

### For Individual Developers
- **Faster development cycles** with AI-assisted workflows
- **Higher code quality** through systematic reviews and analysis
- **Better documentation** with automated writing assistance
- **Improved debugging** with structured methodologies

### For Teams
- **Standardized workflows** across team members
- **Knowledge sharing** through explanation and documentation skills
- **Quality gates** with security and review processes
- **Collaboration tools** with OpenSpec methodology

### For Organizations
- **Scalable AI adoption** across multiple projects and teams
- **Compliance support** with security auditing and documentation
- **Cost efficiency** through accelerated development processes
- **Risk reduction** through systematic quality and security practices

## Community & Support

### Support Channels
- **GitHub Issues**: https://github.com/rimt07/ai-skills/issues
- **GitHub Discussions**: https://github.com/rimt07/ai-skills/discussions
- **Documentation**: Repository README and docs/ directory

### Contribution
- **Open Source**: MIT licensed, community contributions welcome
- **Skill Development**: Guidelines in CONTRIBUTING.md
- **Testing**: Comprehensive testing with multiple AI platforms

### Maintenance
- **Regular Updates**: Monthly skill improvements and additions
- **Platform Compatibility**: Continuous testing across supported platforms
- **Security**: Regular security reviews and updates

## Success Metrics

### Adoption
- **40+ specialized skills** covering complete SDLC
- **Multi-platform support** with 8 major AI agent platforms
- **Enterprise ready** with LEAP marketplace integration

### Quality
- **MIT Licensed** open source with community governance
- **Comprehensive documentation** with usage examples
- **Backward compatibility** ensuring smooth adoption

### Innovation
- **OpenSpec methodology** for specification-driven development
- **Cross-platform consistency** with unified skill interfaces
- **Enterprise integration** with EPAM's LEAP marketplace

This repository represents a comprehensive solution for AI-assisted software development, providing teams and individuals with the tools needed to accelerate their development workflows while maintaining high quality and security standards.