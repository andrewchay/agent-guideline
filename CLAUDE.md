# CLAUDE.md

AI Agent 项目工作指南 - 统一模板

> 本文件是 AI Agent（Claude Code、Kimi CLI 等）的工作指南。新建 Agent 项目时，复制此文件到项目根目录，根据项目需求填写第 9 节"项目特定上下文"。

---

## 1. 角色定义

**Claude should act as**: Senior AI Agent Engineer

**核心职责**：
- 设计和实现高质量的 AI Agent 系统
- 遵循上下文工程和渐进式披露原则
- 构建可评估、可迭代的 Agent 工作流
- 编写清晰、可维护的代码和文档

---

## 2. 关键文件速查

| 文件 | 用途 | AI 权限 | 备注 |
|------|------|---------|------|
| `CLAUDE.md` | 本工作指南 | 只读 | 会话启动必读 |
| `PROGRESS.md` | 项目进度仪表板 | 读取 + 追加 | 禁止 symlink |
| `TODO.md` | 当前任务清单 | 读取 + 修改 | 实时更新进度 |
| `MEMORY.md` | 关键决策和上下文 | 读取 + 追加 | 跨会话记忆 |
| `evals/` | 评估用例和结果 | 读取 + 修改 | 评估驱动开发 |

---

## 3. 会话启动检查清单

每次启动时必须执行：

```bash
# 1. 读取项目状态
head -100 PROGRESS.md

# 2. 读取当前任务
cat TODO.md

# 3. 读取关键记忆
head -50 MEMORY.md

# 4. 确认工作目录
pwd && git status
```

---

## 4. Agent 架构设计

### 4.1 架构选择决策树

```
任务是否明确、步骤固定？
├── 是 → Workflow
│   ├── 可分解为固定子任务 → Prompt Chaining
│   ├── 有明显分类 → Routing
│   └── 需要多视角/并行 → Parallelization
└── 否 → 需要灵活性？
    ├── 是 → Agent（Orchestrator-Workers / Autonomous）
    └── 否 → 单 LLM 调用 + RAG
```

**核心原则**：从最简单的方案开始，只在需要时才增加复杂度。

### 4.2 四种工作流模式

| 模式 | 适用场景 | 关键特征 |
|------|---------|---------|
| **Prompt Chaining** | 可分解为固定子任务 | 顺序执行，可添加 gate 检查 |
| **Routing** | 有明显分类的复杂任务 | 分类后分发到专门处理 |
| **Parallelization** | 需要多视角或并行 | Sectioning（分解）或 Voting（投票）|
| **Orchestrator-Workers** | 复杂、不可预测的任务 | 动态分解和委派 |

### 4.3 多 Agent 系统

**适用场景**：
- 广度优先查询（同时追踪多个独立方向）
- 信息超出单上下文窗口
- 需要与众多复杂工具交互
- 高价值任务，token 成本可接受

**架构**：
```
User Query
    ↓
Lead Agent (分析、规划)
    ↓
Subagent 1 ←→ Subagent 2 ←→ Subagent 3 (并行)
    ↓
Lead Agent (综合结果)
    ↓
Final Answer
```

**性能数据**：多 Agent 比单 Agent 性能提升 ~90%，但 token 消耗约 15×。

---

## 5. 上下文工程（Context Engineering）

### 5.1 核心认知

- **上下文是有限的注意力资源**
- 每个 token 都会消耗注意力预算
- 目标是：**最小的高信号 token 集合**
- 长上下文 ≠ 更好性能（context rot 现象）

### 5.2 System Prompt 设计

**Goldilocks Zone（恰到好处的抽象层级）**：
- ❌ 过于具体：硬编码复杂逻辑，脆弱且难维护
- ❌ 过于模糊：缺乏具体指导，假设共享上下文
- ✅ 恰到好处：足够具体以指导行为，足够灵活以提供启发

**推荐结构**：
```markdown
<background_information>
[必要的背景信息]
</background_information>

## Tool guidance
[工具使用指导]

## Output description
[输出格式说明]

## Examples
[具体示例]
```

### 5.3 渐进式披露设计

```
Level 1: Metadata (name + description)    → 始终在上下文 (~100 words)
Level 2: SKILL.md body                     → Skill 触发时 (<5k words)
Level 3: Bundled resources                 → 按需加载 (无限制)
```

---

## 6. 工具设计最佳实践

### 6.1 核心原则

**工具是确定性系统与非确定性 Agent 之间的契约**。

### 6.2 设计要点

| 原则 | 说明 |
|------|------|
| **自包含** | 每个工具功能独立、明确 |
| **鲁棒性** | 能优雅处理错误 |
| **清晰参数** | 描述性、无歧义 |
| **Token 效率** | 返回信息精简 |
| **避免重叠** | 每个工具有独特用途 |

### 6.3 命名规范

- 使用命名空间：`github-create-issue`, `slack-send-message`
- 小写字母、数字、连字符
- 动词开头，清晰描述动作

### 6.4 Think Tool

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

## 7. 评估驱动开发（Eval-Driven Development）

基于 Anthropic 的研究，评估是 Agent 开发的核心环节。

### 7.1 为什么需要评估

- **避免盲目飞行**：没有评估，无法区分真实回归和噪音，团队陷入"猜测和检查"的被动循环
- **加速迭代**：自动测试数百个场景，快速验证改动
- **新模型适配**：有评估可以快速确定新模型优劣，在几天内完成升级（而非数周）
- **产品-研究协作**：成为最高带宽的沟通渠道，定义可优化的指标

### 7.2 评估类型

| 类型 | 定义 | 适用场景 |
|------|------|---------|
| **Single-turn Evals** | Prompt → Response → Grading | 简单任务、基础能力测试 |
| **Multi-turn Evals** | Agent 在多轮中使用工具 | 工具调用、状态修改 |
| **Agent Evals** | 复杂多轮 + 环境状态变化 | 完整 Agent 能力评估 |

### 7.3 评估组件定义

| 组件 | 定义 | 说明 |
|------|------|------|
| **Task** | 单个测试，定义输入和成功标准 | 也称为 problem 或 test case |
| **Trial** | 任务的单次尝试 | 因模型输出有变化，需多次运行 |
| **Grader** | 评分逻辑，可包含多个断言 | 也称为 checks |
| **Transcript** | 完整记录（输出、工具调用、推理）| 也称为 trace 或 trajectory |
| **Outcome** | 试验结束时的环境最终状态 | 如数据库中的预订记录 |
| **Evaluation Harness** | 端到端运行评估的基础设施 | 并发运行、记录步骤、聚合结果 |
| **Agent Harness** | 使模型成为 Agent 的系统 | 处理输入、编排工具调用 |
| **Evaluation Suite** | 针对特定能力的任务集合 | 如客服套件：退款、取消、升级 |

### 7.4 Grader 类型

| 类型 | 说明 | 示例 |
|------|------|------|
| **Exact Match** | 精确匹配输出 | 验证特定字符串存在 |
| **Semantic Match** | 语义匹配 | LLM 判断输出是否符合预期 |
| **Static Analysis** | 静态分析 | 代码编译、单元测试 |
| **Outcome-based** | 基于环境状态 | 检查数据库、文件系统状态 |
| **LLM-as-Judge** | LLM 评分 | 使用评分标准进行判断 |

### 7.5 评估迭代流程

```
1. 建立基线评估
    ↓
2. 实现/修改 Agent
    ↓
3. 运行评估（多次 Trial）
    ↓
4. 分析失败案例（Transcript 分析）
    ↓
5. 优化 Prompt/工具/Grader
    ↓
6. 重复步骤 3-5
```

### 7.6 评估最佳实践

1. **尽早建立评估**：明确成功定义，编码预期行为
2. **基于真实用例**：避免过于简单的"沙盒"环境
3. **可验证的响应**：每个 prompt 都有明确的验证方式
4. **避免过度严格**：允许格式、措辞的合理变化
5. **收集多维度指标**：准确率、延迟、token 消耗、成本、工具调用次数
6. **运行多次 Trial**：模型输出有变化，单次运行不可靠
7. **关注 Outcome**：不仅看输出文本，更要看环境最终状态
8. **定期人工校准**：LLM graders 需要周期性人工验证

### 7.7 常见评估维度

**功能性维度**：
- 不破坏现有功能
- 正确执行用户请求
- 执行质量

**性能维度**：
- 准确率（Accuracy）
- 延迟（Latency）
- Token 使用量
- 成本 per task
- 错误率（Error Rate）

### 7.8 评估目录结构

```
evals/
├── tasks/                 # 评估任务定义
│   ├── task_name.json     # 单个任务配置
│   └── ...
├── graders/               # 评分逻辑
│   ├── __init__.py
│   ├── base.py           # 基础 Grader 类
│   ├── exact_match.py    # 精确匹配
│   ├── llm_judge.py      # LLM 评分
│   └── outcome_check.py  # 环境状态检查
├── harness.py            # 评估运行器
├── config.yaml           # 评估配置
└── results/              # 评估结果（gitignored）
    ├── YYYY-MM-DD/
    └── latest.json
```

---

## 8. 项目文件体系

### 8.1 核心文件

**PROGRESS.md** - 项目进度仪表板
```markdown
# PROGRESS

**Last Updated:** [Date]

## How This Works
One file. All your projects. Updated when things change.

## DEVELOPMENT
### [Project Name]
**Status:** [Current phase]
**What it does:** [1-2 sentences]
**Current state:** [What works? What doesn't?]
**Next:** [Specific next action]
**Blockers:** [Anything stopping progress?]

## RECENTLY COMPLETED
- [Thing you shipped] ([Date])
```

**TODO.md** - 当前任务清单
```markdown
# TODO

## Active Tasks
- [ ] Task 1 (Priority: High)
- [ ] Task 2 (Priority: Medium)

## Completed Today
- [x] Completed task
```

**MEMORY.md** - 关键决策和上下文
```markdown
# MEMORY

## Key Decisions
### [Date]: [Decision Title]
**Context:** [Why this decision was needed]
**Decision:** [What was decided]
**Consequences:** [Impact on the project]

## Important Context
- [Key fact 1]
- [Key fact 2]
```

### 8.2 目录结构

```
project/
├── .git/
├── CLAUDE.md              # 本工作指南
├── PROGRESS.md            # 项目进度仪表板
├── TODO.md                # 当前任务清单
├── MEMORY.md              # 关键决策和上下文
├── src/                   # 源代码
├── evals/                 # 评估用例
│   ├── tasks/             # 评估任务
│   ├── graders/           # 评分逻辑
│   └── results/           # 评估结果
├── tools/                 # Agent 工具
├── docs/                  # 文档
└── scripts/               # 脚本
```

---

## 9. 项目特定上下文

**Primary**: [Main project/goal - 主要项目目标]

**Secondary**: [Next priority - 次要优先级]

**Current Focus**: [What we're working on right now - 当前工作重点]

**Tech Stack**: [Languages, frameworks, key libraries - 技术栈]

**Key Constraints**: [Performance, security, compatibility - 关键约束]

---

## 10. 自定义规则

1. **简洁优先**：每个 token 都要有价值，避免冗长解释
2. **示例胜过说明**：用具体示例展示期望的输出
3. **工具最小化**：只实现必要的工具，避免膨胀
4. **评估先行**：新功能必须有对应的评估用例
5. **频繁更新 TODO**：完成任务后立即标记
6. **记录关键决策**：重要决策记入 MEMORY.md

---

## 11. 快速命令参考

```bash
# 查看项目状态
cat PROGRESS.md && cat TODO.md

# 更新任务状态
# 编辑 TODO.md，将 [ ] 改为 [x]

# 记录新决策
cat >> MEMORY.md << 'EOF'

## $(date +%Y-%m-%d): [Decision Title]
**Context:** [Why]
**Decision:** [What]
**Consequences:** [Impact]
EOF

# 运行评估
# cd evals && python run_evals.py
```

---

## 12. 禁止事项

| 禁止项 | 原因 | 正确做法 |
|--------|------|----------|
| 冗长 System Prompt | 消耗注意力预算 | 遵循上下文工程原则 |
| 工具功能重叠 | 增加认知负担 | 每个工具功能独立、明确 |
| 忽视错误处理 | 导致脆弱系统 | 工具要鲁棒，优雅处理错误 |
| 返回过多信息 | 浪费 token | 优化工具响应的 token 效率 |
| 跳过评估 | 无法衡量改进 | 尽早建立评估体系 |
| 长上下文迷信 | 质量 > 数量 | 关注上下文质量而非长度 |

---

> **使用方法**：复制此文件到你的 Agent 项目根目录，填写第 9 节"项目特定上下文"，根据项目需求调整第 10 节"自定义规则"。
