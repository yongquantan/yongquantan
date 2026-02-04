---
title: "Backpressure: making subagents 10x more effective"
date: 2026-02-01
description: "Backpressure is the simplest lever I've found to stop subagents from going runaway."
categories:
  - AI
authors:
  - yongquantan
---

Subagents are great at exploring, but terrible at stopping. If you've ever spun up a helper agent and watched it spray dozens of tool calls, you know the pain: high latency, noisy output, and a growing chance it drifts into nonsense.

The fix isn't more prompts. It's backpressure.

In this article, I'll walk through how I made subagents roughly **10x more effective** by applying three levers:

- Reduce tool calls without hurting accuracy
- Enrich error logs so agents recover faster
- Minimize total steps before they go runaway

With reference to projects I've worked on, you'll get to learn what it takes to evolve a subagent out-of-the-box to to a successful, token-efficient one.

<!-- more -->

## The problem: subagents optimize for "do more"

Most subagents are designed to be helpful, which often translates to "do everything you can think of." This is a terrible default when you have:

- Expensive tools (search, web, code execution)
- Long-running tasks with branching paths
- Latency-sensitive workflows

In practice, my failure patterns look like this:

- A subagent shares a brief plan of what they'll do
- It then calls tools in a loop because it isn't sure
- Errors are returned, but with no guidance to recover
- Each error triggers more tool calls
- Eventually the agent locks into a local loop and burns tokens

In my case, giving `claude-haiku-4-5-20251001` 5 unoptimized tools and a step budget of 150 meant that it'd constantly churn through steps, calling tools repeatedly without clear progress, often spiraling into loops until the entire budget was exhausted.

We needed a way to apply pressure back onto the subagent so it would only spend what it could justify.

## Lever 1: Curate the Tool Belt

First, I treated tool calls like a scarce resource. If the agent calls a tool, it needs to be worth it.

### Strategy

- **Plan before calling tools.** Require a short plan (2-4 steps) and a clear success criterion.
- **Cache obvious queries.** If the same search/file/config exists, reuse the result. 
    - Note: this doesn't necessarily mean "use Redis"; it simply means scaffolding the agent's trajectory based on patterns that already work/ have been observed. 

I saw tool call counts drop by 50-80% depending on task. But the bigger effect was *behavioral*: the agent stopped fishing and started reasoning.

## Lever 2: Enrich their Error Logs

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

## Lever 3: Minimize total step budget

Even with fewer tool calls and better errors, subagents still drift when tasks take too many steps. The longer the chain, the higher the chance of drifting off the original goal. Typically if your step budget exceeds 20-30 for a mid-complex task like web scraping, you'll know there's space for optimization.

### What this looks like

- **Set a step budget.** Hard limit for tool calls or reasoning steps per task.
- **Early exit when confidence is high.** If confidence crosses a threshold, stop. This has to be encoded in your tool calls
- **Escalate to human or parent agent.** When the budget is hit, return a partial result and ask for guidance. This can be as simple as ensuring your schemas encode partial success and saving the entire agent trace.

### The Art & Science

Any effective subagent needs to really know their problem (and decision) space, as exemplified by the existence of web search & agentic search (RAG, BM25) tools. At the same time, maximizing your intelligence per token (i.e. Token Factor Productivity) is important too. Setting constraints upfront really forces you to think through what steps you'll take to keep your agent directed and token-efficient -- a key factor that separates toy projects from production tooling.

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
- Cap step budget to prevent runaway loops
- Backpressure is a policy, not a prompt

## Start Today

If you run subagents in production, add a tool call budget and a single-line recovery hint to errors. You'll feel the improvement immediately.

Backpressure is the simplest way I've found to make subagents behave like senior engineers instead of infinite interns.

---

--8<-- "snippets/cta.md"
