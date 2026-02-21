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

# Create evals directory structure
mkdir -p evals/{tasks/{coding,research,customer_support},graders,fixtures/{codebases,databases,documents},results}

# Create evals README
cat > evals/README.md << 'EOF'
# Evaluation Framework

基于 Anthropic 最佳实践的 Agent 评估框架。

## 快速开始

```bash
# 运行所有评估
python harness.py

# 运行特定套件
python harness.py --suite coding

# 运行特定任务
python harness.py --task coding/create_mcp_server

# 指定运行次数
python harness.py --trials 5
```

## 评估组件

| 组件 | 说明 | 位置 |
|------|------|------|
| Task | 单个测试定义 | `tasks/` |
| Grader | 评分逻辑 | `graders/` |
| Harness | 评估运行器 | `harness.py` |
| Results | 评估结果 | `results/` |

## 添加新评估

1. 在 `tasks/` 下创建 Task 定义（JSON 或 Python）
2. 在 `graders/` 下实现对应的 Grader
3. 运行 `python harness.py --task your_task` 测试

## 评估类型

- **Single-turn**: 简单 prompt → response 评估
- **Multi-turn**: 工具调用和状态变化评估
- **Outcome-based**: 基于环境最终状态的评估
EOF

# Create evals config
cat > evals/config.yaml << 'EOF'
# Evaluation Configuration

# Model settings
model:
  name: "claude-sonnet-4"  # or your preferred model
  temperature: 0.0
  max_tokens: 4096

# Execution settings
execution:
  trials_per_task: 3  # Number of trials for each task
  max_concurrent: 5   # Maximum concurrent tasks
  timeout_seconds: 300  # Timeout per task

# Grading settings
grading:
  strict_mode: false  # Allow reasonable variations in format/wording
  llm_judge_model: "claude-haiku-3"  # Model for LLM-as-Judge

# Suites
suites:
  coding:
    - coding/create_mcp_server
    - coding/refactor_code
  research:
    - research/basic_search
  customer_support:
    - customer_support/refund_request
    - customer_support/cancellation
EOF

# Create harness.py
cat > evals/harness.py << 'EOF'
"""
Evaluation Harness for AI Agent

基于 Anthropic 最佳实践的评估运行器。
"""

import json
import yaml
import asyncio
import argparse
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional
from dataclasses import dataclass, asdict
from concurrent.futures import ThreadPoolExecutor


@dataclass
class TrialResult:
    """Result of a single trial."""
    trial_id: int
    passed: bool
    score: float
    reason: str
    transcript: List[Dict[str, Any]]
    latency_ms: int
    token_usage: Dict[str, int]


@dataclass  
class TaskResult:
    """Result of a task (multiple trials)."""
    task_name: str
    trials: List[TrialResult]
    pass_rate: float
    avg_score: float
    avg_latency_ms: int


class BaseGrader:
    """Base class for all graders."""
    
    def grade(self, task_input: Dict, agent_output: Any, 
              environment_state: Dict) -> Dict[str, Any]:
        """
        Grade agent output.
        
        Returns:
            {"passed": bool, "score": float, "reason": str}
        """
        raise NotImplementedError


class ExactMatchGrader(BaseGrader):
    """Exact match grader."""
    
    def __init__(self, field: str = "response", expected: str = None):
        self.field = field
        self.expected = expected
    
    def grade(self, task_input: Dict, agent_output: Any, 
              environment_state: Dict) -> Dict[str, Any]:
        actual = agent_output.get(self.field, "")
        passed = actual == self.expected
        return {
            "passed": passed,
            "score": 1.0 if passed else 0.0,
            "reason": "Exact match" if passed else f"Expected '{self.expected}', got '{actual}'"
        }


class ContainsGrader(BaseGrader):
    """Check if output contains specific content."""
    
    def __init__(self, field: str = "response", contains: List[str] = None):
        self.field = field
        self.contains = contains or []
    
    def grade(self, task_input: Dict, agent_output: Any,
              environment_state: Dict) -> Dict[str, Any]:
        actual = agent_output.get(self.field, "")
        missing = [c for c in self.contains if c not in actual]
        passed = len(missing) == 0
        return {
            "passed": passed,
            "score": 1.0 if passed else 1.0 - len(missing) / len(self.contains),
            "reason": "All required content present" if passed else f"Missing: {missing}"
        }


class OutcomeGrader(BaseGrader):
    """Grade based on environment final state."""
    
    def __init__(self, check_func: callable):
        self.check_func = check_func
    
    def grade(self, task_input: Dict, agent_output: Any,
              environment_state: Dict) -> Dict[str, Any]:
        try:
            passed = self.check_func(environment_state)
            return {
                "passed": passed,
                "score": 1.0 if passed else 0.0,
                "reason": "Outcome check passed" if passed else "Outcome check failed"
            }
        except Exception as e:
            return {
                "passed": False,
                "score": 0.0,
                "reason": f"Grader error: {e}"
            }


class EvaluationHarness:
    """Main evaluation harness."""
    
    def __init__(self, config_path: str = "config.yaml"):
        with open(config_path) as f:
            self.config = yaml.safe_load(f)
        self.results_dir = Path("results")
        self.results_dir.mkdir(exist_ok=True)
    
    async def run_task(self, task_name: str, trial_id: int) -> TrialResult:
        """Run a single trial of a task."""
        # TODO: Implement actual agent execution
        # This is a placeholder implementation
        
        start_time = datetime.now()
        
        # Load task definition
        task_path = Path(f"tasks/{task_name}.json")
        if not task_path.exists():
            task_path = Path(f"tasks/{task_name}.py")
        
        # Simulate agent execution
        # In real implementation, this would:
        # 1. Load the task
        # 2. Run the agent with the task input
        # 3. Capture transcript and environment state
        # 4. Run graders
        
        latency_ms = int((datetime.now() - start_time).total_seconds() * 1000)
        
        return TrialResult(
            trial_id=trial_id,
            passed=True,  # Placeholder
            score=1.0,
            reason="Placeholder - implement actual grading",
            transcript=[],
            latency_ms=latency_ms,
            token_usage={"input": 0, "output": 0}
        )
    
    async def run_evaluation(self, tasks: List[str], 
                            trials: int = None) -> List[TaskResult]:
        """Run evaluation for multiple tasks."""
        trials = trials or self.config["execution"]["trials_per_task"]
        results = []
        
        for task_name in tasks:
            print(f"Running task: {task_name}")
            task_trials = []
            
            # Run trials concurrently
            trial_tasks = [self.run_task(task_name, i) for i in range(trials)]
            task_trials = await asyncio.gather(*trial_tasks)
            
            # Calculate aggregates
            pass_rate = sum(1 for t in task_trials if t.passed) / trials
            avg_score = sum(t.score for t in task_trials) / trials
            avg_latency = sum(t.latency_ms for t in task_trials) // trials
            
            results.append(TaskResult(
                task_name=task_name,
                trials=task_trials,
                pass_rate=pass_rate,
                avg_score=avg_score,
                avg_latency_ms=avg_latency
            ))
        
        return results
    
    def save_results(self, results: List[TaskResult], suite_name: str = None):
        """Save evaluation results."""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        suite_suffix = f"_{suite_name}" if suite_name else ""
        
        result_file = self.results_dir / f"{timestamp}{suite_suffix}.json"
        
        output = {
            "timestamp": timestamp,
            "suite": suite_name,
            "config": self.config,
            "summary": {
                "total_tasks": len(results),
                "overall_pass_rate": sum(r.pass_rate for r in results) / len(results),
                "overall_avg_score": sum(r.avg_score for r in results) / len(results),
            },
            "results": [asdict(r) for r in results]
        }
        
        with open(result_file, 'w') as f:
            json.dump(output, f, indent=2)
        
        # Also save as latest
        latest_link = self.results_dir / "latest.json"
        if latest_link.exists():
            latest_link.unlink()
        latest_link.symlink_to(result_file.name)
        
        print(f"\nResults saved to: {result_file}")
        return result_file
    
    def print_summary(self, results: List[TaskResult]):
        """Print evaluation summary."""
        print("\n" + "="*60)
        print("EVALUATION SUMMARY")
        print("="*60)
        
        for r in results:
            status = "✅" if r.pass_rate >= 0.8 else "⚠️" if r.pass_rate >= 0.5 else "❌"
            print(f"\n{status} {r.task_name}")
            print(f"   Pass Rate: {r.pass_rate:.1%}")
            print(f"   Avg Score: {r.avg_score:.2f}")
            print(f"   Avg Latency: {r.avg_latency_ms}ms")
        
        overall_pass = sum(r.pass_rate for r in results) / len(results)
        print(f"\n{'='*60}")
        print(f"Overall Pass Rate: {overall_pass:.1%}")
        print("="*60)


async def main():
    parser = argparse.ArgumentParser(description="Run Agent Evaluations")
    parser.add_argument("--suite", help="Run a specific test suite")
    parser.add_argument("--task", help="Run a specific task")
    parser.add_argument("--trials", type=int, help="Number of trials per task")
    parser.add_argument("--config", default="config.yaml", help="Config file path")
    args = parser.parse_args()
    
    harness = EvaluationHarness(args.config)
    
    # Determine which tasks to run
    if args.task:
        tasks = [args.task]
    elif args.suite:
        tasks = harness.config["suites"].get(args.suite, [])
    else:
        # Run all tasks from all suites
        tasks = []
        for suite_tasks in harness.config["suites"].values():
            tasks.extend(suite_tasks)
    
    if not tasks:
        print("No tasks to run!")
        return
    
    print(f"Running {len(tasks)} task(s) with {args.trials or harness.config['execution']['trials_per_task']} trial(s) each")
    
    # Run evaluation
    results = await harness.run_evaluation(tasks, args.trials)
    
    # Print and save results
    harness.print_summary(results)
    harness.save_results(results, args.suite)


if __name__ == "__main__":
    asyncio.run(main())
EOF

# Create example tasks
cat > evals/tasks/coding/create_mcp_server.json << 'EOF'
{
  "name": "coding/create_mcp_server",
  "description": "Create a working MCP server with proper structure",
  "category": "coding",
  "difficulty": "medium",
  "input": {
    "prompt": "Create an MCP server that provides a simple calculator tool with add, subtract, multiply, divide operations. The server should follow MCP protocol standards.",
    "files": [],
    "context": "You are building an MCP server for a calculator tool."
  },
  "expected_outcome": {
    "description": "A working MCP server with calculator tools",
    "files_created": ["server.py", "tools.py"],
    "requirements": [
      "Server follows MCP protocol",
      "Implements all four calculator operations",
      "Handles errors gracefully"
    ]
  },
  "graders": [
    {
      "type": "static_analysis",
      "checks": ["python_syntax", "mcp_imports"]
    },
    {
      "type": "outcome",
      "check": "server_runs_and_responds"
    },
    {
      "type": "unit_test",
      "test_file": "test_calculator.py"
    }
  ],
  "timeout_seconds": 180
}
EOF

cat > evals/tasks/coding/refactor_code.json << 'EOF'
{
  "name": "coding/refactor_code",
  "description": "Refactor messy code while maintaining functionality",
  "category": "coding",
  "difficulty": "easy",
  "input": {
    "prompt": "Refactor the following code to improve readability and maintainability without changing behavior:",
    "files": ["messy_code.py"],
    "context": "Focus on: function extraction, variable naming, removing duplication"
  },
  "expected_outcome": {
    "description": "Refactored code with same behavior",
    "requirements": [
      "All existing tests pass",
      "Code is more readable",
      "No functionality changed"
    ]
  },
  "graders": [
    {
      "type": "static_analysis",
      "checks": ["linting", "complexity"]
    },
    {
      "type": "unit_test",
      "test_file": "test_original.py"
    }
  ],
  "timeout_seconds": 120
}
EOF

cat > evals/tasks/research/basic_search.json << 'EOF'
{
  "name": "research/basic_search",
  "description": "Find specific information through search",
  "category": "research",
  "difficulty": "easy",
  "input": {
    "prompt": "Find the release date of Python 3.10 and list three major features introduced in this version.",
    "tools_available": ["web_search", "web_fetch"]
  },
  "expected_outcome": {
    "description": "Accurate information about Python 3.10",
    "key_facts": [
      "Release date: October 4, 2021",
      "Pattern matching (structural pattern matching)",
      "Precise types in type hints (| operator)",
      "Context managers improvements"
    ]
  },
  "graders": [
    {
      "type": "contains",
      "required_content": ["October 2021", "pattern matching", "union types"]
    },
    {
      "type": "llm_judge",
      "criteria": "Accuracy and completeness of information"
    }
  ],
  "timeout_seconds": 60
}
EOF

cat > evals/tasks/customer_support/refund_request.json << 'EOF'
{
  "name": "customer_support/refund_request",
  "description": "Handle customer refund request following policy",
  "category": "customer_support",
  "difficulty": "medium",
  "input": {
    "prompt": "A customer wants a refund for an order placed 25 days ago. Our policy allows refunds within 30 days. Process this request.",
    "context": "You are a customer support agent. Follow the refund policy and be polite.",
    "tools_available": ["lookup_order", "process_refund", "escalate"]
  },
  "expected_outcome": {
    "description": "Refund processed correctly",
    "requirements": [
      "Verify order is within 30-day window",
      "Process refund using correct tool",
      "Provide confirmation to customer"
    ]
  },
  "graders": [
    {
      "type": "outcome",
      "check": "refund_recorded_in_database"
    },
    {
      "type": "llm_judge",
      "criteria": "Politeness, clarity, policy compliance"
    }
  ],
  "timeout_seconds": 60
}
EOF

cat > evals/tasks/customer_support/cancellation.json << 'EOF'
{
  "name": "customer_support/cancellation",
  "description": "Handle subscription cancellation",
  "category": "customer_support",
  "difficulty": "easy",
  "input": {
    "prompt": "Customer wants to cancel their subscription. They are on a monthly plan. Handle this request.",
    "tools_available": ["lookup_subscription", "cancel_subscription", "offer_retention_deal"]
  },
  "expected_outcome": {
    "description": "Subscription cancelled with retention attempt",
    "requirements": [
      "Attempt retention offer first",
      "If declined, process cancellation",
      "Confirm effective date"
    ]
  },
  "graders": [
    {
      "type": "outcome",
      "check": "subscription_status_cancelled"
    },
    {
      "type": "llm_judge",
      "criteria": "Followed process: retention attempt before cancellation"
    }
  ],
  "timeout_seconds": 60
}
EOF

# Create grader implementations
cat > evals/graders/__init__.py << 'EOF'
"""Evaluation graders."""

from .base import BaseGrader
from .exact_match import ExactMatchGrader
from .contains import ContainsGrader
from .outcome import OutcomeGrader
from .llm_judge import LLMJudgeGrader

__all__ = [
    "BaseGrader",
    "ExactMatchGrader",
    "ContainsGrader",
    "OutcomeGrader",
    "LLMJudgeGrader",
]
EOF

cat > evals/graders/base.py << 'EOF'
"""Base grader class."""

from abc import ABC, abstractmethod
from typing import Dict, Any


class BaseGrader(ABC):
    """Base class for all graders."""
    
    @abstractmethod
    def grade(self, task_input: Dict, agent_output: Any, 
              environment_state: Dict) -> Dict[str, Any]:
        """
        Grade agent output.
        
        Args:
            task_input: The input given to the agent
            agent_output: The agent's response
            environment_state: Final state of the environment
            
        Returns:
            Dict with keys:
                - passed: bool
                - score: float (0.0 to 1.0)
                - reason: str
        """
        pass
EOF

cat > evals/graders/exact_match.py << 'EOF'
"""Exact match grader."""

from .base import BaseGrader
from typing import Dict, Any


class ExactMatchGrader(BaseGrader):
    """Grades by exact string match."""
    
    def __init__(self, field: str = "response", expected: str = None):
        self.field = field
        self.expected = expected
    
    def grade(self, task_input: Dict, agent_output: Any,
              environment_state: Dict) -> Dict[str, Any]:
        actual = agent_output.get(self.field, "")
        passed = actual == self.expected
        
        return {
            "passed": passed,
            "score": 1.0 if passed else 0.0,
            "reason": "Exact match" if passed else f"Expected '{self.expected}', got '{actual}'"
        }
EOF

cat > evals/graders/contains.py << 'EOF'
"""Contains grader - checks if output contains required content."""

from .base import BaseGrader
from typing import Dict, Any, List


class ContainsGrader(BaseGrader):
    """Grades by checking if output contains required content."""
    
    def __init__(self, field: str = "response", required: List[str] = None):
        self.field = field
        self.required = required or []
    
    def grade(self, task_input: Dict, agent_output: Any,
              environment_state: Dict) -> Dict[str, Any]:
        actual = agent_output.get(self.field, "")
        missing = [r for r in self.required if r.lower() not in actual.lower()]
        passed = len(missing) == 0
        
        return {
            "passed": passed,
            "score": 1.0 if passed else 1.0 - len(missing) / len(self.required),
            "reason": "All required content present" if passed else f"Missing: {missing}"
        }
EOF

cat > evals/graders/outcome.py << 'EOF'
"""Outcome-based grader - checks environment state."""

from .base import BaseGrader
from typing import Dict, Any, Callable


class OutcomeGrader(BaseGrader):
    """Grades based on environment final state."""
    
    def __init__(self, check_func: Callable[[Dict], bool] = None):
        self.check_func = check_func
    
    def grade(self, task_input: Dict, agent_output: Any,
              environment_state: Dict) -> Dict[str, Any]:
        if self.check_func is None:
            return {
                "passed": False,
                "score": 0.0,
                "reason": "No check function provided"
            }
        
        try:
            passed = self.check_func(environment_state)
            return {
                "passed": passed,
                "score": 1.0 if passed else 0.0,
                "reason": "Outcome check passed" if passed else "Outcome check failed"
            }
        except Exception as e:
            return {
                "passed": False,
                "score": 0.0,
                "reason": f"Grader error: {e}"
            }
EOF

cat > evals/graders/llm_judge.py << 'EOF'
"""LLM-as-Judge grader."""

from .base import BaseGrader
from typing import Dict, Any


class LLMJudgeGrader(BaseGrader):
    """Uses an LLM to judge output quality."""
    
    def __init__(self, criteria: str = None, model: str = None):
        self.criteria = criteria
        self.model = model or "claude-haiku-3"
    
    def grade(self, task_input: Dict, agent_output: Any,
              environment_state: Dict) -> Dict[str, Any]:
        """
        Grade using LLM as judge.
        
        In production, this would call an LLM with a structured prompt.
        For now, returns a placeholder.
        """
        # TODO: Implement actual LLM call
        # prompt = f"""
        # Evaluate the following agent output based on these criteria: {self.criteria}
        # 
        # Task: {task_input.get('prompt')}
        # Agent Output: {agent_output}
        # 
        # Respond with JSON: {{"passed": bool, "score": float, "reason": str}}
        # """
        
        return {
            "passed": True,
            "score": 1.0,
            "reason": f"LLM judge placeholder - criteria: {self.criteria}"
        }
EOF

echo "✅ Evaluation framework created in evals/"

echo "✅ Project '$PROJECT_NAME' initialized successfully!"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_NAME"
echo "  2. Edit CLAUDE.md section 6 '项目特定上下文'"
echo "  3. Update TODO.md with your specific tasks"
echo "  4. Start building your Agent!"
