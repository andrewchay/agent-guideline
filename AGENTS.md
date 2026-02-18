# Agent Design Guidelines

A comprehensive guide for designing effective AI agent skills and capabilities.

---

## 1. Core Philosophy

### Context Engineering First

基于 Anthropic 的研究，我们采用**上下文工程（Context Engineering）**作为核心方法论。这是提示词工程的自然演进，关注整个上下文状态的优化，而非单条提示词。

**关键认知**：
- 上下文窗口是有限的**注意力资源**
- 每个 token 都会消耗注意力预算
- 目标是：**最小的高信号 token 集合**

**实践原则**：
- "这段信息真的必要吗？"
- "这段内容对得起它的 token 成本吗？"
- 用简洁例子胜过冗长解释

### Agentic Systems 分类

根据 Anthropic 的定义，我们区分两种架构：

| 类型 | 定义 | 适用场景 |
|------|------|---------|
| **Workflows** | LLM 和工具通过预定义代码路径编排 | 任务明确、步骤固定 |
| **Agents** | LLM 动态指导自己的流程和工具使用 | 需要灵活性和模型驱动决策 |

**建议**：从最简单的方案开始，只在需要时才增加复杂度。

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

### Workflow Patterns

基于 Anthropic 的研究，我们定义以下工作流模式：

#### Pattern 1: Prompt Chaining
顺序执行，每步处理上一步输出，可添加 gate 检查。

**适用**：任务可分解为固定子任务，如：生成大纲 → 检查 → 写文档

#### Pattern 2: Routing
分类输入，分发到专门处理流程。

**适用**：有明显分类的复杂任务，如：客服查询路由

#### Pattern 3: Parallelization
并行处理，包括 Sectioning（分解子任务）和 Voting（多视角）。

**适用**：需要多视角或并行处理，如：代码安全审查

#### Pattern 4: Orchestrator-Workers
中心协调器动态分解任务，委派给工作者。

**适用**：复杂、不可预测的任务，如：研究任务

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

## Workflow Pattern
[Prompt Chaining / Routing / Parallelization / Orchestrator-Workers]

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

基于 Anthropic 的上下文工程原则，三级加载系统：

```
Level 1: Metadata (name + description)    → 始终在上下文 (~100 words)
Level 2: SKILL.md body                     → Skill 触发时 (<5k words)
Level 3: Bundled resources                 → 按需加载 (无限制)
```

**核心原则**：上下文是有限的注意力资源，必须精心策划。

### Context Rot 认知

研究表明，随着上下文长度增加，模型的 recall 能力会下降（context rot）。这意味着：
- 长上下文 ≠ 更好性能
- 需要主动策划进入上下文的信息
- 每轮迭代都要重新筛选信息

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

When establishing a new project, include these files for consistent context management:

### BEST_PRACTICES.md

**必需文件**：包含基于 OpenAI/Anthropic 研究的 AI Agent 最佳实践。

内容结构：
- Agent 架构设计（Workflows vs Agents）
- 上下文工程原则
- 评估驱动开发
- 多 Agent 系统设计
- 工具设计最佳实践

### CLAUDE.md

**必需文件**：每个 Agent 项目必须创建 `CLAUDE.md`，作为 AI Agent 的工作指南。

**使用模板**：复制本项目的 `CLAUDE.md` 作为模板，根据项目需求调整。

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

## 4. 核心设计原则
### 4.1 上下文工程
### 4.2 Agent 架构选择
### 4.3 工具设计

## 5. 评估驱动开发

## 6. 多实例并行开发（Git Worktree）

## 7. 经验教训沉淀

## 8. 目录结构规范

## 9. 快速命令参考

## 10. 禁止事项

## 11. 项目特定上下文

## 12. 自定义规则
```

#### 创建新 Agent 时的检查清单

- [ ] 复制 `CLAUDE.md` 模板到项目根目录
- [ ] 复制 `BEST_PRACTICES.md` 到项目根目录
- [ ] 填写 **角色定义**（第 1 节）
- [ ] 更新 **关键文件速查**（第 2 节）
- [ ] 填写 **项目特定上下文**（第 11 节）
- [ ] 添加 **自定义规则**（第 12 节）
- [ ] 创建 `PROGRESS.md` 文件

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

### Context Engineering 反模式

1. **Verbose explanations** - Prefer concise examples
2. **Duplicated information** - Use references/ for detailed content
3. **Deep nesting** - Keep references one level deep
4. **Extraneous files** - No README, CHANGELOG, etc. in skills
5. **Missing triggers** - Description must include when to use
6. **Static when dynamic works** - Use prototypes for UI/AI features
7. **Starting with solution** - Lead with problem and context

### Agent 架构反模式

8. **过早使用复杂框架** - 先用 LLM API 直接实现
9. **不必要的 Agent 化** - 简单任务用 Workflow 或单 LLM 调用
10. **工具膨胀** - 只实现必要的工具
11. **忽视评估** - 尽早建立评估体系
12. **长上下文迷信** - 关注上下文质量而非长度

### 工具设计反模式

13. **功能重叠的工具** - 每个工具有独特用途
14. **模糊的工具描述** - 清晰说明用途和参数
15. **忽略错误处理** - 工具要鲁棒
16. **返回过多信息** - 优化 token 效率

---

## 11. Eval-Driven Development

基于 Anthropic 的研究，评估是 Agent 开发的核心环节。

### 11.1 为什么需要评估

- **避免盲目飞行**：没有评估，无法区分真实回归和噪音
- **加速迭代**：自动测试数百个场景
- **新模型适配**：有评估可以快速确定新模型优劣
- **产品-研究协作**：成为最高带宽的沟通渠道

### 11.2 评估组件

| 组件 | 定义 |
|------|------|
| **Task** | 单个测试，定义输入和成功标准 |
| **Trial** | 任务的单次尝试 |
| **Grader** | 评分逻辑，可包含多个断言 |
| **Transcript** | 完整记录（输出、工具调用、推理） |
| **Outcome** | 试验结束时的环境最终状态 |
| **Harness** | 端到端运行评估的基础设施 |

### 11.3 评估类型

**Single-turn Evals**
- prompt → response → grading
- 适用于简单分类或生成任务

**Multi-turn Evals**
- Agent 在多轮中使用工具
- 错误可能传播和累积
- 需要更复杂的验证逻辑

### 11.4 最佳实践

1. **尽早建立评估**：明确成功定义
2. **基于真实用例**：避免简单"沙盒"环境
3. **可验证响应**：每个 prompt 都有验证方式
4. **避免过度严格**：允许格式、措辞的合理变化
5. **多维度指标**：准确率、成本、延迟、token 消耗

### 11.5 迭代流程

```
1. 建立基线评估
    ↓
2. 实现/修改 Agent
    ↓
3. 运行评估
    ↓
4. 分析失败案例
    ↓
5. 优化 Prompt/工具
    ↓
6. 重复步骤 3-5
```

---

## 12. Multi-Agent Systems

### 12.1 适用场景

**适合多 Agent**：
- 广度优先查询（同时追踪多个独立方向）
- 信息超出单上下文窗口
- 需要与众多复杂工具交互
- 高价值任务，token 成本可接受

**不适合多 Agent**：
- 需要所有 Agent 共享相同上下文
- Agent 之间有大量依赖
- 实时协调要求高

### 12.2 架构模式

**Orchestrator-Workers（协调器-工作者）**
```
User Query
    ↓
Lead Agent (分析、规划)
    ↓
Subagent 1 ←→ Subagent 2 ←→ Subagent 3
(并行搜索不同方面)
    ↓
Lead Agent (综合结果)
    ↓
Final Answer
```

### 12.3 性能数据

- 多 Agent 系统比单 Agent 性能提升 90.2%（内部研究评估）
- Token 使用量：多 Agent ≈ 15× 普通聊天
- Agent ≈ 4× 普通聊天

### 12.4 关键洞察

**Token 使用解释性能差异**：
- Token 使用量本身解释 80% 的性能差异
- 工具调用次数和模型选择是另外两个因素
- 多 Agent 架构通过分布式上下文有效扩展 token 使用

---

## 13. Tool Design Best Practices

### 13.1 核心原则

工具是**确定性系统与非确定性 Agent 之间的新契约**。

### 13.2 设计要点

1. **自包含**：功能独立、明确
2. **鲁棒性**：优雅处理错误
3. **清晰参数**：描述性、无歧义
4. **Token 效率**：返回精简信息
5. **避免重叠**：每个工具有独特用途

### 13.3 Think Tool

**适用场景**：
- 复杂工具调用链
- 需要仔细分析工具输出
- 政策/规则繁重的环境
- 顺序决策

**实现**：
```json
{
  "name": "think",
  "description": "Use the tool to think about something. It will not obtain new information or change the database, but just append the thought to the log. Use it when complex reasoning or some cache memory is needed.",
  "input_schema": {
    "type": "object",
    "properties": {
      "thought": {
        "type": "string",
        "description": "A thought to think about."
      }
    },
    "required": ["thought"]
  }
}
```

**性能提升**：Airline domain +54%

### 13.4 工具优化流程

```
1. 快速原型 → 2. 运行评估 → 3. 分析结果 → 4. 优化工具 → 5. 重复
```

---

## 14. Key Principles Summary

| Principle | Why It Matters |
|-----------|----------------|
| **Context Engineering** | 上下文是有限的注意力资源，需要精心策划 |
| **Start Simple** | 从 LLM API 直接开始，需要时才增加复杂度 |
| **Eval-Driven** | 评估是高质量 Agent 的基础 |
| **Tool Minimalism** | 只实现必要的工具，避免膨胀 |
| **Progressive Disclosure** | 按层级组织信息，避免过载 |
| **Workflow Pattern** | 选择合适的架构模式（Workflow vs Agent） |
| **Multi-Agent When Needed** | 并行化带来性能提升，但有成本 |

---

> **Remember:** These are starting points based on OpenAI and Anthropic research. Adapt to your project's needs while keeping the core philosophy of context efficiency and progressive disclosure.
