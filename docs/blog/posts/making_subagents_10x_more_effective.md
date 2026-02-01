---
title: "Backpressure: making subagents 10x more effective"
date: 2025-10-01
description: "Backpressure is the simplest lever I've found to stop subagents from going runaway."
categories:
  - AI
authors:
  - yongquantan
---

Subagents are great at exploring, but terrible at stopping. If you've ever spun up a helper agent and watched it spray dozens of tool calls, you know the pain: high latency, noisy output, and a growing chance it drifts into nonsense.

The fix isn't more prompts. It's backpressure.

In this article, I'll walk through how I made subagents roughly **10x more effective** by applying three backpressure levers:

- Reduce tool calls without hurting accuracy
- Enrich error logs so agents recover faster
- Minimize total steps before they go runaway

<!-- more -->

## The problem: subagents optimize for "do more"

Most subagents are designed to be helpful, which often translates to "do everything you can think of." This is a terrible default when you have:

- Expensive tools (search, web, code execution)
- Long-running tasks with branching paths
- Latency-sensitive workflows

In practice, the failure pattern looked like this:

- A subagent calls tools in a loop because it isn't sure
- Errors are returned, but with no guidance to recover
- Each error triggers more tool calls
- Eventually the agent locks into a local loop and burns tokens

In my case, giving `claude-haiku-4-5-20251001` 5 unoptimized tools and a step budget of 150 meant that it'd constantly churn through steps, calling tools repeatedly without clear progress, often spiraling into loops until the entire budget was exhausted.

We needed a way to apply pressure back onto the subagent so it would only spend what it could justify.

## Backpressure lever 1: reduce tool calls

First, I treated tool calls like a scarce resource. If the agent calls a tool, it needs to be worth it.

### Strategy

- **Plan before calling tools.** Require a short plan (2-4 steps) and a clear success criterion.
- **Batch calls when possible.** If two tools can be used in one pass, prefer a single pass with richer input.
- **Cache obvious queries.** If the same search or file is used twice, reuse the result.

### Result

I saw tool call counts drop by 50-80% depending on task. But the bigger effect was *behavioral*: the agent stopped fishing and started reasoning.

## Backpressure lever 2: enrich error logs

Errors are only useful if they help recovery. Most tool errors are raw, unhelpful, and force the agent to guess the fix.

### Strategy

- **Add context to errors.** Include the inputs, constraints, and likely failure mode.
- **Provide a next-step hint.** A single line like "Try X with Y" cuts recovery time dramatically.
- **Tag errors with types.** Parsing "Timeout" vs "Bad input" helps the agent choose a different path.

### Example

Instead of:

```
ToolError: request failed
```

I emitted:

```
ToolError: request failed (timeout)
Input: search(query="...")
Hint: reduce result size or tighten query
```

This single change reduced loops after failures by about 3x in my tests.

## Backpressure lever 3: minimize total steps

Even with fewer tool calls and better errors, subagents still drift when tasks take too many steps. The longer the chain, the higher the chance of drifting off the original goal.

### Strategy

- **Set a step budget.** Hard limit for tool calls or reasoning steps per task.
- **Early exit when confidence is high.** If confidence crosses a threshold, stop.
- **Escalate to human or parent agent.** When the budget is hit, return a partial result and ask for guidance.

### Result

With a step cap in place, success rates went up because failures were caught early rather than compounding. The parent agent could then decide whether to retry with new constraints.

## Putting it together: a simple backpressure policy

Here's the policy I ended up with:

- Tool call budget: 3-5 calls per subtask
- Mandatory plan before first call
- Typed error logs with recovery hint
- Early exit if confidence is high

This doesn't eliminate subagent failure. It just stops failures from becoming catastrophes.

## Why this works

Backpressure works because it aligns the subagent's incentives with your system's needs:

- **Fewer calls** means less exploration and more reasoning
- **Better errors** means faster recovery and less looping
- **Shorter chains** means less drift and higher precision

This doesn't just reduce costs. It improves the *shape* of subagent behavior.

## Key takeaways

- Treat tool calls as scarce resources, not free actions
- Enrich errors with hints so recovery is deliberate
- Cap steps to prevent runaway loops
- Backpressure is a policy, not a prompt

## Start Today

If you run subagents in production, add a tool call budget and a single-line recovery hint to errors. You'll feel the improvement immediately.

Backpressure is the simplest way I've found to make subagents behave like senior engineers instead of infinite interns.
