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

基于 Anthropic 的研究，评估是 Agent 开发的核心环节。完整的评估体系是高质量 Agent 的基础。

### 7.1 为什么需要评估

**避免盲目飞行**：没有评估，团队陷入"猜测和检查"的被动循环——等待用户投诉、手动复现、修复 bug、希望没有引入新问题。无法区分真实回归和噪音。

**加速迭代**：自动测试数百个场景，在发布前验证改动。

**新模型适配**：有评估可以快速确定新模型优劣，在几天内完成升级（而非数周）。

**产品-研究协作**：评估成为最高带宽的沟通渠道，定义研究人员可以优化的指标。

**复合价值**：一旦建立评估，自动获得基线和回归测试（延迟、token 使用量、成本、错误率）。

### 7.2 评估类型

| 类型 | 定义 | 复杂度 | 适用场景 |
|------|------|--------|---------|
| **Single-turn** | Prompt → Response → Grading | 低 | 基础能力、简单任务 |
| **Multi-turn** | Agent 使用工具多轮交互 | 中 | 工具调用、状态管理 |
| **Agent Evals** | 复杂多轮 + 环境状态变化 | 高 | 完整 Agent 能力评估 |

**关键区别**：Agent 评估中，错误可能在多轮中传播和累积，且前沿模型可能找到超越静态评估的创造性解决方案。

### 7.3 评估组件详解

| 组件 | 定义 | 别名 | 说明 |
|------|------|------|------|
| **Task** | 单个测试，定义输入和成功标准 | Problem, Test Case | 评估的基本单元 |
| **Trial** | 任务的单次尝试 | Run | 因模型输出有变化，需多次运行取平均 |
| **Grader** | 评分逻辑 | Checker | 可包含多个 assertions |
| **Transcript** | 完整交互记录 | Trace, Trajectory | 包含输出、工具调用、推理过程 |
| **Outcome** | 环境最终状态 | Final State | 如数据库中的预订记录 |
| **Evaluation Harness** | 评估基础设施 | Test Runner | 并发运行、记录步骤、聚合结果 |
| **Agent Harness** | Agent 运行系统 | Scaffold | 处理输入、编排工具调用 |
| **Evaluation Suite** | 任务集合 | Test Suite | 针对特定能力的任务组 |

### 7.4 Grader 类型与实现

| 类型 | 说明 | 适用场景 | 示例 |
|------|------|---------|------|
| **Exact Match** | 精确匹配输出 | 结构化输出 | `response == expected` |
| **Contains** | 包含特定内容 | 文本验证 | `"success" in response` |
| **Semantic Match** | 语义匹配 | 开放式回答 | 嵌入向量相似度 |
| **Static Analysis** | 静态分析 | 代码评估 | 编译检查、单元测试 |
| **Outcome-based** | 基于环境状态 | 状态变更验证 | 检查数据库、文件系统 |
| **LLM-as-Judge** | LLM 评分 | 主观质量评估 | 使用评分标准判断 |
| **Browser Agent** | 浏览器自动化 | UI 验证 | 端到端功能测试 |

**Grader 设计原则**：
- 避免过度严格：允许格式、措辞的合理变化
- 关注 Outcome 而非 Transcript：代理说"已预订"不等于真的预订了
- 多个 Graders：一个 Task 可有多个 Graders，每个包含多个 assertions

### 7.5 评估迭代流程

```
Step 1: 建立基线评估
    - 定义成功标准
    - 创建初始 Task 集合
    - 实现基础 Graders
    
Step 2: 实现/修改 Agent
    - 开发新功能或修复问题
    
Step 3: 运行评估（多次 Trial）
    - 建议每个 Task 运行 3-5 次
    - 记录 Transcript 和 Outcome
    
Step 4: 分析失败案例
    - 查看失败 Trial 的 Transcript
    - 区分真正失败 vs 评估过于严格
    - 识别工具描述问题
    
Step 5: 优化 Prompt/工具/Grader
    - 修复 Agent 问题
    - 或调整 Grader 使其更合理
    
Step 6: 重复步骤 3-5
```

### 7.6 评估最佳实践

**设计阶段**：
1. **尽早建立评估**：编码预期行为，消除歧义
2. **基于真实用例**：从生产环境提取场景，避免"玩具"问题
3. **可验证的响应**：每个 Task 都有明确的验证方式

**运行阶段**：
4. **多次 Trial**：模型输出有随机性，单次运行不可靠
5. **关注 Outcome**：不仅看输出文本，更要看环境最终状态
6. **收集多维度指标**：准确率、延迟、token 消耗、成本、工具调用次数

**维护阶段**：
7. **定期人工校准**：LLM graders 需要周期性人工验证
8. **分离评估套件**：质量基准测试 vs 回归测试
9. **版本控制评估**：Task 和 Grader 也应版本控制

### 7.7 评估维度示例

**Descript 视频编辑 Agent**：
- 不破坏现有功能（Don't break things）
- 正确执行用户请求（Do what I asked）
- 执行质量（Do it well）

**Bolt AI 评估系统**：
- 静态分析评分输出
- 浏览器 Agent 测试应用
- LLM 评判指令遵循

**通用维度**：
- 功能正确性（Functional Correctness）
- 指令遵循（Instruction Following）
- 简洁性（Concision）
- 过度工程（Over-engineering）
- 错误处理（Error Handling）

### 7.8 评估目录结构

```
evals/
├── README.md              # 评估说明和运行指南
├── config.yaml           # 评估配置（模型、并发数、重试次数）
├── harness.py            # 评估运行器主程序
├── tasks/                # 评估任务定义
│   ├── __init__.py
│   ├── base.py          # 基础 Task 类
│   ├── coding/          # 编码任务
│   │   ├── __init__.py
│   │   ├── create_mcp_server.json
│   │   └── refactor_code.json
│   ├── research/        # 研究任务
│   └── customer_support/ # 客服任务
├── graders/             # 评分逻辑
│   ├── __init__.py
│   ├── base.py         # 基础 Grader 类
│   ├── exact_match.py
│   ├── llm_judge.py
│   ├── outcome_check.py
│   └── static_analysis.py
├── fixtures/           # 测试数据和环境
│   ├── codebases/     # 代码库模板
│   ├── databases/     # 数据库初始状态
│   └── documents/     # 测试文档
└── results/           # 评估结果（gitignored）
    ├── 2025-02-21/
    │   ├── run_001.json
    │   └── summary.html
    └── latest.json
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
