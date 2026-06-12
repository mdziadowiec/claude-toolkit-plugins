---
name: karpathy
description: >
  Coding-discipline guidelines that reduce common LLM coding mistakes —
  Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution.
  Invoke when the user types "/karpathy", or asks to "be disciplined", "no
  overengineering", "keep it surgical", "minimal diff", "think before you code",
  "stop overcomplicating", or wants tighter, more cautious coding behavior on a
  task. These bias toward caution over speed; for trivial tasks, use judgment.
---

# Karpathy Skills — Coding Discipline

Behavioral guidelines to reduce common LLM coding mistakes. They bias toward caution over speed; for trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

> For *bug fixes* specifically, the advisor-call rule lives in the global `## Guardrails` section (call the advisor before committing to an uncertain fix). Don't restate it — follow it.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove imports/variables/functions that YOUR changes made unused; don't remove pre-existing dead code unless asked.

The test: every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan with a verify check per step.

---

**Working if:** fewer unnecessary changes in diffs, fewer rewrites from overcomplication, and clarifying questions come before implementation rather than after mistakes.
