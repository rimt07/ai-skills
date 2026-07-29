# Migration from Skills CLI to APM

This guide helps you migrate from the legacy `npx skills add` installation method to the new APM (Agent Package Manager) system.

## Why Migrate?

APM offers several advantages over the legacy skills CLI:

- **Cross-platform compatibility**: Works with Claude, Cursor, Copilot, Codex, Gemini, Windsurf, Kiro, and OpenCode
- **Dependency management**: Proper versioning and dependency resolution
- **Reproducible builds**: Lockfile ensures consistent installations
- **Security**: Content validation and integrity checks
- **Better organization**: Structured package management

## Migration Steps

### Step 1: Install APM

First, install the APM CLI:

```bash
# macOS/Linux
curl -sSL https://aka.ms/apm-unix | sh

# Windows (PowerShell)
irm https://aka.ms/apm-windows | iex
```

### Step 2: Remove Legacy Skills (Optional)

If you want a clean migration, you can remove the existing skills installation:

```bash
# This removes the global skills installation
npx skills remove rimt07/ai-skills --all -y
```

### Step 3: Initialize APM in Your Project

```bash
# In your project directory
apm init your-project-name
```

### Step 4: Install the Skills Collection

```bash
# Install the complete collection (equivalent to npx skills add rimt07/ai-skills --skill '*')
apm install rimt07/ai-skills

# Or install specific skills
apm install rimt07/ai-skills --skill openspec-workflow-custom
```

## Command Comparison

### Legacy Skills CLI vs APM

| Legacy Skills CLI | APM Equivalent | Description |
|------------------|----------------|-------------|
| `npx skills add rimt07/ai-skills --skill '*'` | `apm install rimt07/ai-skills` | Install all skills |
| `npx skills add rimt07/ai-skills --skill specific-skill` | `apm install rimt07/ai-skills --skill specific-skill` | Install specific skill |
| `npx skills remove rimt07/ai-skills` | `apm uninstall rimt07/ai-skills` | Remove skills |
| `npx skills list` | `apm list` | List installed skills |
| `npx skills update` | `apm update` | Update skills |

### Agent-Specific Installation

| Agent | Legacy | APM |
|-------|--------|-----|
| Kiro CLI | `npx skills add rimt07/ai-skills -a kiro-cli -g` | `apm install rimt07/ai-skills --target kiro` |
| Claude | Manual setup | `apm install rimt07/ai-skills --target claude` |
| Cursor | Manual setup | `apm install rimt07/ai-skills --target cursor` |
| Copilot | Manual setup | `apm install rimt07/ai-skills --target copilot` |

## Configuration Migration

### Before (Skills CLI)

Skills CLI used global installation and agent-specific flags:

```bash
npx skills add rimt07/ai-skills --skill '*' -y -a kiro-cli -g
```

### After (APM)

APM uses a project-based `apm.yml` manifest:

```yaml
name: your-project
version: 1.0.0
description: Your project with AI skills

targets:
  - kiro
  - claude
  - cursor

dependencies:
  apm:
    - rimt07/ai-skills
```

## Verification

### Check Your Migration

1. **Verify APM installation**:
   ```bash
   apm --version
   ```

2. **Check installed packages**:
   ```bash
   apm list
   ```

3. **Verify compilation**:
   ```bash
   apm compile
   ```

4. **Check generated files**:
   ```bash
   # You should see directories like .claude/, .cursor/, .kiro/, etc.
   ls -la
   ```

### Expected Directory Structure After Migration

```
your-project/
├── apm.yml                    # APM manifest
├── apm.lock.yaml             # APM lockfile (generated)
├── apm_modules/              # APM cache (gitignored)
├── .claude/                  # Claude-specific files
├── .cursor/                  # Cursor-specific files
├── .kiro/                    # Kiro-specific files
├── .github/                  # Copilot-specific files
└── .agents/                  # Cross-platform skills
```

## Troubleshooting

### Common Issues

1. **APM not found after installation**:
   ```bash
   # Restart your terminal or run:
   source ~/.bashrc  # Linux
   source ~/.zshrc   # macOS with zsh
   ```

2. **Permissions issues on macOS/Linux**:
   ```bash
   # Fix permissions
   sudo chown -R $(whoami) ~/.apm
   ```

3. **Skills not appearing in agent**:
   ```bash
   # Recompile
   apm compile
   
   # Check if target directories exist
   ls -la .claude/ .cursor/ .kiro/
   ```

4. **Dependency conflicts**:
   ```bash
   # Clear cache and reinstall
   apm cache clean
   apm install
   ```

### Getting Help

If you encounter issues during migration:

1. Check the [APM documentation](https://microsoft.github.io/apm/)
2. Run `apm doctor` for diagnostic information
3. Open an issue in the [repository](https://github.com/rimt07/ai-skills/issues)
4. Include the output of:
   ```bash
   apm doctor
   apm list
   cat apm.yml
   ```

## Benefits After Migration

Once migrated to APM, you'll have:

- **Multi-platform support**: Same skills work across all supported agents
- **Version control**: Proper dependency management with lockfiles
- **Reproducible environments**: Team members get identical setups
- **Security**: Package validation and integrity checks
- **Future-proof**: Active development and Microsoft backing

## Rollback (if needed)

If you need to rollback to the legacy system:

```bash
# Remove APM installation
apm uninstall rimt07/ai-skills

# Remove APM files
rm apm.yml apm.lock.yaml
rm -rf apm_modules/ .claude/ .cursor/ .kiro/ .agents/

# Reinstall with legacy method
npx skills add rimt07/ai-skills --skill '*' -y -a kiro-cli -g
```

However, we recommend persisting with APM as it's the future-proof solution!

## Need Help?

- 📖 [APM Documentation](https://microsoft.github.io/apm/)
- 🐛 [Report Issues](https://github.com/rimt07/ai-skills/issues)
- 💬 [Discussions](https://github.com/rimt07/ai-skills/discussions)
- 📧 Contact: roberto.meza@example.com