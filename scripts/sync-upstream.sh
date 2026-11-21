#!/usr/bin/env bash
# Rebase this fork's patch branch onto the latest upstream. See FORK.md.
#
#   scripts/sync-upstream.sh          # fetch, update mirror, rebase, (no push)
#   scripts/sync-upstream.sh --push   # ...and push mirror + patch branch
#
# Overridable: UPSTREAM_URL, UPSTREAM_BRANCH, PATCH_BRANCH.
set -euo pipefail

UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/filcuk/pebble-watchface-argus.git}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-main}"     # also the fork's pristine mirror branch
PATCH_BRANCH="${PATCH_BRANCH:-custom}"
PUSH=0
[[ "${1:-}" == "--push" ]] && PUSH=1

cd "$(git rev-parse --show-toplevel)"

if [[ -n "$(git status --porcelain --untracked-files=no)" ]]; then
  echo "error: working tree has uncommitted changes; commit or stash first" >&2
  exit 1
fi

git remote get-url upstream >/dev/null 2>&1 || git remote add upstream "$UPSTREAM_URL"
# Remember conflict resolutions so the next rebase replays them automatically.
git config rerere.enabled true
git config rerere.autoupdate true

git fetch upstream --tags
git fetch origin

# 1. Fast-forward the pristine mirror branch. It must never carry fork commits.
git checkout -q "$UPSTREAM_BRANCH"
git merge --ff-only "upstream/$UPSTREAM_BRANCH"

# 2. Back up the current patch stack, then rebase it onto the new upstream.
git checkout -q "$PATCH_BRANCH"
backup="backup/$PATCH_BRANCH-$(date +%Y%m%d-%H%M%S)"
git branch "$backup"
echo "Patch stack before rebase saved as local branch: $backup"
echo "Fork commits being replayed:"
git log --oneline "upstream/$UPSTREAM_BRANCH..$PATCH_BRANCH"

if ! git rebase "upstream/$UPSTREAM_BRANCH"; then
  cat >&2 <<EOF

Rebase stopped on a conflict. Resolve it, then:
  git add <files> && git rebase --continue
If a fork commit is now obsolete (upstream adopted it): git rebase --skip
To give up and restore the old stack:  git rebase --abort
Afterwards re-run with --push, or push manually (see FORK.md).
EOF
  exit 1
fi

echo
echo "Rebased. Fork commits now on top of upstream/$UPSTREAM_BRANCH:"
git log --oneline "upstream/$UPSTREAM_BRANCH..$PATCH_BRANCH"
echo
echo "Review the diff against upstream with:"
echo "  git diff upstream/$UPSTREAM_BRANCH..$PATCH_BRANCH"

if (( PUSH )); then
  git push origin "$UPSTREAM_BRANCH"
  git push --force-with-lease origin "$PATCH_BRANCH"
else
  echo
  echo "Not pushed. Build/test, then:"
  echo "  git push origin $UPSTREAM_BRANCH"
  echo "  git push --force-with-lease origin $PATCH_BRANCH"
fi
