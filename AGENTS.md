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

---

## 2. 项目设置

### 2.1 快速开始

使用初始化脚本创建新项目：

```bash
./scripts/init-agent-project.sh my-agent-project
cd my-agent-project
```

### 2.2 核心文件

每个 Agent 项目必须包含以下文件：

| 文件 | 用途 | 说明 |
|------|------|------|
| `CLAUDE.md` | AI Agent 工作指南 | **必须**，复制模板后填写项目特定上下文 |
| `PROGRESS.md` | 项目进度仪表板 | 跟踪项目状态和进展 |
| `TODO.md` | 当前任务清单 | 实时更新任务进度 |
| `MEMORY.md` | 关键决策和上下文 | 跨会话记忆重要信息 |

### 2.3 目录结构

```
project/
├── CLAUDE.md              # AI Agent 工作指南（必须）
├── PROGRESS.md            # 项目进度仪表板
├── TODO.md                # 当前任务清单
├── MEMORY.md              # 关键决策和上下文
├── src/                   # 源代码
├── tools/                 # Agent 工具
├── evals/                 # 评估用例
│   ├── tasks/             # 评估任务
│   ├── graders/           # 评分逻辑
│   └── results/           # 评估结果
├── docs/                  # 文档
└── scripts/               # 脚本
```

---

## 3. Skill Structure

### 3.1 Anatomy of a Skill

```
skill-name/
├── SKILL.md              # Required: Instructions and metadata
├── scripts/              # Optional: Executable code
├── references/           # Optional: Documentation loaded on demand
└── assets/               # Optional: Templates, icons, fonts
```

### 3.2 SKILL.md Structure

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
  - All "when to use" information

---

## 4. Progressive Disclosure Design

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

---

## 5. Writing Guidelines

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

## 6. Workflow Patterns

基于 Anthropic 的研究，我们定义以下工作流模式：

### Pattern 1: Prompt Chaining
顺序执行，每步处理上一步输出，可添加 gate 检查。

**适用**：任务可分解为固定子任务，如：生成大纲 → 检查 → 写文档

### Pattern 2: Routing
分类输入，分发到专门处理流程。

**适用**：有明显分类的复杂任务，如：客服查询路由

### Pattern 3: Parallelization
并行处理，包括 Sectioning（分解子任务）和 Voting（多视角）。

**适用**：需要多视角或并行处理，如：代码安全审查

### Pattern 4: Orchestrator-Workers
中心协调器动态分解任务，委派给工作者。

**适用**：复杂、不可预测的任务，如：研究任务

---

## 7. Eval-Driven Development

基于 Anthropic 的研究，评估是 Agent 开发的核心环节。

### 7.1 为什么需要评估

- **避免盲目飞行**：没有评估，无法区分真实回归和噪音
- **加速迭代**：自动测试数百个场景
- **新模型适配**：有评估可以快速确定新模型优劣
- **产品-研究协作**：成为最高带宽的沟通渠道

### 7.2 评估组件

| 组件 | 定义 |
|------|------|
| **Task** | 单个测试，定义输入和成功标准 |
| **Trial** | 任务的单次尝试 |
| **Grader** | 评分逻辑，可包含多个断言 |
| **Transcript** | 完整记录（输出、工具调用、推理）|
| **Outcome** | 试验结束时的环境最终状态 |

### 7.3 迭代流程

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

## 8. Tool Design Best Practices

### 8.1 核心原则

工具是**确定性系统与非确定性 Agent 之间的新契约**。

### 8.2 设计要点

1. **自包含**：功能独立、明确
2. **鲁棒性**：优雅处理错误
3. **清晰参数**：描述性、无歧义
4. **Token 效率**：返回精简信息
5. **避免重叠**：每个工具有独特用途

### 8.3 Think Tool

**适用场景**：复杂工具调用链、政策繁重环境、顺序决策

```json
{
  "name": "think",
  "description": "Use the tool to think about something. It will not obtain new information or change the database, but just append the thought to the log. Use it when complex reasoning or some cache memory is needed.",
  "input_schema": {
    "type": "object",
    "properties": {
      "thought": { "type": "string", "description": "A thought to think about." }
    },
    "required": ["thought"]
  }
}
```

---

## 9. Key Principles Summary

| Principle | Why It Matters |
|-----------|----------------|
| **Context Engineering** | 上下文是有限的注意力资源，需要精心策划 |
| **Start Simple** | 从 LLM API 直接开始，需要时才增加复杂度 |
| **Eval-Driven** | 评估是高质量 Agent 的基础 |
| **Tool Minimalism** | 只实现必要的工具，避免膨胀 |
| **Progressive Disclosure** | 按层级组织信息，避免过载 |
| **Workflow Pattern** | 选择合适的架构模式 |

---

## 10. Anti-Patterns to Avoid

### Context Engineering 反模式

1. **Verbose explanations** - Prefer concise examples
2. **Duplicated information** - Use references/ for detailed content
3. **Deep nesting** - Keep references one level deep
4. **Extraneous files** - No README, CHANGELOG, etc. in skills
5. **Missing triggers** - Description must include when to use

### Agent 架构反模式

6. **过早使用复杂框架** - 先用 LLM API 直接实现
7. **不必要的 Agent 化** - 简单任务用 Workflow 或单 LLM 调用
8. **工具膨胀** - 只实现必要的工具
9. **忽视评估** - 尽早建立评估体系
10. **长上下文迷信** - 关注上下文质量而非长度

---

> **Remember:** These are starting points based on OpenAI and Anthropic research. Adapt to your project's needs while keeping the core philosophy of context efficiency and progressive disclosure.
