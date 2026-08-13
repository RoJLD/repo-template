# repo-template — Composable Bootstrap

This folder is the **composable repo bootstrap kit** (tiers + addons +
recipes) used to scaffold new projects under `C:\Users\rdenis\VScode\`.
See `BOOTSTRAP.md` and `PATTERNS.md` for the user-facing design; this
file is for the agent working on the kit itself.

The general workspace rules in `../CLAUDE.md` apply. The rules below
are repo-template-specific.

## Commit identity (mandatory)

**All commits in this repo MUST use the GitHub identity**, not the Alten
work email:

| Field | Value |
|---|---|
| `user.email` | `roblastar@live.fr` |
| `user.name` | `Robin DENIS` |

Sanity-check before committing:
```bash
git config user.email   # → roblastar@live.fr
git var GIT_AUTHOR_IDENT  # confirm full identity git would use
```

## Specs discipline (repo-template-specific)

The workspace-level `Specs discipline` rule applies here — read it
first (`../CLAUDE.md`). For repo-template specifically:

- Specs live in `docs/superpowers/specs/`, plans in
  `docs/superpowers/plans/`. Create those directories on first use.
- **Every new addon, recipe, or tier change MUST start with a spec.**
  Because repo-template is consumed by many downstream projects, the
  *why-this-shape* reasoning is load-bearing — write it down before
  cutting the addon.
- Spec filename: `docs/superpowers/specs/YYYY-MM-DD-<slug>.md` (e.g.
  `2026-05-26-addon-code-intel.md`).
- When an addon or recipe changes shape (new option, removed option,
  renamed file), **update the spec in the same commit as the change**.
  Downstream projects rely on the spec to understand contracts.
- Never delete specs. Append-only history. For genuine redesigns, write
  a successor spec with a `Supersedes:` link to the original.

## What lives where

```
repo-template/
├── BOOTSTRAP.md           User-facing bootstrap guide
├── PATTERNS.md            Composition patterns (tiers/addons/recipes)
├── bootstrap.ps1          Main bootstrap entry-point
├── add-addon.ps1          Add an addon to an existing project
├── validate.ps1           Validate a scaffolded project
├── template/              Tier-0 base templates
├── tier-3-additions/      Tier-3 layer (gitnexus-integrated)
├── addons/                Optional cross-cutting features (code-intel, …)
├── recipes/               Pre-baked tier+addon combinations
└── CLAUDE.md              ← this file
```

## When you ship a feature here

Workspace-level rules apply (`../CLAUDE.md` "Feature changelog
discipline"). For repo-template specifically:

1. **Write/update the spec first** (see Specs discipline above).
2. **Update `PATTERNS.md`** if the change affects composition rules.
3. **Update `BOOTSTRAP.md`** if the change affects user-facing flow.
4. **Run `./validate.ps1`** on a freshly scaffolded project before
   declaring done.
5. **Note downstream impact**: if the change is breaking, list which
   existing projects (gitnexus, plane, hmm_studio, Experiment.Crypto.*)
   need a re-bootstrap.
