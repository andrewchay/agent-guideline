# AI Agent 最佳实践总结

基于 OpenAI Developer Blog 和 Anthropic Engineering Blog 的研究，整理出以下最佳实践。

---

## 一、Agent 架构设计

### 1.1 Workflows vs Agents

**Workflows（工作流）**
- LLM 和工具通过预定义的代码路径编排
- 适用于：任务明确、步骤固定的场景
- 优势：可预测性高、一致性好

**Agents（智能体）**
- LLM 动态指导自己的流程和工具使用
- 适用于：需要灵活性和模型驱动决策的场景
- 优势：灵活、自适应

**建议**：从最简单的方案开始，只在需要时才增加复杂度。

### 1.2 核心构建模块

**增强型 LLM（Augmented LLM）**
- 检索（Retrieval）
- 工具（Tools）
- 记忆（Memory）

**工作流模式**：

| 模式 | 适用场景 | 示例 |
|------|---------|------|
| **Prompt Chaining** | 任务可分解为固定子任务 | 生成营销文案→翻译 |
| **Routing** | 复杂任务有明确分类 | 客服查询路由到不同处理流程 |
| **Parallelization** | 需要多视角或并行处理 | 代码安全审查、内容审核 |
| **Orchestrator-Workers** | 复杂任务无法预测步骤 | 研究任务、复杂数据分析 |

---

## 二、上下文工程（Context Engineering）

### 2.1 核心原则

**上下文是有限的注意力资源**
- 每个新token都会消耗注意力预算
- 上下文越长，模型 recall 能力越弱（context rot）
- 目标是：最小的高信号token集合

### 2.2 System Prompt 设计

**正确的抽象层级（Goldilocks Zone）**：
- ❌ 过于具体：硬编码复杂逻辑，脆弱且难维护
- ❌ 过于模糊：缺乏具体指导，假设共享上下文
- ✅ 恰到好处：足够具体以指导行为，足够灵活以提供启发

**组织方式**：
```markdown
<background_information>
## Tool guidance
## Output description
## Examples
```

### 2.3 工具设计原则

**工具是确定性系统与非确定性Agent之间的契约**

1. **自包含**：每个工具功能独立、明确
2. **鲁棒性**：能优雅处理错误
3. **清晰的输入参数**：描述性、无歧义
4. **Token 效率**：返回信息精简
5. **避免功能重叠**：每个工具有独特用途

**命名空间建议**：
- `github-create-issue`
- `linear-address-issue`
- `slack-send-message`

---

## 三、评估（Evals）

### 3.1 评估结构

| 组件 | 定义 |
|------|------|
| **Task** | 单个测试，定义输入和成功标准 |
| **Trial** | 任务的单次尝试 |
| **Grader** | 评分逻辑，可包含多个断言 |
| **Transcript** | 完整记录（输出、工具调用、推理） |
| **Outcome** | 试验结束时的环境最终状态 |
| **Harness** | 端到端运行评估的基础设施 |

### 3.2 评估类型

**Single-turn Evals**
- 简单直接：prompt → response → grading

**Multi-turn Evals**
- Agent 在多轮中使用工具
- 错误可能传播和累积

### 3.3 评估最佳实践

1. **尽早建立评估**：明确成功的定义
2. **基于真实用例**：避免过于简单的"沙盒"环境
3. **可验证的响应**：每个 prompt 都有验证方式
4. **避免过度严格的验证器**：允许格式、措辞的合理变化
5. **收集多维度指标**：准确率、延迟、token消耗、工具调用次数

---

## 四、多Agent系统

### 4.1 适用场景

**适合多Agent**：
- 广度优先查询（同时追踪多个独立方向）
- 信息超出单上下文窗口
- 需要与众多复杂工具交互
- 高价值任务，token成本可接受

**不适合多Agent**：
- 需要所有Agent共享相同上下文
- Agent之间有大量依赖
- 实时协调要求高

### 4.2 架构模式

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

### 4.3 性能数据

- 多Agent系统比单Agent性能提升 90.2%（内部研究评估）
- Token使用量：多Agent ≈ 15× 普通聊天
- Agent ≈ 4× 普通聊天

---

## 五、工具使用优化

### 5.1 Think Tool（思考工具）

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

**性能提升**：
- Airline domain: +54% (0.370 → 0.570)
- Retail domain: +3.7% (0.783 → 0.812)

### 5.2 工具优化流程

```
1. 快速原型 → 2. 运行评估 → 3. 分析结果 → 4. 优化工具 → 5. 重复
```

**与Agent协作优化**：
- 使用 Claude Code 自动生成评估任务
- 分析失败案例，识别工具描述问题
- 迭代改进工具描述和参数

---

## 六、Responses API（OpenAI）

### 6.1 核心特性

**Stateful-by-default**
- 对话和工具状态自动跟踪
- 推理状态在轮次间保留
- GPT-5 + Responses 在 TAUBench 上比 Chat Completions 高 5%

**Multimodal from ground up**
- 文本、图像、音频、函数调用都是一等公民

**Better cache utilization**
- 比 Chat Completions 高 40-80%

**Polymorphic Items**
```json
[
  {"type": "reasoning", ...},
  {"type": "message", ...},
  {"type": "function_call", ...}
]
```

### 6.2 与 Chat Completions 对比

| 特性 | Chat Completions | Responses |
|------|-----------------|-----------|
| 状态管理 | 无状态 | 有状态 |
| 推理保留 | 轮次间丢失 | 跨轮次保留 |
| 输出结构 | 单消息 | 多项目列表 |
| 托管工具 | 有限 | 完整支持 |
| 缓存效率 | 较低 | 高 40-80% |

---

## 七、Prompt Engineering 最佳实践

### 7.1 基本原则

1. **简洁是关键**：上下文窗口是公共资源
2. **默认假设Agent已经很聪明**：只添加它没有的信息
3. **用例子胜过冗长解释**
4. **适当的自由度**：
   - 高自由度：多种有效方法，上下文依赖决策
   - 中自由度：有首选模式，允许一定变化
   - 低自由度：脆弱操作，一致性关键

### 7.2 渐进式披露设计

```
Level 1: Metadata (name + description)    → 始终在上下文 (~100 words)
Level 2: SKILL.md body                     → Skill触发时 (<5k words)
Level 3: Bundled resources                 → 按需加载 (无限制)
```

### 7.3 避免的反模式

| 反模式 | 问题 | 解决方案 |
|--------|------|---------|
| 冗长解释 | 消耗token | 用简洁例子 |
| 信息重复 | 维护困难 | 用references/ |
| 深层嵌套 | 难以导航 | 保持一层深度 |
| 无关文件 | 噪音 | 只保留必要文件 |
| 缺少触发器 | 难以使用 | description包含使用场景 |

---

## 八、MCP（Model Context Protocol）

### 8.1 设计原则

**工具是确定性系统与非确定性Agent之间的新契约**

**关键原则**：
1. 选择正确的工具实现（和不实现）
2. 命名空间定义清晰功能边界
3. 从工具返回有意义的上下文
4. 优化工具响应的token效率
5. Prompt工程优化工具描述和规格

### 8.2 工具描述优化

**好的工具描述**：
- 清晰说明工具的用途
- 描述每个参数的预期值
- 提供使用示例
- 说明错误处理方式

---

## 九、实施建议

### 9.1 开发流程

```
Step 1: 用具体例子理解需求
    ↓
Step 2: 规划可复用内容（scripts, references, assets）
    ↓
Step 3: 初始化Skill（创建目录 + SKILL.md）
    ↓
Step 4: 编辑Skill（实现资源，编写SKILL.md）
    ↓
Step 5: 打包Skill（创建 .skill 归档）
    ↓
Step 6: 基于实际使用迭代
```

### 9.2 项目结构

```
skill-name/
├── SKILL.md              # 必需：指令和元数据
├── scripts/              # 可选：可执行代码
├── references/           # 可选：按需加载的文档
└── assets/               # 可选：模板、图标、字体
```

### 9.3 关键文件

**CLAUDE.md**：每个Agent项目必须创建
- 角色定义
- 关键文件速查
- 会话启动检查清单
- 多实例并行开发指南
- 经验教训沉淀

**PROGRESS.md**：项目进度仪表板
- 不是待办清单
- 回答：我在做什么？什么在等待？我交付了什么？

---

## 十、参考资源

### OpenAI
- [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)
- [Responses API](https://developers.openai.com/blog/responses-api)
- [Shell + Skills + Compaction](https://developers.openai.com/blog/shell-skills-tips)

### Anthropic
- [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Demystifying evals for AI agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)
- [Effective context engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [The "think" tool](https://www.anthropic.com/engineering/claude-think-tool)
- [Multi-agent research system](https://www.anthropic.com/engineering/multi-agent-research-system)
- [Writing tools for agents](https://www.anthropic.com/engineering/writing-tools-for-agents)
