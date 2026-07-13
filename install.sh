#!/bin/bash
# Installs the pr-review skill to ~/.claude/commands/pr-review.md
# Usage: ./install.sh

DEST="$HOME/.claude/commands/pr-review.md"

cp skill.md "$DEST"
echo "Installed to $DEST"
