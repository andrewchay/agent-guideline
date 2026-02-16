# Agent Design Guidelines

A comprehensive guide for designing effective AI agent skills and capabilities.

---

## 1. Core Philosophy

### Concise is Key
The context window is a public good. Skills share context with system prompts, conversation history, and user requests.

**Default assumption: The agent is already very smart.** Only add context it doesn't already have. Challenge each piece of information:
- "Does the agent really need this explanation?"
- "Does this paragraph justify its token cost?"

Prefer concise examples over verbose explanations.

### Set Appropriate Degrees of Freedom

Match specificity to task fragility:

| Freedom Level | Use When | Form |
|--------------|----------|------|
| **High** | Multiple valid approaches, context-dependent decisions | Text-based instructions |
| **Medium** | Preferred pattern exists, some variation acceptable | Pseudocode or scripts with parameters |
| **Low** | Fragile operations, consistency critical | Specific scripts, few parameters |

Think of it as a path: narrow bridges need guardrails (low freedom), open fields allow many routes (high freedom).

---

## 2. Skill Structure

### Anatomy of a Skill

```
skill-name/
├── SKILL.md              # Required: Instructions and metadata
├── scripts/              # Optional: Executable code
├── references/           # Optional: Documentation loaded on demand
└── assets/               # Optional: Templates, icons, fonts
```

### SKILL.md Structure

```markdown
---
name: skill-name
description: Clear description of what the skill does and when to use it.
---

# Skill Title

Brief overview.

## Quick Start
[Essential getting started info]

## Core Principles
[Key guidelines]

## Detailed Sections
[Link to references/ for heavy content]
```

#### Frontmatter Requirements

- **name**: Lowercase, digits, hyphens only. Under 64 characters.
- **description**: Primary triggering mechanism. Include:
  - What the skill does
  - Specific triggers/contexts for when to use it
  - All "when to use" information (body is only loaded after triggering)

### Bundled Resources

#### scripts/
- Executable code (Python, Bash, etc.)
- For tasks requiring deterministic reliability
- Token efficient, may execute without loading into context

#### references/
- Documentation loaded as needed
- For large content (>10k words), include grep patterns in SKILL.md
- Keep SKILL.md lean, move detailed content here
- **Avoid duplication**: Information lives in either SKILL.md or references/, not both

#### assets/
- Files used in output (templates, images, fonts)
- Separates output resources from documentation
- Enables using files without loading into context

---

## 3. Progressive Disclosure Design

Three-level loading system for context efficiency:

```
Level 1: Metadata (name + description)    → Always in context (~100 words)
Level 2: SKILL.md body                     → When skill triggers (<5k words)
Level 3: Bundled resources                 → As needed (unlimited)
```

### Patterns

**Pattern 1: High-level guide with references**
```markdown
## Quick start
[Basic example]

## Advanced features
- **Form filling**: See [FORMS.md](FORMS.md)
- **API reference**: See [REFERENCE.md](REFERENCE.md)
```

**Pattern 2: Domain-specific organization**
```
skill/
├── SKILL.md
└── references/
    ├── finance.md
    ├── sales.md
    └── product.md
```

**Pattern 3: Conditional details**
```markdown
For simple edits, modify XML directly.

**For tracked changes**: See [REDLINING.md](REDLINING.md)
```

### Guidelines

- Keep SKILL.md under 500 lines
- Split content when approaching the limit
- Reference files clearly from SKILL.md with when-to-use guidance
- Avoid deeply nested references (keep one level deep)
- Include table of contents for files >100 lines

---

## 4. Writing Guidelines

### Language Style

- Use imperative/infinitive form
- Be direct and actionable
- Focus on "why" over "what" for non-obvious behavior

### What to Include

| ✅ Include | ❌ Exclude |
|-----------|-----------|
| Multi-step workflows | README.md, INSTALLATION_GUIDE.md |
| Specific output formats | CHANGELOG.md, QUICK_REFERENCE.md |
| Quality standards | Auxiliary documentation |
| Procedural knowledge | Setup/testing procedures |
| Domain-specific details | User-facing documentation |

A skill should only contain essential files for an AI agent to do the job.

---

## 5. Skill Creation Process

```
Step 1: Understand with concrete examples
    ↓
Step 2: Plan reusable contents (scripts, references, assets)
    ↓
Step 3: Initialize the skill (create directory + SKILL.md)
    ↓
Step 4: Edit the skill (implement resources, write SKILL.md)
    ↓
Step 5: Package the skill (create .skill archive)
    ↓
Step 6: Iterate based on real usage
```

### Naming Conventions

- Lowercase letters, digits, hyphens only
- Normalize to hyphen-case: "Plan Mode" → `plan-mode`
- Prefer short, verb-led phrases
- Namespace by tool when helpful: `gh-address-comments`, `linear-address-issue`
- Folder name matches skill name exactly

---

## 6. Project Setup Templates

When establishing a new project, include these two files for consistent context management:

### CLAUDE.md

**必需文件**：每个 Agent 项目必须创建 `CLAUDE.md`，作为 AI Agent（Claude Code、Kimi CLI 等）的工作指南。

**使用模板**：复制 `CLAUDE.md` 作为模板，根据项目需求调整。

#### CLAUDE.md 核心结构

```markdown
# CLAUDE.md

AI Agent 工作指南

---

## 1. 角色定义
Claude should act as: [角色]

## 2. 关键文件速查
| 文件 | 用途 | AI 权限 |

## 3. 会话启动检查清单
每次启动时必须执行...

## 4. 多实例并行开发（Git Worktree）
[如需要并行开发，保留此章节]

## 5. 经验教训沉淀
[记录模板和原则]

## 6. 目录结构规范

## 7. 快速命令参考

## 8. 禁止事项

## 9. 项目特定上下文
[填写项目信息]

## 10. 自定义规则
```

#### 创建新 Agent 时的检查清单

- [ ] 复制 `CLAUDE.md` 模板到项目根目录
- [ ] 填写 **角色定义**（第 1 节）
- [ ] 更新 **关键文件速查**（第 2 节）
- [ ] 填写 **项目特定上下文**（第 9 节）
- [ ] 添加 **自定义规则**（第 10 节）
- [ ] 如需要并行开发，保留第 4-8 节
- [ ] 创建 `PROGRESS.md` 文件

#### 完整 CLAUDE.md 模板

> 模板文件：`./CLAUDE.md`

### PROGRESS.md

A dashboard that answers: What am I working on? What's waiting? What have I shipped?

```markdown
# PROGRESS

**Last Updated:** [Date]

---

## How This Works

One file. All your projects. Updated when things change.

**Not a to-do list.** A dashboard that answers:
1. What am I working on?
2. What's waiting?
3. What have I shipped?

---

## IDEATION

> Ideas you're exploring. Not committed yet.

### [Idea Name]
**Why:** [What problem does this solve?]
**Next:** [What do you need to decide?]

---

## DESIGN

> Committed projects in planning phase.

### [Project Name]
**Status:** Planning
**Approach:** [How will you tackle this?]
**Next:** [Specific next action]

---

## DEVELOPMENT

> Actively building.

### [Project Name]
**Status:** [Current phase]
**Location:** [Where this lives — file path, repo, URL]
**What it does:** [1-2 sentences]
**Current state:** [What works? What doesn't?]
**Next:** [Specific next action]
**Blockers:** [Anything stopping progress?]

---

## LIVE

> Shipped and running.

### [Project Name]
**Status:** [Active / Maintenance / Stable]
**What's live:** [Brief description]
**Last touch:** [When you last worked on this]

---

## RECENTLY COMPLETED

> What you've actually shipped. Proof of progress.

**[Month Year]:**
- [Thing you shipped] ([Date])
- [Another thing] ([Date])

---

## ON ICE

> Paused. Not deleted — just not active.

### [Project Name]
**Why paused:** [Reason]
**Reactivate if:** [What would need to change?]

---

## Quick Reference

**High energy?** → [Most important/hardest thing]
**Low energy?** → [Easiest/maintenance tasks]
**Quick win?** → [Smallest thing you can finish]

---

**Update this when things change. Weekly minimum.**
```

---

## 7. Documentation Templates

### README Structure (Priority Order)

1. **Title + One-liner** - What is this?
2. **Quick Start** - Running in <5 min
3. **Features** - What can I do?
4. **Configuration** - How to customize
5. **API Reference** - Link to detailed docs
6. **Contributing** - How to help
7. **License** - Legal

### API Documentation Template

```markdown
## GET /users/:id

Get a user by ID.

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| id | string | Yes | User ID |

**Response:**
- 200: User object
- 404: User not found
```

### Code Comment Guidelines

| ✅ Comment | ❌ Don't Comment |
|-----------|-----------------|
| Why (business logic) | What (obvious) |
| Complex algorithms | Every line |
| Non-obvious behavior | Self-explanatory code |
| API contracts | Implementation details |

---

## 8. AI-Friendly Documentation

### llms.txt Template

```markdown
# Project Name
> One-line objective.

## Core Files
- [src/index.ts]: Main entry
- [src/api/]: API routes
- [docs/]: Documentation

## Key Concepts
- Concept 1: Brief explanation
- Concept 2: Brief explanation
```

### MCP-Ready Documentation

- Clear H1-H3 hierarchy
- JSON/YAML examples for data structures
- Mermaid diagrams for flows
- Self-contained sections

---

## 9. Key Principles Summary

| Principle | Why It Matters |
|-----------|----------------|
| **Scannable** | Headers, lists, tables for quick parsing |
| **Examples first** | Show, don't just tell |
| **Progressive detail** | Simple → Complex |
| **Up to date** | Outdated = misleading |
| **Context efficient** | Every token must justify its cost |
| **Actionable** | Lead to clear agent action |

---

## 10. Anti-Patterns to Avoid

1. **Verbose explanations** - Prefer concise examples
2. **Duplicated information** - Use references/ for detailed content
3. **Deep nesting** - Keep references one level deep
4. **Extraneous files** - No README, CHANGELOG, etc. in skills
5. **Missing triggers** - Description must include when to use
6. **Static when dynamic works** - Use prototypes for UI/AI features
7. **Starting with solution** - Lead with problem and context

---

> **Remember:** These are starting points. Adapt to your project's needs while keeping the core philosophy of context efficiency and progressive disclosure.
