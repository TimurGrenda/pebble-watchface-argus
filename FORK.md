# Fork notes

This is a personal fork of
[filcuk/pebble-watchface-argus](https://github.com/filcuk/pebble-watchface-argus)
carrying a small stack of local changes on top of upstream.

## Branches

| Branch   | Contents                                                     | Rules                                 |
|----------|--------------------------------------------------------------|---------------------------------------|
| `main`   | Exact mirror of `upstream/main`                              | Fast-forward only. Never commit here. |
| `custom` | `upstream/main` + the fork's commits (this file included)    | Rebased onto upstream; force-pushed.  |

Build and install from `custom`. The fork's changes are always exactly
`git log upstream/main..custom`, one commit per change, so each one can be
dropped, reworded or sent upstream as a PR on its own.

## Local changes

| Commit subject                                   | What / why                                                                                                                                                                  |
|--------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Add fork notes and upstream sync script`        | This file, `CLAUDE.md` and `scripts/sync-upstream.sh`.                                                                                                                      |
| `Add light colour theme`                         | All watch-side colours go through `src/c/theme.h`. `ARGUS_LIGHT_THEME` (default `1`) selects black-on-white; set it to `0` (in `theme.h` or `-DARGUS_LIGHT_THEME=0`) for the original dark theme. |
| `Bump @rebble/clay to ^1.1.0`                    | Newer Clay.                                                                                                                                                                 |
| `Add launcher menu icon`                         | 25×25 black-on-white `resources/images/menu_icon.png`, declared with `menuIcon: true` in `package.json`.                                                                    |

Keep this table up to date when adding or dropping a fork commit.

When upstream adds new drawing code, check it for hard-coded `GColorWhite`/
`GColorBlack`/accent colours and route them through `THEME_*` in a follow-up
fork commit; otherwise they will be invisible on the light background.

## Updating from upstream

```bash
git remote add upstream https://github.com/filcuk/pebble-watchface-argus.git   # once per clone
scripts/sync-upstream.sh            # fetch, fast-forward main, rebase custom
# build + test (see DEVELOPMENT.md), then:
git push origin main
git push --force-with-lease origin custom
```

`scripts/sync-upstream.sh --push` does the two pushes itself. The script
saves the pre-rebase stack as a local `backup/custom-<timestamp>` branch and
enables `git rerere`, so a conflict resolved once is replayed automatically
on later rebases in the same clone.

On a conflict: resolve, `git add`, `git rebase --continue`. If upstream has
adopted or superseded a fork change, `git rebase --skip` that commit and
remove it from the table above.

## Adding a new local change

```bash
git checkout custom
# edit, build, test
git commit          # one logical change per commit
git push origin custom
```

To amend an existing fork commit instead of stacking a fix on top, use
`git commit --fixup=<sha>` followed by `git rebase --autosquash upstream/main`.

## Releases

Tag builds you install as `<upstream-version>-custom.<n>`, e.g.
`v1.3.1-custom.1`, so an older patched build can be rebuilt after later
rebases rewrite `custom`.
