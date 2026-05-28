# Contributing to claude-vibes

Thanks for chipping in! The contribution loop here is short.

## Pull-request workflow

1. Branch from `main`. Make your change.
2. Open a PR with a **Conventional Commits**–formatted title (see below).
3. We use **squash merge only**. The PR **title** becomes the single commit subject on `main`; the PR **body** becomes the commit body.

GitHub is configured to delete the head branch on merge, so you don't need to clean up your feature branch by hand.

## Conventional Commits

The PR title prefix decides whether (and how) `release-please` cuts the next release:

| Prefix | Effect on the next release |
|--------|----------------------------|
| `fix:` / `fix(scope):` | patch (`x.y.Z`) |
| `feat:` / `feat(scope):` | minor (`x.Y.0`) |
| `feat!:` / `<type>!:` or any `BREAKING CHANGE:` footer in the PR body | major (`X.0.0`) |
| `chore:`, `docs:`, `refactor:`, `test:`, `ci:`, `style:`, `perf:`, `build:` | no release |

The `release-please` config for this repo lives in [`release-please-config.json`](./release-please-config.json).

### ⚠️ Don't write conventional-commit markers in prose

`release-please` scans the **entire** squashed commit body, not just the subject line. If you write something like:

> Future contributors should use the bang-suffixed type for breaking work…

inside a PR body using the **literal** marker at line-start, `release-please` will treat it as a breaking-change marker and bump the major version unexpectedly. It happened once during the setup of this repo (see [PR #6](https://github.com/DeepVista-AI/claude-vibes/pull/6) and the subsequent fix).

**Rules of thumb when writing PR/commit prose:**

- Don't start a line with `<type>!:` (e.g. `feat!:`, `fix!:`) followed by descriptive text.
- Don't put the literal string `BREAKING CHANGE:` at the start of a line.
- If you need to refer to those markers in prose, wrap them in backticks and don't put them at line-start, or paraphrase ("the bang-suffixed type", "a breaking-change footer").

## Releasing

You don't release by hand. [release-please](https://github.com/googleapis/release-please) watches `main`:

1. Merge a `fix:` / `feat:` PR onto `main`.
2. `release-please` opens or updates a PR titled `chore(main): release X.Y.Z` that bumps every version field (in `.claude-plugin/plugin.json`, both spots in `.claude-plugin/marketplace.json`, and `.release-please-manifest.json`) and appends to `CHANGELOG.md`.
3. Merging that release PR cuts the `vX.Y.Z` git tag and a GitHub Release.
4. Users get the new version on their next `claude plugin update`.

To force a specific version on the next release, add a `Release-As: 1.2.3` footer to a PR body.

## Local development

```bash
git clone https://github.com/DeepVista-AI/claude-vibes
cd claude-vibes
# install locally for development (path source, not the marketplace):
claude plugin install ./
```

Edit hooks, scripts, commands, or sounds; reload Claude Code to pick up changes.

## Audio is macOS-only

The plugin uses `afplay` and `terminal-notifier` (optional). Linux/Windows contributions for portable audio are welcome — see the scripts in `scripts/` for the relevant hooks.
