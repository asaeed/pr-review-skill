# PR Review Skill

A Claude Code skill for reviewing GitHub pull requests with inline comments on the diff.

## What It Does

- Fetches PR metadata and file contents at the head SHA (so line numbers are accurate)
- Analyzes the PR against a tweakable priority list (correctness → security → … → style)
- Presents findings as a numbered list with titles, details, and clickable links to exact lines
- On user selection, posts the chosen findings as **inline comments on the PR diff** (not general PR comments) in a single review

## Installation

```bash
./install.sh
```

Installs to `~/.claude/commands/pr-review.md`.

## Prerequisites

GitHub MCP plugin must be connected and authorized. The skill uses:
- `mcp__plugin_github_github__pull_request_read`
- `mcp__plugin_github_github__get_file_contents`
- `mcp__plugin_github_github__pull_request_review_write`

If the MCP isn't available, the skill stops and asks you to connect it — it won't silently fall back to `gh` CLI.

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
