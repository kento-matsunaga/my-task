#!/bin/bash
set -euo pipefail

SKILL_NAME="neta-trend-daily"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="${SCRIPT_DIR}/.claude/skills/${SKILL_NAME}"
SKILL_DST="${HOME}/.claude/skills/${SKILL_NAME}"

echo "=== ${SKILL_NAME} installer ==="
echo ""

# Check source exists
if [ ! -d "${SKILL_SRC}" ]; then
  echo "ERROR: Skill source not found at ${SKILL_SRC}"
  exit 1
fi

# Create ~/.claude/skills/ if needed
mkdir -p "${HOME}/.claude/skills"

# Handle existing symlink or directory
if [ -L "${SKILL_DST}" ]; then
  echo "Removing existing symlink: ${SKILL_DST}"
  rm "${SKILL_DST}"
elif [ -d "${SKILL_DST}" ]; then
  echo "WARNING: ${SKILL_DST} exists as a directory."
  echo "Remove it manually if you want to proceed."
  exit 1
fi

# Create symlink
ln -s "${SKILL_SRC}" "${SKILL_DST}"
echo "Symlink created:"
echo "  ${SKILL_DST} -> ${SKILL_SRC}"

# Create .daily output directory
mkdir -p "${HOME}/.claude/.daily"
echo "Output directory ready: ~/.claude/.daily/"

echo ""
echo "Done! You can now use /neta-trend-daily from any project."
