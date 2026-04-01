#!/bin/bash
# Harness Engineering - Installer
# 3-Agent Pipeline Pattern for Claude Code
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/suhanlee/harness/main/install.sh | bash
#   or
#   ./install.sh [target-directory]

set -euo pipefail

TARGET_DIR="${1:-.}"
REPO_URL="https://raw.githubusercontent.com/suhanlee/harness/main"

echo "=== Harness Engineering Installer ==="
echo ""

# Ensure .claude directories exist
mkdir -p "${TARGET_DIR}/.claude/commands"
mkdir -p "${TARGET_DIR}/.claude/skills/harness-planner"
mkdir -p "${TARGET_DIR}/.claude/skills/harness-generator"
mkdir -p "${TARGET_DIR}/.claude/skills/harness-evaluator"

# Download files
echo "Downloading harness command..."
curl -fsSL "${REPO_URL}/.claude/commands/harness.md" \
  -o "${TARGET_DIR}/.claude/commands/harness.md"

echo "Downloading planner skill..."
curl -fsSL "${REPO_URL}/.claude/skills/harness-planner/SKILL.md" \
  -o "${TARGET_DIR}/.claude/skills/harness-planner/SKILL.md"

echo "Downloading generator skill..."
curl -fsSL "${REPO_URL}/.claude/skills/harness-generator/SKILL.md" \
  -o "${TARGET_DIR}/.claude/skills/harness-generator/SKILL.md"

echo "Downloading evaluator skill..."
curl -fsSL "${REPO_URL}/.claude/skills/harness-evaluator/SKILL.md" \
  -o "${TARGET_DIR}/.claude/skills/harness-evaluator/SKILL.md"

echo ""
echo "=== Installation complete ==="
echo ""
echo "Installed files:"
echo "  ${TARGET_DIR}/.claude/commands/harness.md"
echo "  ${TARGET_DIR}/.claude/skills/harness-planner/SKILL.md"
echo "  ${TARGET_DIR}/.claude/skills/harness-generator/SKILL.md"
echo "  ${TARGET_DIR}/.claude/skills/harness-evaluator/SKILL.md"
echo ""
echo "Usage: /harness [mission description]"
echo ""
echo "Optional: Add the harness engineering section to your CLAUDE.md"
echo "See: https://github.com/suhanlee/harness#add-to-claudemd-optional"
