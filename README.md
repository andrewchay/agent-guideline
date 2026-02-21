# AI Agent Design Guidelines

基于 OpenAI 和 Anthropic 最新研究的 AI Agent 最佳实践指南。

## 核心文档

| 文档 | 说明 |
|------|------|
| [CLAUDE.md](CLAUDE.md) | AI Agent 项目工作指南（模板） |
| [AGENTS.md](AGENTS.md) | Agent 设计原则和架构模式 |
| [BEST_PRACTICES.md](BEST_PRACTICES.md) | 最佳实践完整总结 |

## 快速开始：创建新 Agent 项目

### 1. 初始化项目

```bash
./scripts/init-agent-project.sh my-agent-project
cd my-agent-project
```

这会创建完整的项目结构，包括评估框架。

### 2. 配置项目上下文

编辑 `CLAUDE.md` 第 9 节 "项目特定上下文":

```markdown
**Primary**: [你的主要目标]
**Secondary**: [次要优先级]
**Current Focus**: [当前工作重点]
**Tech Stack**: [技术栈：语言、框架]
**Key Constraints**: [关键约束：性能、安全等]
```

### 3. 设置第一个评估（在编码之前！）

```bash
# 编辑示例任务或创建新任务
vim evals/tasks/coding/my_first_task.json
```

定义 Agent 成功的标准。

### 4. 运行基线评估

```bash
# 运行评估（可能会失败——这是预期的！）
./scripts/run-evals.sh --suite coding

# 或运行所有评估
./scripts/run-evals.sh
```

### 5. 实现你的 Agent

开始在 `src/` 中构建你的 Agent。

### 6. 迭代：编码 → 评估 → 改进

```bash
# 做出更改后，再次运行评估
./scripts/run-evals.sh --trials 5

# 查看结果
cat evals/results/latest.json
```

### 7. 跟踪进度

工作时更新 `TODO.md` 和 `PROGRESS.md`。

---

## 快速参考

| 你想做的事 | 命令 |
|-----------|------|
| 创建新项目 | `./scripts/init-agent-project.sh <name>` |
| 运行所有评估 | `./scripts/run-evals.sh` |
| 运行特定套件 | `./scripts/run-evals.sh --suite coding` |
| 运行特定任务 | `./scripts/run-evals.sh --task coding/my_task` |
| 运行更多 trials | `./scripts/run-evals.sh --trials 5` |
| 检查项目状态 | `cat PROGRESS.md && cat TODO.md` |

---

## 核心原则：评估优先开发

```
1. 定义成功标准（Task + Grader）
        ↓
2. 运行评估（建立基线）
        ↓
3. 实现最小化 Agent
        ↓
4. 运行评估 → 查看失败
        ↓
5. 修复和改进
        ↓
6. 重复步骤 4-5
```

这种方法确保你有明确的成功定义，可以客观地衡量进度。

---

## 项目结构

```
my-agent-project/
├── CLAUDE.md              # AI Agent 工作指南
├── PROGRESS.md            # 项目进度仪表板
├── TODO.md                # 当前任务清单
├── MEMORY.md              # 关键决策和上下文
├── src/                   # 源代码
├── tools/                 # Agent 工具
├── evals/                 # 评估框架
│   ├── README.md          # 评估说明
│   ├── config.yaml        # 评估配置
│   ├── harness.py         # 评估运行器
│   ├── tasks/             # 评估任务
│   │   ├── coding/
│   │   ├── research/
│   │   └── customer_support/
│   ├── graders/           # 评分逻辑
│   │   ├── base.py
│   │   ├── exact_match.py
│   │   ├── contains.py
│   │   ├── outcome.py
│   │   └── llm_judge.py
│   ├── fixtures/          # 测试数据
│   └── results/           # 评估结果
├── docs/                  # 文档
└── scripts/               # 脚本
```

---

## 关键概念

### 上下文工程（Context Engineering）
- 上下文是有限的注意力资源
- 目标是：最小的高信号 token 集合
- 使用渐进式披露：Metadata → SKILL.md → References

### 评估驱动开发（Eval-Driven Development）
- **Task**: 单个测试，定义输入和成功标准
- **Trial**: 任务的单次尝试（需多次运行）
- **Grader**: 评分逻辑
- **Transcript**: 完整交互记录
- **Outcome**: 环境最终状态

### 工作流模式
- **Prompt Chaining**: 顺序执行，可添加 gate 检查
- **Routing**: 分类后分发到专门处理
- **Parallelization**: 并行处理，多视角
- **Orchestrator-Workers**: 动态分解和委派

---

## 参考资源

### Anthropic
- [Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)
- [Demystifying Evals for AI Agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)

### OpenAI
- [Building Agents Guide](https://platform.openai.com/docs/guides/agents)
- [Agents SDK](https://github.com/openai/openai-agents-python)

---

> **提示**: 这些指南基于 OpenAI 和 Anthropic 官方工程博客，建议定期查阅原文获取最新信息。
