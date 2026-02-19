#!/bin/bash
# Initialize a new AI Agent project with CLAUDE.md template
# Usage: ./init-agent-project.sh <project-name>

set -e

PROJECT_NAME=$1

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: $0 <project-name>"
    echo "Example: $0 my-agent-project"
    exit 1
fi

# Create project directory
mkdir -p "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Create directory structure
mkdir -p src tools evals/{tasks,graders,results} docs scripts

# Create CLAUDE.md
cat > CLAUDE.md << 'EOF'
# CLAUDE.md

AI Agent 项目工作指南

> 本文件是 AI Agent（Claude Code、Kimi CLI 等）的工作指南。

---

## 1. 角色定义

**Claude should act as**: Senior AI Agent Engineer

**核心职责**：
- 设计和实现高质量的 AI Agent 系统
- 遵循上下文工程和渐进式披露原则
- 构建可评估、可迭代的 Agent 工作流

---

## 2. 关键文件速查

| 文件 | 用途 | AI 权限 |
|------|------|---------|
| `CLAUDE.md` | 本工作指南 | 只读 |
| `PROGRESS.md` | 项目进度仪表板 | 读取 + 追加 |
| `TODO.md` | 当前任务清单 | 读取 + 修改 |
| `MEMORY.md` | 关键决策和上下文 | 读取 + 追加 |
| `evals/` | 评估用例和结果 | 读取 + 修改 |

---

## 3. 会话启动检查清单

每次启动时执行：

```bash
head -100 PROGRESS.md
cat TODO.md
head -50 MEMORY.md
pwd && git status
```

---

## 4. Agent 架构设计

### 4.1 架构选择

```
任务是否明确、步骤固定？
├── 是 → Workflow (Prompt Chaining / Routing / Parallelization)
└── 否 → Agent (Orchestrator-Workers / Autonomous)
```

**原则**：从最简单的方案开始，只在需要时才增加复杂度。

### 4.2 上下文工程

- 上下文是有限的注意力资源
- 目标是：最小的高信号 token 集合
- 使用渐进式披露：Metadata → SKILL.md → References

### 4.3 工具设计

- 自包含、鲁棒、清晰参数
- Token 效率优先
- 避免功能重叠
- 使用命名空间：`github-create-issue`

---

## 5. 项目文件体系

### PROGRESS.md - 项目进度仪表板

```markdown
# PROGRESS
**Last Updated:** [Date]

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

### TODO.md - 当前任务清单

```markdown
# TODO

## Active Tasks
- [ ] Task 1 (Priority: High)
- [ ] Task 2 (Priority: Medium)

## Completed Today
- [x] Completed task
```

### MEMORY.md - 关键决策

```markdown
# MEMORY

## Key Decisions
### [Date]: [Decision Title]
**Context:** [Why]
**Decision:** [What]
**Consequences:** [Impact]
```

---

## 6. 项目特定上下文

**Primary**: [Main project/goal]
**Secondary**: [Next priority]
**Current Focus**: [What we're working on]
**Tech Stack**: [Languages, frameworks]
**Key Constraints**: [Performance, security]

---

## 7. 自定义规则

1. 简洁优先：每个 token 都要有价值
2. 示例胜过说明
3. 工具最小化
4. 评估先行
5. 频繁更新 TODO
6. 记录关键决策

---

## 8. 禁止事项

- 冗长 System Prompt
- 工具功能重叠
- 忽视错误处理
- 返回过多信息
- 跳过评估
- 长上下文迷信
EOF

# Create PROGRESS.md
cat > PROGRESS.md << EOF
# PROGRESS

**Last Updated:** $(date +%Y-%m-%d)

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

---

## DESIGN

> Committed projects in planning phase.

---

## DEVELOPMENT

> Actively building.

### $PROJECT_NAME
**Status:** Initializing
**Location:** $(pwd)
**What it does:** [To be filled]
**Current state:** Project structure created
**Next:** Define project scope and requirements
**Blockers:** None

---

## LIVE

> Shipped and running.

---

## RECENTLY COMPLETED

**$(date +%B %Y):**
- Project initialized ($(date +%Y-%m-%d))

---

## ON ICE

> Paused. Not deleted — just not active.

---

## Quick Reference

**High energy?** → Define core architecture
**Low energy?** → Documentation and setup
**Quick win?** → Create first tool prototype

---

**Update this when things change. Weekly minimum.**
EOF

# Create TODO.md
cat > TODO.md << EOF
# TODO - $PROJECT_NAME

## Active Tasks

- [ ] Define project scope and requirements
- [ ] Design Agent architecture
- [ ] Create first tool prototype
- [ ] Set up evaluation framework

## Backlog

- [ ] Implement core Agent loop
- [ ] Add memory/context management
- [ ] Create comprehensive evals
- [ ] Documentation

## Completed

- [x] Initialize project structure ($(date +%Y-%m-%d))
EOF

# Create MEMORY.md
cat > MEMORY.md << EOF
# MEMORY - $PROJECT_NAME

## Project Initialization

**Date:** $(date +%Y-%m-%d)
**Project:** $PROJECT_NAME

## Key Decisions

### $(date +%Y-%m-%d): Project Structure
**Context:** Starting a new AI Agent project
**Decision:** Use standard Agent project structure with CLAUDE.md, PROGRESS.md, TODO.md, MEMORY.md
**Consequences:** Consistent project management across Agent sessions

## Important Context

- Project initialized with CLAUDE.md template
- Following Anthropic/OpenAI best practices
- Eval-driven development approach
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# Dependencies
node_modules/
__pycache__/
*.pyc
.env
venv/

# IDE
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Logs
*.log
logs/

# Eval results (may contain sensitive data)
evals/results/*.json
evals/results/*.txt

# Temporary files
tmp/
temp/
*.tmp
EOF

# Create README.md
cat > README.md << EOF
# $PROJECT_NAME

AI Agent project created with CLAUDE.md template.

## Project Structure

\`\`\`
.
├── CLAUDE.md          # AI Agent 工作指南
├── PROGRESS.md        # 项目进度仪表板
├── TODO.md            # 当前任务清单
├── MEMORY.md          # 关键决策和上下文
├── src/               # 源代码
├── tools/             # Agent 工具
├── evals/             # 评估用例
│   ├── tasks/         # 评估任务
│   ├── graders/       # 评分逻辑
│   └── results/       # 评估结果
├── docs/              # 文档
└── scripts/           # 脚本
\`\`\`

## Getting Started

1. Read \`CLAUDE.md\` for project guidelines
2. Check \`TODO.md\` for current tasks
3. Update \`PROGRESS.md\` with project status

## Development

- Follow context engineering principles
- Use eval-driven development
- Update MEMORY.md for key decisions
EOF

# Create sample eval structure
cat > evals/tasks/example_task.json << 'EOF'
{
  "name": "example_task",
  "description": "Example evaluation task",
  "input": {
    "prompt": "Example prompt for the agent"
  },
  "expected_outcome": {
    "description": "What success looks like"
  },
  "grader": {
    "type": "exact_match",
    "field": "response"
  }
}
EOF

cat > evals/graders/example_grader.py << 'EOF'
"""Example grader for evaluation tasks."""

def grade_example(task_input, agent_output, expected_outcome):
    """
    Grade agent output against expected outcome.
    
    Args:
        task_input: The input given to the agent
        agent_output: The agent's response
        expected_outcome: The expected result
    
    Returns:
        dict: {"passed": bool, "score": float, "reason": str}
    """
    # Implement grading logic
    passed = agent_output.get("response") == expected_outcome.get("expected_response")
    
    return {
        "passed": passed,
        "score": 1.0 if passed else 0.0,
        "reason": "Exact match" if passed else "Response mismatch"
    }
EOF

echo "✅ Project '$PROJECT_NAME' initialized successfully!"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. Edit CLAUDE.md section 6 '项目特定上下文'"
echo "  3. Update TODO.md with your specific tasks"
echo "  4. Start building your Agent!"
