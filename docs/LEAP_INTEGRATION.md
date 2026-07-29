# LEAP Marketplace Integration

This document explains how to use the AI Skills Collection through EPAM's LEAP AI Marketplace.

## What is LEAP?

LEAP (Learning, Engagement, and AI Platform) is EPAM's internal AI marketplace that provides curated AI tools, skills, and agents for EPAM teams and projects.

## Installation via LEAP

### Prerequisites

1. **EPAM Network Access**: You must be connected to EPAM's network or VPN
2. **LEAP Account**: Valid EPAM credentials with LEAP access
3. **APM Installation**: APM must be installed on your system

### Installation Methods

#### Method 1: Direct LEAP Installation

```bash
# Access LEAP marketplace
leap marketplace search "ai-skills"

# Install the complete collection
leap install epam.ai-skills

# Or install via APM with LEAP registry
apm marketplace add leap
apm install ai-skills@leap
```

#### Method 2: APM with LEAP Registry

```bash
# Add LEAP as a marketplace
apm marketplace add leap --registry https://git.epam.com/epm-ease/apm-registry

# Install from LEAP registry  
apm install rimt07/ai-skills@leap
```

#### Method 3: Enterprise Bundle

```bash
# Install enterprise bundle with EPAM-specific configurations
leap bundle install ai-skills-enterprise
```

## LEAP-Specific Features

### Enterprise Integration

When installed via LEAP, the skills collection includes:

- **EPAM Code Standards**: Pre-configured with EPAM coding standards
- **Enterprise Security**: Enhanced security policies for enterprise use
- **Compliance Tools**: Built-in compliance checking for EPAM projects
- **Team Collaboration**: Enhanced team workflow features

### Supported LEAP Platforms

- ✅ **EPAM Claude Enterprise**
- ✅ **EPAM GitHub Copilot Enterprise** 
- ✅ **Cursor Enterprise**
- ✅ **Codex Enterprise**
- ✅ **Internal AI Platforms**

## Configuration for LEAP

### Enterprise Configuration File

Create a `leap-config.yml` in your project:

```yaml
# LEAP Enterprise Configuration
leap:
  environment: "enterprise"
  compliance: "epam-standard"
  
  # EPAM-specific settings
  epam:
    division: "your-division"
    project_code: "your-project-code"
    security_level: "internal"
    
  # Skill customization for LEAP
  skills:
    openspec-workflow-custom:
      enabled: true
      epam_templates: true
    code-analisys-intelligence-protocol:
      enabled: true
      epam_standards: true
    owasp-security-audit:
      enabled: true
      epam_policies: true

  # Enterprise features
  features:
    audit_logging: true
    compliance_checking: true
    team_collaboration: true
    enterprise_templates: true
```

### Team Project Setup

```bash
# Initialize LEAP-enabled project
leap init my-epam-project --template ai-skills

# Install skills with enterprise configuration
leap install ai-skills --config enterprise

# Enable team collaboration features
leap team setup --skills ai-skills
```

## LEAP Marketplace Categories

The AI Skills Collection is available in these LEAP categories:

- **🛠️ Development & Engineering**
  - Code Analysis Tools
  - Debugging Utilities
  - Testing Frameworks

- **🤖 AI & Machine Learning**
  - AI Agent Skills
  - Prompt Engineering
  - Workflow Automation

- **📋 Project Management**
  - OpenSpec Methodology
  - Task Breakdown Tools
  - Planning Utilities

- **🔒 Security & Compliance**
  - OWASP Audit Tools
  - Security Hardening
  - Compliance Checking

## Enterprise Support

### LEAP Support Channels

- **📧 Email**: leap-support@epam.com
- **💬 Slack**: #leap-ai-marketplace
- **📝 Tickets**: LEAP Support Portal
- **📚 Documentation**: LEAP Internal Wiki

### SLA for Enterprise Users

- **Response Time**: 4 hours during business hours
- **Resolution Time**: 1-2 business days for standard issues
- **Escalation**: Available for critical production issues

## Usage Examples

### Basic Enterprise Workflow

```bash
# 1. Setup LEAP environment
leap auth login
leap profile set --division "Digital Platform"

# 2. Create new project with AI skills
leap project create my-ai-project
cd my-ai-project

# 3. Install AI skills collection
leap install ai-skills --enterprise

# 4. Configure for your team
leap configure --team "Platform Engineering"

# 5. Start using skills
# Skills are now available in your AI agents
```

### Integration with EPAM Tools

```bash
# Integration with EPAM GitLab
leap gitlab integrate ai-skills

# Integration with EPAM Jira
leap jira configure --skills ai-skills

# Integration with EPAM Confluence
leap confluence setup --documentation ai-skills
```

## Compliance and Security

### Data Privacy

- All skills comply with EPAM data privacy policies
- No sensitive data is transmitted outside EPAM network
- Enterprise audit logging for all skill usage

### Security Features

- **Network Isolation**: Skills run within EPAM's secure network
- **Access Control**: Role-based access to different skill sets
- **Audit Trail**: Complete logging of skill usage and modifications

### Compliance Standards

- ✅ **GDPR Compliant**
- ✅ **SOX Compliant** (for relevant projects)
- ✅ **ISO 27001** aligned
- ✅ **EPAM Security Standards**

## Troubleshooting LEAP Issues

### Common Issues

1. **Authentication Failures**
   ```bash
   # Re-authenticate with LEAP
   leap auth logout
   leap auth login --refresh
   ```

2. **Registry Access Issues**
   ```bash
   # Check VPN connection
   leap connectivity test
   
   # Reset registry configuration
   leap registry reset
   leap marketplace add leap --force
   ```

3. **Installation Conflicts**
   ```bash
   # Clear LEAP cache
   leap cache clean
   
   # Reinstall with enterprise settings
   leap install ai-skills --enterprise --force
   ```

### Getting Help

For LEAP-specific issues:

1. **Check LEAP Status**: https://status.leap.epam.com
2. **Internal Documentation**: LEAP Wiki
3. **Support Ticket**: LEAP Support Portal
4. **Community**: #leap-users Slack channel

## Migration from Public APM

If you're migrating from public APM installation:

```bash
# 1. Remove public installation
apm uninstall rimt07/ai-skills

# 2. Setup LEAP
leap auth login
leap marketplace add leap

# 3. Install enterprise version
leap install ai-skills --enterprise

# 4. Migrate configuration
leap migrate-config --from apm.yml
```

This ensures you get the enterprise-enhanced version with EPAM-specific features and compliance.