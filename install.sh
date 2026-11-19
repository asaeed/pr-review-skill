#!/bin/bash
# Installs the pr-review skill into one agent profile.
# Usage: ./install.sh <claude-work|claude-personal|codex-work|codex-personal>
set -euo pipefail
cd "$(dirname "$0")"

case "${1:-}" in
  claude-work)     DEST="$HOME/.claude-work/commands/pr-review.md" ;;
  claude-personal) DEST="$HOME/.claude/commands/pr-review.md" ;;
  codex-work)      DEST="$HOME/.codex-work/skills/pr-review/SKILL.md" ;;
  codex-personal)  DEST="$HOME/.codex/skills/pr-review/SKILL.md" ;;
  *) echo "Usage: $0 <claude-work|claude-personal|codex-work|codex-personal>" >&2; exit 2 ;;
esac

mkdir -p "$(dirname "$DEST")"
cp skill.md "$DEST"
echo "Installed to $DEST"
