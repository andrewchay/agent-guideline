# PROGRESS

**Last Updated:** 2026-02-21

---

## How This Works

One file. All your projects. Updated when things change.

**Not a to-do list.** A dashboard that answers:
1. What am I working on?
2. What's waiting?
3. What have I shipped?

---

## DEVELOPMENT

### AI Agent Best Practices Research
**Status:** Documentation Complete with Comprehensive Eval Framework
**Location:** `/Users/chaihao/LLM/Guidelines/`
**What it does:** 基于 OpenAI 和 Anthropic 研究，整理 AI Agent 最佳实践

**Current state:**
- ✅ BEST_PRACTICES.md - 最佳实践总结（基于 OpenAI/Anthropic 博客）
- ✅ CLAUDE.md - 更新为包含上下文工程和评估驱动开发
- ✅ AGENTS.md - 更新 Workflow 模式、评估、多 Agent 系统
- ✅ **Eval Framework** - 基于 Anthropic "Demystifying Evals" 完整评估框架
  - 评估组件详解（Task, Trial, Grader, Transcript, Outcome, Harness）
  - 评估类型（Single-turn, Multi-turn, Agent Evals）
  - Grader 类型（Exact Match, Contains, Outcome-based, LLM-as-Judge）
  - 评估最佳实践和迭代流程
- ✅ **Init Script** - 项目初始化脚本包含完整评估框架模板
  - 评估运行器（harness.py）
  - 示例 Task 定义（coding, research, customer support）
  - Grader 实现（base, exact_match, contains, outcome, llm_judge）
  - 配置文件（config.yaml）
- ✅ 融入 Context Engineering 原则
- ✅ 融入 Eval-Driven Development 方法
- ✅ 融入 Multi-Agent Systems 架构

**Key Insights Documented:**
1. **Context Engineering** - 上下文是有限的注意力资源，需要精心策划
2. **Workflow Patterns** - Prompt Chaining, Routing, Parallelization, Orchestrator-Workers
3. **Eval-Driven Development** - 评估是高质量 Agent 的基础
4. **Evaluation Framework** - 基于 Anthropic 研究的完整评估体系
5. **Multi-Agent Systems** - 并行化带来 90.2% 性能提升
6. **Tool Design** - Think Tool 带来 +54% 性能提升

**Next:** 
- 将这些最佳实践应用到实际 Agent 开发中
- 使用新的评估框架建立实际测试用例

---

## RECENTLY COMPLETED

**February 2026:**
- 更新评估框架，基于 Anthropic "Demystifying Evals" (2026-02-21)
  - 阅读并研究 Anthropic 评估文章
  - 更新 CLAUDE.md 第 7 节：完整的评估驱动开发指南
  - 更新 AGENTS.md 第 7 节：详细的评估框架
  - 更新 scripts/init-agent-project.sh：包含完整评估框架模板
  - 添加评估组件定义（Task, Trial, Grader, Transcript, Outcome, Harness, Suite）
  - 添加 Grader 类型和实现示例
  - 添加评估最佳实践和迭代流程

**February 2025:**
- AI Agent 最佳实践研究和文档整理 (2025-02-18)
  - 阅读 OpenAI Developer Blog 所有文章
  - 阅读 Anthropic Engineering Blog 关键文章
  - 创建 BEST_PRACTICES.md 总结文档
  - 更新 CLAUDE.md 融入最佳实践
  - 更新 AGENTS.md 添加新章节

---

## Quick Reference

**High energy?** → 开始实际 Agent 开发，应用这些最佳实践
**Low energy?** → 阅读文档，理解概念
**Quick win?** → 用新的评估框架建立第一个测试套件

---

**Update this when things change. Weekly minimum.**
