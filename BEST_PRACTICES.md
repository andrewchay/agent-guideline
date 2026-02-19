# AI Agent 最佳实践总结

基于 OpenAI Developer Platform 和 Anthropic Engineering Blog 的最新研究，整理出构建生产级 AI Agent 的完整最佳实践。

---

## 一、Agent 基础概念

### 1.1 Workflows vs Agents

**Workflows（工作流）**
- LLM 和工具通过预定义的代码路径编排
- 适用于：任务明确、步骤固定的场景
- 优势：可预测性高、一致性好、延迟和成本可控

**Agents（智能体）**
- LLM 动态指导自己的流程和工具使用
- 适用于：需要灵活性和模型驱动决策的场景
- 优势：灵活、自适应、能处理开放式任务

**核心建议**：从最简单的方案开始，只在需要时才增加复杂度。许多应用通过优化单轮 LLM 调用（配合检索和上下文示例）就已足够。

### 1.2 何时使用 Agents

**适合使用 Agents 的场景：**
- 任务复杂且步骤无法预先确定
- 需要多步骤推理和工具调用
- 需要模型自主决策和调整策略

**不建议使用 Agents 的场景：**
- 任务简单明确，单轮调用即可解决
- 对延迟和成本敏感
- 需要高度一致性和可预测性

### 1.3 框架选择建议

**推荐做法**：
- 从直接使用 LLM API 开始，许多模式只需几行代码
- 如需框架，确保理解底层代码，避免错误假设

**常见框架**：
- Claude Agent SDK
- OpenAI Agents SDK
- Strands Agents SDK (AWS)
- Rivet / Vellum (GUI 工具)

**警告**：框架会增加抽象层，可能隐藏底层 prompts 和 responses，使调试更困难。

---

## 二、核心构建模块

### 2.1 增强型 LLM（Augmented LLM）

基础构建模块包含三个核心能力：

| 能力 | 说明 | 实现方式 |
|------|------|----------|
| **检索 (Retrieval)** | 动态获取外部信息 | RAG、向量搜索、文件搜索 |
| **工具 (Tools)** | 执行操作和与外部系统交互 | Function calling、MCP |
| **记忆 (Memory)** | 跨会话保持上下文 | 向量存储、对话状态管理 |

### 2.2 工作流模式

#### Prompt Chaining（提示链）
```
输入 → LLM调用1 → 检查点 → LLM调用2 → 输出
```
- **适用**：任务可分解为固定子任务
- **示例**：生成营销文案 → 翻译 → 合规检查

#### Routing（路由）
```
输入 → 分类器 → 分支A / 分支B / 分支C
```
- **适用**：复杂任务有明确分类
- **示例**：客服查询路由到不同处理流程

#### Parallelization（并行化）
```
输入 → [LLM调用1] + [LLM调用2] + [LLM调用3] → 聚合结果
```
- **适用**：需要多视角或并行处理
- **变体**：
  - **Sectioning**：将任务分解为独立子任务并行执行
  - **Voting**：同一任务多次执行获取多样化输出
- **示例**：代码安全审查、内容审核

#### Orchestrator-Workers（协调器-工作者）
```
用户查询 → 协调器（分析、分解）→ 工作者1/2/3（并行）→ 协调器（综合）→ 输出
```
- **适用**：复杂任务无法预测步骤
- **示例**：研究任务、复杂数据分析

---

## 三、上下文工程（Context Engineering）

### 3.1 核心原则

**上下文是有限的注意力资源**
- 每个新 token 都会消耗注意力预算
- 上下文越长，模型 recall 能力越弱（context rot）
- 目标是：最小的高信号 token 集合

**Context Rot 现象**：
- Transformer 架构中，n 个 token 产生 n² 的成对关系
- 随着上下文增长，模型捕捉这些关系的能力被拉伸
- 模型对长序列的依赖关系理解较弱

### 3.2 System Prompt 设计

**正确的抽象层级（Goldilocks Zone）**：
- ❌ 过于具体：硬编码复杂逻辑，脆弱且难维护
- ❌ 过于模糊：缺乏具体指导，假设共享上下文
- ✅ 恰到好处：足够具体以指导行为，足够灵活以提供启发

**组织方式**：
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

### 3.3 渐进式披露设计

```
Level 1: Metadata (name + description)    → 始终在上下文 (~100 words)
Level 2: SKILL.md body                     → Skill触发时 (<5k words)
Level 3: Bundled resources                 → 按需加载 (无限制)
```

---

## 四、工具设计最佳实践

### 4.1 工具的本质

**工具是确定性系统与非确定性 Agent 之间的契约**

传统软件：确定性系统之间的契约（`getWeather("NYC")` 总是返回相同结果）
Agent 工具：确定性与非确定性之间的契约（Agent 可能调用工具、使用知识或询问澄清）

### 4.2 工具设计原则

| 原则 | 说明 |
|------|------|
| **自包含** | 每个工具功能独立、明确 |
| **鲁棒性** | 能优雅处理错误 |
| **清晰的输入参数** | 描述性、无歧义 |
| **Token 效率** | 返回信息精简 |
| **避免功能重叠** | 每个工具有独特用途 |

**命名空间建议**：
- `github-create-issue`
- `linear-address-issue`
- `slack-send-message`

### 4.3 Think Tool（思考工具）

**适用场景**：
- 复杂工具调用链
- 需要仔细分析工具输出
- 政策/规则繁重的环境
- 顺序决策，每步建立在前一步之上

**实现示例**：
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

**性能提升**（τ-Bench 基准测试）：
- Airline domain: +54% (0.370 → 0.570)
- Retail domain: +3.7% (0.783 → 0.812)

**注意**：Claude 4 的 Extended Thinking 功能已整合类似能力，在大多数情况下推荐使用该功能而非单独的 think tool。

### 4.4 MCP（Model Context Protocol）优化

**代码执行优化**：
- 将 MCP 工具作为代码 API 而非直接工具调用呈现
- Agent 编写代码与 MCP 服务器交互
- 按需加载工具定义，减少 token 消耗

**性能提升示例**：
- 传统方式：150,000 tokens
- 代码执行方式：2,000 tokens
- **节省：98.7%**

---

## 五、评估（Evals）

### 5.1 评估结构

| 组件 | 定义 |
|------|------|
| **Task** | 单个测试，定义输入和成功标准 |
| **Trial** | 任务的单次尝试 |
| **Grader** | 评分逻辑，可包含多个断言 |
| **Transcript** | 完整记录（输出、工具调用、推理）|
| **Outcome** | 试验结束时的环境最终状态 |
| **Harness** | 端到端运行评估的基础设施 |
| **Agent Harness** | 使模型成为 Agent 的系统 |

### 5.2 评估类型

**Single-turn Evals**
- 简单直接：prompt → response → grading

**Multi-turn Evals**
- Agent 在多轮中使用工具
- 错误可能传播和累积

### 5.3 评估最佳实践

1. **尽早建立评估**：明确成功的定义
2. **基于真实用例**：避免过于简单的"沙盒"环境
3. **可验证的响应**：每个 prompt 都有验证方式
4. **避免过度严格的验证器**：允许格式、措辞的合理变化
5. **收集多维度指标**：准确率、延迟、token消耗、工具调用次数

### 5.4 评估开发流程

```
1. 快速原型 → 2. 运行评估 → 3. 分析结果 → 4. 优化工具 → 5. 重复
```

**与 Agent 协作优化**：
- 使用 Claude Code 自动生成评估任务
- 分析失败案例，识别工具描述问题
- 迭代改进工具描述和参数

---

## 六、多 Agent 系统

### 6.1 适用场景

**适合多 Agent**：
- 广度优先查询（同时追踪多个独立方向）
- 信息超出单上下文窗口
- 需要与众多复杂工具交互
- 高价值任务，token 成本可接受

**不适合多 Agent**：
- 需要所有 Agent 共享相同上下文
- Agent 之间有大量依赖
- 实时协调要求高

### 6.2 架构模式

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
Citation Agent (添加引用)
    ↓
Final Answer
```

### 6.3 性能数据

- 多 Agent 系统比单 Agent 性能提升 **90.2%**（内部研究评估）
- Token 使用量：多 Agent ≈ **15×** 普通聊天
- 单 Agent ≈ **4×** 普通聊天

**关键发现**：
- Token 使用量本身解释了 80% 的性能差异
- 工具调用次数和模型选择是另外两个关键因素
- 升级到 Claude Sonnet 4 的性能提升大于在 Claude Sonnet 3.7 上加倍 token 预算

### 6.4 多 Agent 提示工程原则

1. **像你的 Agent 一样思考**：从 Agent 视角理解任务
2. **明确协调规则**：防止创建过多子 Agent
3. **限制递归深度**：避免无限搜索
4. **清晰的任务边界**：每个 Agent 有明确职责

---

## 七、长时运行 Agent

### 7.1 核心挑战

Agent 必须在离散的会话中工作，每个新会话开始时都没有之前的记忆。

**常见失败模式**：
1. Agent 试图一次性完成太多工作，导致上下文耗尽
2. 后续会话面对半成品功能，需要猜测之前发生了什么
3. 后期 Agent 看到已有进展后过早宣布完成

### 7.2 解决方案

**Initializer Agent（初始化 Agent）**：
- 第一次会话使用专门提示
- 设置初始环境：`init.sh` 脚本、`claude-progress.txt`、初始 git commit

**Coding Agent（编码 Agent）**：
- 每次会话专注于增量进展
- 留下清晰的工件供下一个会话使用

### 7.3 环境管理组件

**Feature List（功能列表）**：
```json
{
  "category": "functional",
  "description": "New chat button creates a fresh conversation",
  "steps": [...],
  "passes": false
}
```

**进度跟踪**：
- 使用 `claude-progress.txt` 记录已完成工作
- 配合 git 历史快速了解工作状态
- 每次会话结束时提交代码并写描述性提交信息

**测试要求**：
- 明确提示使用浏览器自动化工具进行端到端测试
- 像真实用户一样验证功能

---

## 八、OpenAI 平台特性

### 8.1 Responses API

**核心特性**：
- **Stateful-by-default**：对话和工具状态自动跟踪
- **Multimodal from ground up**：文本、图像、音频、函数调用都是一等公民
- **Better cache utilization**：比 Chat Completions 高 40-80%
- **Polymorphic Items**：支持多种输出类型混合

**与 Chat Completions 对比**：

| 特性 | Chat Completions | Responses |
|------|-----------------|-----------|
| 状态管理 | 无状态 | 有状态 |
| 推理保留 | 轮次间丢失 | 跨轮次保留 |
| 输出结构 | 单消息 | 多项目列表 |
| 托管工具 | 有限 | 完整支持 |
| 缓存效率 | 较低 | 高 40-80% |

### 8.2 AgentKit 和 Agents SDK

**AgentKit**：模块化工具包，用于构建、部署和优化 Agent
- Agent Builder：可视化画布创建工作流
- 内置工具：Web 搜索、文件搜索、Computer Use
- 向量存储：外部和持久化知识

**Agents SDK**：开源 SDK，用于构建 Agent 应用
- 支持工具和编排
- 可替代 Agent Builder 作为后端

### 8.3 2025 年关键发展

**推理能力**：
- 从独立推理模型（o1, o3）向统一模型线发展
- GPT-5.x 家族整合推理深度、工具使用和对话质量

**多模态**：
- 音频：Realtime API 支持低延迟双向音频流
- 图像：GPT Image 1/1.5 支持高质量图像生成和编辑
- 视频：Sora 2 支持视频生成和编辑
- 文档：PDF 输入支持文档密集型工作流

**Codex**：
- GPT-5.2-Codex 成为代码生成、审查和仓库级推理的默认选择
- Codex CLI 支持本地环境中的 Agent 式编码
- 支持 AGENTS.md 和 MCP

---

## 九、Prompt Engineering 最佳实践

### 9.1 基本原则

1. **简洁是关键**：上下文窗口是公共资源
2. **默认假设 Agent 已经很聪明**：只添加它没有的信息
3. **用例子胜过冗长解释**
4. **适当的自由度**：
   - 高自由度：多种有效方法，上下文依赖决策
   - 中自由度：有首选模式，允许一定变化
   - 低自由度：脆弱操作，一致性关键

### 9.2 避免的反模式

| 反模式 | 问题 | 解决方案 |
|--------|------|---------|
| 冗长解释 | 消耗 token | 用简洁例子 |
| 信息重复 | 维护困难 | 用 references/ |
| 深层嵌套 | 难以导航 | 保持一层深度 |
| 无关文件 | 噪音 | 只保留必要文件 |
| 缺少触发器 | 难以使用 | description 包含使用场景 |
| 静态当动态可行 | 不够灵活 | 使用原型 |
| 从解决方案开始 | 忽略问题本质 | 先理解问题和上下文 |

---

## 十、实施建议

### 10.1 开发流程

```
Step 1: 用具体例子理解需求
    ↓
Step 2: 规划可复用内容（scripts, references, assets）
    ↓
Step 3: 初始化 Skill（创建目录 + SKILL.md）
    ↓
Step 4: 编辑 Skill（实现资源，编写 SKILL.md）
    ↓
Step 5: 打包 Skill（创建 .skill 归档）
    ↓
Step 6: 基于实际使用迭代
```

### 10.2 项目结构

```
skill-name/
├── SKILL.md              # 必需：指令和元数据
├── scripts/              # 可选：可执行代码
├── references/           # 可选：按需加载的文档
└── assets/               # 可选：模板、图标、字体
```

### 10.3 关键文件

**CLAUDE.md**：每个 Agent 项目必须创建
- 角色定义
- 关键文件速查
- 会话启动检查清单
- 多实例并行开发指南
- 经验教训沉淀

**PROGRESS.md**：项目进度仪表板
- 不是待办清单
- 回答：我在做什么？什么在等待？我交付了什么？

---

## 十一、参考资源

### OpenAI
- [OpenAI for Developers in 2025](https://developers.openai.com/blog/openai-for-developers-2025/)
- [Building Agents Guide](https://platform.openai.com/docs/guides/agents)
- [Responses API](https://platform.openai.com/docs/api-reference/responses)
- [Agents SDK](https://github.com/openai/openai-agents-python)
- [A Practical Guide to Building Agents (PDF)](https://cdn.openai.com/business-guides-and-resources/a-practical-guide-to-building-agents.pdf)

### Anthropic
- [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Demystifying Evals for AI Agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)
- [Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [The "Think" Tool](https://www.anthropic.com/engineering/claude-think-tool)
- [Multi-Agent Research System](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Writing Tools for Agents](https://www.anthropic.com/engineering/writing-tools-for-agents)
- [Code Execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)
- [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Introducing Advanced Tool Use](https://www.anthropic.com/engineering/introducing-advanced-tool-use-on-the-claude-developer-platform)

---

> **最后更新**：2025年2月
> 
> 本文档基于 OpenAI 和 Anthropic 官方工程博客及文档整理，建议定期查阅原文获取最新信息。
