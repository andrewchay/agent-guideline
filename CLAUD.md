# CLAUDE.md

AI Agent 工作指南 - 用于 Claude Code、Kimi CLI 等工具

---

## 1. 角色定义

Claude should act as: **[Your preferred role]**

<!-- 选项: Coach / Advisor / Pair programmer / Architect / Reviewer -->

---

## 2. 关键文件速查

| 文件 | 用途 | AI 操作权限 |
|------|------|------------|
| `PROGRESS.md` | 项目进度仪表板 | 读取 + 追加 |
| `data/dev-tasks.json` | 任务队列 | 读取 + 修改 |
| `data/api-key.json` | API 密钥配置 | 只读 (symlink) |
| `CLAUDE.md` | 本工作指南 | 只读 |

---

## 3. 会话启动检查清单

每次启动时必须执行：

```bash
# 1. 读取项目状态
cat PROGRESS.md

# 2. 检查当前任务
cat data/dev-tasks.json | jq '.tasks[] | select(.status == "in_progress")'

# 3. 确认工作目录
pwd && git status
```

---

## 4. 多实例并行开发（Git Worktree）

### 4.1 架构

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
│           │ • api-key.json      │ API 密钥                   │
│           │ • node_modules/     │ 依赖加速                   │
│           └─────────────────────┘                           │
│                                                              │
│   ⚠️ 禁止 symlink: PROGRESS.md（用 git -C 编辑主仓库）       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 任务生命周期（9 步流程）

| 步骤 | 动作 | 命令/操作 | 关键检查点 |
|------|------|-----------|-----------|
| 1 | 领取任务 | 原子读取 `dev-tasks.json` | 状态改为 "in_progress" |
| 2 | 创建 worktree | `git worktree add -b task/xxx ../worktrees/task-xxx` | 端口分配、symlink 共享文件 |
| 3 | 开发实现 | 在隔离环境编码 | 修改仅限于当前 worktree |
| 4 | 提交代码 | `git commit -m "feat: xxx"` | 提交到任务分支 |
| 5 | 合并测试 | `git merge origin/main && npm test` | 必须通过测试 |
| 6 | 合并到 main | `git rebase origin/main` → `git push` | 见 [4.3 冲突处理](#43-冲突处理) |
| 7 | 标记完成 | 更新 `dev-tasks.json` 状态为 "done" | **必须在清理前完成** |
| 8 | 清理环境 | `git worktree remove` + 删除分支 | 本地 + 远程分支 |
| 9 | 经验沉淀 | 追加到 `PROGRESS.md` | 附 commit ID |

### 4.3 冲突处理

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

## 5. 经验教训沉淀

### 5.1 记录模板

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
- **Tags**: #git #test #deploy
```

### 5.2 记录原则

| 原则 | 要求 |
|------|------|
| 及时 | 解决后立即记录 |
| 可回溯 | **必须附 Commit ID** |
| 可搜索 | 使用标签如 `#git` `#test` |
| 防重复 | **同样的问题不要犯两次** |

---

## 6. 目录结构规范

```
project/                      # 主仓库
├── .git/
├── data/
│   ├── dev-tasks.json       # 共享任务队列
│   ├── dev-task.lock        # 文件锁
│   └── api-key.json         # 共享密钥
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

## 7. 快速命令参考

```bash
# 创建任务工作区
git worktree add -b task/001 ../project-worktrees/task-001
cd ../project-worktrees/task-001
ln -s ../../project/data/dev-tasks.json data/
ln -s ../../project/data/api-key.json data/
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

## 8. 禁止事项

| 禁止项 | 原因 | 正确做法 |
|--------|------|----------|
| symlink `PROGRESS.md` | 防止状态冲突 | 用 `git -C ../../project` 编辑主仓库 |
| 直接标记任务失败 | 必须解决问题 | 按 [4.3 冲突处理](#43-冲突处理) 流程 |
| 清理前不标记完成 | 防止状态丢失 | 步骤 7 必须在步骤 8 之前 |
| 重复端口 | 服务冲突 | 每个 worktree 分配唯一端口 |

---

## 9. 项目特定上下文

<!-- 在此添加项目特定信息 -->

**Primary:** [Main project/goal]
**Secondary:** [Next priority]

---

## 10. 自定义规则

1. [Rule 1]
2. [Rule 2]
3. [Rule 3]
