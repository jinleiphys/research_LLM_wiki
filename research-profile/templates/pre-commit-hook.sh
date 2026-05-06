#!/usr/bin/env bash
#
# research-profile — pre-commit privacy guard
#
# Refuses to commit files that match private/embargoed patterns. Catches
# accidents the .gitignore alone cannot (e.g., `git add -f` of an ignored
# file, or files added before the gitignore rule existed).
#
# Install in your wiki repo:
#   cp templates/pre-commit-hook.sh <wiki>/.git/hooks/pre-commit
#   chmod +x <wiki>/.git/hooks/pre-commit
#
# Bypass once with: git commit --no-verify
# (Do this only when you have genuinely intended to commit a flagged file.
# Never bypass for sensitivity: embargoed pages.)

set -euo pipefail

# --- Pattern 1: filename matches *.private.md or *.local.md ---
mapfile -t private_files < <(
    git diff --cached --name-only --diff-filter=ACM \
    | grep -E '\.(private|local)\.md$' || true
)

if [[ ${#private_files[@]} -gt 0 ]]; then
    {
        echo "❌ research-profile pre-commit: refusing to commit private files."
        echo ""
        echo "These files match *.private.md or *.local.md, which are gitignored by"
        echo "default for a reason (incoming referee reports, drafts you don't want"
        echo "in history, etc.):"
        echo ""
        for f in "${private_files[@]}"; do echo "  $f"; done
        echo ""
        echo "If you truly want them tracked, rename to a non-private name AND"
        echo "remove the matching line from .gitignore. To bypass once: git commit --no-verify"
    } >&2
    exit 1
fi

# --- Pattern 2: file frontmatter contains `sensitivity: embargoed` ---
mapfile -t staged_md < <(
    git diff --cached --name-only --diff-filter=ACM \
    | grep -E '\.md$' || true
)

embargoed_files=()
for f in "${staged_md[@]}"; do
    if [[ -f "$f" ]] && head -n 30 "$f" 2>/dev/null \
        | grep -qE '^[[:space:]]*sensitivity:[[:space:]]*embargoed[[:space:]]*$'
    then
        embargoed_files+=("$f")
    fi
done

if [[ ${#embargoed_files[@]} -gt 0 ]]; then
    {
        echo "❌ research-profile pre-commit: refusing to commit embargoed files."
        echo ""
        echo "These files have 'sensitivity: embargoed' in their frontmatter:"
        echo ""
        for f in "${embargoed_files[@]}"; do echo "  $f"; done
        echo ""
        echo "Either remove the embargo (after the embargo period expires) by"
        echo "changing the frontmatter to 'sensitivity: private' or 'public',"
        echo "or move the content to a *.private.md file. Avoid --no-verify here."
    } >&2
    exit 1
fi

exit 0
