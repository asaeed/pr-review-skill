# PR Review Skill

A Claude Code / Codex skill for reviewing GitHub pull requests with inline comments on the diff.

## What It Does

- Fetches PR metadata and file contents at the head SHA (so line numbers are accurate)
- Analyzes the PR against a tweakable priority list (correctness → security → … → style)
- Presents findings as a numbered list with titles, details, and clickable links to exact lines
- On user selection, posts the chosen findings as **inline comments on the PR diff** (not general PR comments) in a single review

## Installation

```bash
./install.sh <profile>
```

`<profile>` picks the agent profile to install into:

| profile | destination |
|---|---|
| `claude-work` | `~/.claude-work/commands/pr-review.md` |
| `claude-personal` | `~/.claude/commands/pr-review.md` |
| `codex-work` | `~/.codex-work/skills/pr-review/SKILL.md` |
| `codex-personal` | `~/.codex/skills/pr-review/SKILL.md` |

## Prerequisites

The `gh` CLI, logged in (`gh auth status`). The skill reads the PR with `gh pr view` / `gh pr diff` / `gh api .../contents`, and posts the review with `gh api .../pulls/<n>/reviews`. If `gh` isn't logged in, it stops and asks you to run `gh auth login`.

## Usage

```
/pr-review <PR URL or number>
```

Example:

```
/pr-review https://github.com/org/repo/pull/54
```

The skill will:
1. Fetch PR data
2. Present a numbered list of findings + the priority list it used
3. Let you reply with the issue numbers to post (e.g. `1, 3, 5`) — or ask for priority tweaks
4. Post the selected findings as inline diff comments in one review
