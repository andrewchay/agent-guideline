# CLAUDE.md

AI Agent 工作指南 - 基于 Anthropic 和 OpenAI 最佳实践

---

## 1. 角色定义

Claude should act as: **Senior AI Agent Engineer**

**核心职责**：
- 设计和实现高质量的 AI Agent 系统
- 遵循上下文工程和渐进式披露原则
- 构建可评估、可迭代的 Agent 工作流

---

## 2. 关键文件速查

| 文件 | 用途 | AI 权限 | 备注 |
|------|------|---------|------|
| `BEST_PRACTICES.md` | AI Agent 最佳实践总结 | 只读 | 基于 OpenAI/Anthropic 研究 |
| `AGENTS.md` | Agent 设计指南 | 读取 + 编辑 | Skill 设计规范 |
| `CLAUDE.md` | 本工作指南 | 只读 | 会话启动必读 |
| `PROGRESS.md` | 项目进度仪表板 | 读取 + 追加 | 禁止 symlink |
| `data/dev-tasks.json` | 任务队列 | 读取 + 修改 | 原子操作 |
| `data/dev-task.lock` | 文件锁 | 读取 + 创建/删除 | 并发控制 |

---

## 3. 会话启动检查清单

每次启动时必须执行：

```bash
# 1. 读取最佳实践（保持最新认知）
cat BEST_PRACTICES.md

# 2. 读取项目状态
cat PROGRESS.md

# 3. 检查当前任务
cat data/dev-tasks.json | jq '.tasks[] | select(.status == "in_progress")'

# 4. 确认工作目录
pwd && git status
```

---

## 4. 核心设计原则

### 4.1 上下文工程（Context Engineering）

**关键认知**：
- 上下文窗口是有限的注意力资源
- 每个 token 都会消耗注意力预算
- 目标是：最小的高信号 token 集合

**实践要点**：
1. **简洁是关键**：挑战每段信息的价值
2. **渐进式披露**：
   - Level 1: Metadata (~100 words) - 始终在上下文
   - Level 2: SKILL.md body (<5k words) - Skill 触发时加载
   - Level 3: References - 按需加载
3. **避免 context rot**：上下文越长，recall 能力越弱

### 4.2 Agent 架构选择

**决策树**：
```
任务是否明确、步骤固定？
├── 是 → Workflow（Prompt Chaining / Routing / Parallelization）
└── 否 → 需要灵活性？
    ├── 是 → Agent（Orchestrator-Workers / Autonomous）
    └── 否 → 单 LLM 调用 + RAG
```

**Workflow 模式选择**：

| 模式 | 适用场景 | 关键特征 |
|------|---------|---------|
| **Prompt Chaining** | 可分解为固定子任务 | 顺序执行，可添加 gate |
| **Routing** | 有明显分类的任务 | 分类后分发到专门处理 |
| **Parallelization** | 需要多视角或并行 | Sectioning 或 Voting |
| **Orchestrator-Workers** | 复杂、不可预测的任务 | 动态分解和委派 |

### 4.3 工具设计

**核心原则**：工具是确定性系统与非确定性 Agent 之间的契约

**设计要点**：
1. **自包含**：功能独立、明确
2. **鲁棒性**：优雅处理错误
3. **清晰参数**：描述性、无歧义
4. **Token 效率**：返回精简信息
5. **避免重叠**：每个工具有独特用途

**命名规范**：
- 使用命名空间：`github-create-issue`, `slack-send-message`
- 小写字母、数字、连字符
- 动词开头，清晰描述动作

---

## 5. 评估驱动开发（Eval-Driven Development）

### 5.1 评估结构

```
Evaluation Suite
├── Task 1
│   ├── Input (prompt)
│   ├── Expected Outcome
│   └── Grader (验证逻辑)
├── Task 2
│   └── ...
└── Metrics
    ├── Pass Rate
    ├── Token Usage
    ├── Latency
    └── Tool Call Count
```

### 5.2 评估最佳实践

1. **尽早建立评估**：明确成功定义
2. **基于真实用例**：避免简单"沙盒"环境
3. **可验证响应**：每个 prompt 都有验证方式
4. **避免过度严格**：允许合理的变化
5. **多维度指标**：准确率、成本、延迟

### 5.3 迭代流程

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

## 6. 多实例并行开发（Git Worktree）

### 6.1 架构

```
┌─────────────────────────────────────────────────────────────┐
│                    并行开发架构                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   Worker 1 (port: 5200)      Worker 2 (port: 5201)          │
│   ┌───────────────┐          ┌───────────────┐              │
│   │ worktree/     │          │ worktree/     │              │
│   │ ├── data/     │          │ ├── data/     │ 隔离实验数据  │
│   │ └── src/      │          │ └── src/      │              │
│   └───────┬───────┘          └───────┬───────┘              │
│           │                          │                       │
│           └──────────┬───────────────┘                       │
│                      │                                       │
│           ┌──────────▼──────────┐                           │
│           │   共享文件 (symlink) │                           │
│           ├─────────────────────┤                           │
│           │ • dev-tasks.json    │ 任务队列                   │
│           │ • dev-task.lock     │ 文件锁                     │
│           │ • BEST_PRACTICES.md │ 最佳实践（只读）            │
│           │ • CLAUDE.md         │ 工作指南（只读）            │
│           └─────────────────────┘                           │
│                                                              │
│   ⚠️ 禁止 symlink: PROGRESS.md（用 git -C 编辑主仓库）       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 6.2 任务生命周期（9 步流程）

| 步骤 | 动作 | 命令/操作 | 关键检查点 |
|------|------|-----------|-----------|
| 1 | 领取任务 | 原子读取 `dev-tasks.json` | 状态改为 "in_progress" |
| 2 | 创建 worktree | `git worktree add -b task/xxx ../worktrees/task-xxx` | 端口分配、symlink 共享文件 |
| 3 | 开发实现 | 在隔离环境编码 | 修改仅限于当前 worktree |
| 4 | 提交代码 | `git commit -m "feat: xxx"` | 提交到任务分支 |
| 5 | 合并测试 | `git merge origin/main && npm test` | 必须通过测试 |
| 6 | 合并到 main | `git rebase origin/main` → `git push` | 见 [6.3 冲突处理](#63-冲突处理) |
| 7 | 标记完成 | 更新 `dev-tasks.json` 状态为 "done" | **必须在清理前完成** |
| 8 | 清理环境 | `git worktree remove` + 删除分支 | 本地 + 远程分支 |
| 9 | 经验沉淀 | 追加到 `PROGRESS.md` | 附 commit ID |

### 6.3 冲突处理

#### Rebase 失败

```bash
# 情况 1: unstaged changes
git stash && git rebase --continue

# 情况 2: merge conflicts
git status                    # 查看冲突文件
# 手动解决冲突标记 <<<<<<< ======= >>>>>>>
git add <resolved-files>
git rebase --continue
# 重复直到完成
```

#### 测试失败

```bash
npm test                      # 1. 运行测试
# 2. 分析错误信息
# 3. 修复代码
git commit -m "fix: xxx"      # 4. 提交修复
npm test                      # 5. 重新测试（循环直到通过）
```

> ⚠️ **原则**：遇到冲突或测试失败必须解决，**不能放弃任务**。

---

## 7. 经验教训沉淀

### 7.1 记录模板

每次问题/重要改动后，追加到 `PROGRESS.md`：

```markdown
## 2024-01-XX 经验教训

### 问题：XXX
描述...

### 原因
为什么会发生...

### 解决方案
如何解决的...

### 预防措施
- [ ] 检查项 1
- [ ] 检查项 2

### 参考
- **Git Commit**: `abc1234`  ← 必须附上
- **Tags**: #context-engineering #evals #tools
```

### 7.2 记录原则

| 原则 | 要求 |
|------|------|
| 及时 | 解决后立即记录 |
| 可回溯 | **必须附 Commit ID** |
| 可搜索 | 使用标签如 `#evals` `#tools` |
| 防重复 | **同样的问题不要犯两次** |

---

## 8. 目录结构规范

```
project/                      # 主仓库
├── .git/
├── data/
│   ├── dev-tasks.json       # 共享任务队列
│   ├── dev-task.lock        # 文件锁
│   └── api-key.json         # 共享密钥
├── BEST_PRACTICES.md        # AI Agent 最佳实践
├── CLAUDE.md                # ⚠️ 禁止 symlink
├── AGENTS.md                # Agent 设计指南
├── PROGRESS.md              # ⚠️ 禁止 symlink
├── src/
└── ...

project-worktrees/           # worktree 根目录（与主仓库同级）
├── task-001/               # 任务 1 工作区
│   ├── data/               # 隔离实验数据
│   ├── node_modules -> ../../project/node_modules
│   └── ...
├── task-002/
└── task-003/
```

---

## 9. 快速命令参考

```bash
# 创建任务工作区
git worktree add -b task/001 ../project-worktrees/task-001
cd ../project-worktrees/task-001
ln -s ../../project/data/dev-tasks.json data/
ln -s ../../project/data/api-key.json data/
ln -s ../../project/BEST_PRACTICES.md .
ln -s ../../project/CLAUDE.md .
ln -s ../../project/node_modules .
export PORT=5201

# 完成任务并清理
git checkout main
git merge task/001
git push origin main
# 更新 dev-tasks.json 标记完成
git worktree remove ../project-worktrees/task-001
git branch -D task/001
git push origin --delete task/001
```

---

## 10. 禁止事项

| 禁止项 | 原因 | 正确做法 |
|--------|------|----------|
| symlink `PROGRESS.md` | 防止状态冲突 | 用 `git -C ../../project` 编辑主仓库 |
| 直接标记任务失败 | 必须解决问题 | 按 [6.3 冲突处理](#63-冲突处理) 流程 |
| 清理前不标记完成 | 防止状态丢失 | 步骤 7 必须在步骤 8 之前 |
| 重复端口 | 服务冲突 | 每个 worktree 分配唯一端口 |
| 冗长 System Prompt | 消耗注意力预算 | 遵循上下文工程原则 |
| 工具功能重叠 | 增加认知负担 | 每个工具功能独立、明确 |

---

## 11. 项目特定上下文

**Primary**: AI Agent 技能开发和最佳实践研究
**Secondary**: 多 Agent 系统架构设计

**当前重点**：
- 基于 OpenAI/Anthropic 最佳实践更新文档
- 建立可复用的 Agent 设计模式
- 实现评估驱动的开发流程

---

## 12. 自定义规则

1. **始终先读取 BEST_PRACTICES.md**：保持对最新最佳实践的认知
2. **上下文优先于提示词**：关注整体上下文配置，而非单条提示词优化
3. **评估先行**：新 Agent 功能必须有对应的评估用例
4. **工具最小化**：只实现必要的工具，避免工具膨胀
5. **渐进式披露**：Skill 文档按层级组织，避免信息过载
