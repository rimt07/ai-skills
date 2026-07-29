# Contributing to AI Skills Collection

Thank you for your interest in contributing to the AI Skills Collection! This guide will help you understand how to contribute skills and improvements to this APM-compatible package.

## Getting Started

### Prerequisites

1. Install APM:
   ```bash
   # macOS/Linux
   curl -sSL https://aka.ms/apm-unix | sh
   
   # Windows
   irm https://aka.ms/apm-windows | iex
   ```

2. Fork and clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/ai-skills.git
   cd ai-skills
   ```

3. Install the package locally:
   ```bash
   apm install
   ```

## Project Structure

The project follows APM conventions:

```
├── apm.yml                    # APM manifest (main configuration)
├── .apm/                      # Source directory for APM
│   ├── skills/               # All skills go here
│   ├── agents/               # Agent definitions
│   ├── hooks/                # Lifecycle hooks
│   ├── instructions/         # Always-on instructions
│   ├── prompts/              # Reusable prompts
│   └── context/              # Shared context files
├── skills/                   # Legacy skills (for backward compatibility)
├── agents/                   # Legacy agents
└── hooks/                    # Legacy hooks
```

## Adding a New Skill

### 1. Create the Skill Directory

Create a new directory under `.apm/skills/` with your skill name:

```bash
mkdir .apm/skills/your-skill-name
```

### 2. Create the SKILL.md File

Every skill must have a `SKILL.md` file following this template:

```markdown
# Your Skill Name

Brief description of what this skill does.

## When to Use

- Use when...
- Use when...

## When NOT to Use

- Don't use when...
- Avoid when...

## Implementation

[Detailed skill implementation content here]

## Examples

[Provide concrete examples of the skill in action]
```

### 3. Add Supporting Files

If your skill needs additional files (templates, scripts, references):

```
.apm/skills/your-skill-name/
├── SKILL.md                  # Main skill file
├── templates/                # Optional templates
├── examples/                 # Optional examples
└── references/               # Optional reference materials
```

### 4. Test Your Skill

1. Compile the package:
   ```bash
   apm compile
   ```

2. Test with different targets:
   ```bash
   apm compile --target claude
   apm compile --target cursor
   apm compile --target copilot
   ```

3. Validate the skill works as expected

### 5. Update Documentation

If you're adding a significant skill:

1. Add it to the list in `README.md`
2. Update the `apm.yml` if needed
3. Add any relevant documentation to `docs/`

## Adding Other Primitives

### Instructions

Add always-on rules to `.apm/instructions/`:

```markdown
# instruction-name.md

Instructions that should always be active for specific file patterns.
```

### Prompts

Add reusable prompts to `.apm/prompts/`:

```markdown
# prompt-name.prompt.md

Reusable prompt template that can be invoked by agents.
```

### Agents

Add agent definitions to `.apm/agents/`:

```markdown
# agent-name.agent.md

Agent definition with model, system prompt, and tool configurations.
```

## Testing Guidelines

1. **Validate with APM**: Always run `apm compile` after changes
2. **Test Multiple Targets**: Ensure compatibility across platforms
3. **Test Dependencies**: If your skill depends on others, test the combination
4. **Test Edge Cases**: Include error scenarios in your examples

## Submission Guidelines

### Pull Request Process

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-skill-name
   ```

2. Make your changes following the guidelines above

3. Test thoroughly:
   ```bash
   apm compile
   apm validate  # if available
   ```

4. Commit with clear messages:
   ```bash
   git add .
   git commit -m "feat: add your-skill-name skill for specific use case"
   ```

5. Push and create a pull request:
   ```bash
   git push origin feature/your-skill-name
   ```

### PR Requirements

- [ ] Skill follows the `SKILL.md` template
- [ ] Code compiles without errors (`apm compile`)
- [ ] Documentation is updated (README.md if significant)
- [ ] Examples are provided and tested
- [ ] Backward compatibility maintained (legacy structure)

### Code Review Process

1. Automated checks will run (APM compilation, validation)
2. Maintainers will review for:
   - Skill quality and usefulness
   - Documentation completeness
   - APM compatibility
   - Following conventions
3. Address any feedback
4. Once approved, the skill will be merged

## Style Guidelines

### File Naming

- Skills: `kebab-case-name`
- Files: `lowercase-with-dashes.md`
- Directories: `kebab-case`

### Skill Quality Standards

- **Clear Purpose**: Each skill should have a specific, well-defined purpose
- **Good Documentation**: Include when to use, when not to use, and examples
- **Practical Examples**: Provide real-world usage scenarios
- **Error Handling**: Consider edge cases and error scenarios
- **Platform Compatibility**: Ensure the skill works across supported platforms

### Markdown Standards

- Use clear headings (`#`, `##`, `###`)
- Include code blocks with language specification
- Use bullet points for lists
- Keep lines under 100 characters when possible

## Questions and Support

- Open an issue for questions about contributing
- Check existing issues before creating new ones
- Tag maintainers (@rimt07) for urgent questions
- Use discussions for general questions about skills

## License

By contributing, you agree that your contributions will be licensed under the MIT License.