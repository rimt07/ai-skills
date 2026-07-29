# APM Usage Examples

This document provides examples of how to use the AI Skills Collection with APM (Agent Package Manager).

## Installation Examples

### Complete Package Installation

```bash
# Install all skills and agents
apm install rimt07/ai-skills
```

### Specific Skills Installation

```bash
# Install only the OpenSpec workflow skill
apm install rimt07/ai-skills --skill openspec-workflow-custom

# Install multiple specific skills
apm install rimt07/ai-skills --skill code-analisys-intelligence-protocol
apm install rimt07/ai-skills --skill debugging-and-error-recovery
```

### Target-Specific Installation

```bash
# Install for Claude only
apm install rimt07/ai-skills --target claude

# Install for Cursor only  
apm install rimt07/ai-skills --target cursor

# Install for GitHub Copilot only
apm install rimt07/ai-skills --target copilot
```

## Project Setup Examples

### Basic Project Setup

```bash
# Create a new project with APM
mkdir my-project
cd my-project
apm init my-project

# Install the skills collection
apm install rimt07/ai-skills

# Your project now has all skills available
```

### Custom apm.yml Configuration

```yaml
name: my-custom-project
version: 1.0.0
description: My project with AI skills
author: Your Name

# Target specific platforms
targets:
  - claude
  - cursor
  - copilot

# Dependencies
dependencies:
  apm:
    - rimt07/ai-skills                    # Full collection
    - rimt07/ai-skills/skills/explain     # Specific skill
  mcp: []

# Custom scripts
scripts:
  review: "echo 'Running code review'"
  test: "echo 'Running tests'"
```

### Development Workflow

```bash
# Install dependencies
apm install

# Compile for all targets
apm compile

# Compile for specific target
apm compile --target claude

# Update dependencies
apm update

# Run custom scripts
apm run review
apm run test
```

## Skill Usage Examples

### OpenSpec Workflow

Once installed, you can use the OpenSpec workflow skill:

```
# In your AI agent conversation
Use the openspec-workflow-custom skill to create a new feature proposal
```

### Code Analysis

```
# In your AI agent conversation  
Use the code-analisys-intelligence-protocol skill to analyze this codebase
```

### Writing Assistance

```
# In your AI agent conversation
Use the writing-skills skill to improve this technical documentation
```

## Advanced Usage

### Private Repository

```bash
# Set GitHub token for private repos
export GITHUB_APM_PAT=your_token_here

# Install from private repository
apm install your-org/private-skills
```

### Local Development

```bash
# Link local package for development
apm link ./local-skills-package

# Install from local directory
apm install ./local-skills-package
```

### Marketplace Usage

```bash
# Add a marketplace
apm marketplace add github/awesome-copilot

# Install from marketplace
apm install awesome-copilot-skills@github/awesome-copilot
```

## Verification

### Check Installation

```bash
# List installed packages
apm list

# View package details
apm view rimt07/ai-skills

# Check what targets are configured
apm targets
```

### Audit and Security

```bash
# Audit installed packages
apm audit

# Check for security issues
apm audit --security

# Check for outdated packages
apm outdated
```

### Troubleshooting

```bash
# Check APM doctor for issues
apm doctor

# Clear cache if needed
apm cache clean

# Reinstall packages
apm install --force
```

## Platform-Specific Examples

### Claude Code

After installation, your `.claude/` directory will contain:
- Skills in `.claude/skills/`
- Instructions in `.claude/instructions/`
- Agents in `.claude/agents/`

### GitHub Copilot

After installation, your `.github/` directory will contain:
- Instructions in `.github/copilot-instructions.md`
- Skills in `.github/skills/`

### Cursor

After installation, your `.cursor/` directory will contain:
- Rules in `.cursor/rules/`
- Skills in `.cursor/skills/`

## Integration Examples

### CI/CD Pipeline

```yaml
# .github/workflows/apm.yml
name: APM Validation

on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install APM
        run: curl -sSL https://aka.ms/apm-unix | sh
        
      - name: Install dependencies
        run: apm install --frozen
        
      - name: Compile and validate
        run: apm compile
        
      - name: Audit packages
        run: apm audit --ci
```

### Docker Usage

```dockerfile
# Dockerfile
FROM node:18-alpine

# Install APM
RUN curl -sSL https://aka.ms/apm-unix | sh

# Copy project files
COPY . .

# Install APM dependencies
RUN apm install --frozen

# Compile for production
RUN apm compile --target production
```

This comprehensive example set should help users understand how to effectively use APM with your skills collection!