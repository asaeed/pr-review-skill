# PR Review

Review a GitHub pull request, present findings for user selection, then post the selected ones as inline comments on the PR diff and submit the review.

## Inputs

The user will provide either a PR number or a full PR URL (e.g. `https://github.com/org/repo/pull/54`). Parse `org/repo` and PR number from the URL.

If no PR is specified, ask the user which one to review before doing anything else.

## Step 1 — Check GitHub MCP availability

Prefer the GitHub MCP plugin for everything. The tools you need are:
- `mcp__plugin_github_github__pull_request_read` — PR metadata + diff
- `mcp__plugin_github_github__get_file_contents` — file contents at a specific SHA
- `mcp__plugin_github_github__pull_request_review_write` — post a review with inline comments

Before doing any review work, verify these tools are available. If they aren't connected or authorized, **stop and tell the user**:

> GitHub MCP isn't available in this session. Please connect/authorize it and retry — I won't silently fall back to `gh` CLI.

Do not proceed with `gh` CLI unless the user explicitly asks you to.

## Step 2 — Fetch PR data

1. Get PR metadata including `headRefOid` (the head commit SHA) and the list of changed files.
2. Get the diff.
3. For each changed file, fetch its contents at `headRefOid` so you have the exact line numbers in the current PR state. **Do not estimate line numbers from diff hunk headers** — always read the actual file.

## Step 3 — Priority list (tweakable)

Analyze the PR through these priorities, in order. Higher items dominate lower ones.

1. **Correctness bugs** — data loss, corruption, incorrect results, off-by-one, wrong SQL/query, logic errors
2. **Security** — injection, secrets in code, auth bypass, unsafe deserialization, SSRF
3. **Safety of external inputs** — unvalidated env vars, unchecked user input, unsafe type casts (`as Foo` on unknown strings)
4. **Silent failures** — discarded return values, swallowed errors, empty catch blocks, fire-and-forget async
5. **Behavior changes to production paths** — removed guards, changed defaults, altered retry/timeout semantics
6. **Concurrency & state** — race conditions, missing transactions, shared mutable state
7. **Resource management** — leaks, unbounded growth, missing cleanup
8. **Test coverage** — new behavior without tests, deleted tests, tests that don't test the change
9. **Performance** — O(n²) where O(n) fits, N+1 queries, redundant work in hot paths
10. **Readability / style** — naming, comments, structure (lowest — only call out if it impedes review)

Present this priority list to the user with the findings, and ask if they'd like to adjust it before you analyze. If they tweak it, re-analyze with the new priorities.

## Step 4 — Present findings

Format each finding as:

```
### N. <Short title>

**Details:** <1–3 sentences on the problem and why it matters. Be concrete.>

**Link:** https://github.com/<org>/<repo>/blob/<headSHA>/<path>#L<line>[-L<endLine>]
```

Where `<line>` is the exact line in the file at `headSHA`. Use `#L42-L48` for ranges.

After the numbered list, include the priority list you used (so the user can tweak it):

```
---

**Priorities applied:**
1. Correctness bugs
2. Security
3. ...

Reply with the issue numbers to post (e.g. `1, 3, 5`), or ask me to tweak priorities and re-analyze.
```

## Step 5 — Post selected comments inline on the diff

When the user provides issue numbers, post them as **inline review comments on the PR diff** — not as general PR comments. Combine them into a single review.

### GitHub's diff-line constraint

GitHub only allows inline comments on lines that are visible in the PR diff (added lines or context lines inside a diff hunk). If you try to comment on a line outside the diff, the API returns `422 "Line could not be resolved"`.

**If the most relevant line for a finding is not in the diff:**
- Pick the nearest changed line in the same hunk (or the nearest diff-visible context line).
- In the comment body, reference the actual line: `The real issue is at file.ts:78 (outside this hunk) — ...`

Never silently drop a finding because its line isn't in the diff. Always post; adjust the anchor line and note it in the body.

### Posting the review

Use `mcp__plugin_github_github__pull_request_review_write` with:
- `event`: `COMMENT` (not `APPROVE` or `REQUEST_CHANGES` unless the user explicitly asked)
- `commitId`: the `headRefOid` from Step 2
- `comments[]`: one entry per selected finding, each with `path`, `line`, `side: "RIGHT"`, and `body`
- **No top-level `body`** — the user does not want a general summary comment on the PR, only the inline ones

Post exactly one review containing all the selected inline comments. Do not submit separate reviews per comment, and do not add a general comment to the PR conversation.

### Handling posting failures

If the API returns `422 "Line could not be resolved"`, the line isn't in the diff. Re-pick a diff-visible anchor in the same hunk, update the comment body to reference the real line, and retry. Never give up silently.

## Step 6 — Confirm

After the review is posted, tell the user:
- How many comments were posted
- The URL of the review (from the API response's `html_url`)

## Quick reference

| Step | Action |
|------|--------|
| 1 | Check GitHub MCP is available; stop if not |
| 2 | Fetch PR metadata, diff, and each changed file's contents at head SHA |
| 3 | Analyze against priority list (tweakable) |
| 4 | Present numbered findings with clickable `blob/<sha>/path#Lline` links |
| 5 | On user selection, post one review with inline diff comments (no general body) |
| 6 | Confirm with count and review URL |

## Common mistakes

- **Estimating line numbers from diff hunks.** Always read the file at `headSHA`.
- **Falling back to `gh` CLI silently** when GitHub MCP isn't connected. Tell the user first.
- **Adding a top-level review body.** The user wants only inline comments, no general summary.
- **Dropping a finding because its line isn't in the diff.** Anchor to a nearby diff-visible line and reference the real line in the body.
- **Submitting multiple reviews** for the same batch. Use one review with all selected comments.
