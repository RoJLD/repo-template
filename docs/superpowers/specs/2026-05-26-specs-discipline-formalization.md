# 2026-05-26 — Formalize specs discipline in repo-template

**Status** : current
**Author** : Robin DENIS
**Effort estimate** : ~0.5 day
**Prerequisites** : workspace `CLAUDE.md` "Specs discipline" section
(committed 2026-05-26).

## 1. Context

The workspace-level `CLAUDE.md` (at `c:\Users\rdenis\VScode\CLAUDE.md`)
now mandates a **Specs discipline**: before invoking
`superpowers:writing-plans` on any non-trivial change, write or update a
dated spec under `docs/superpowers/specs/`, never delete it, and keep
it in lockstep with the code.

repo-template is the canonical bootstrap kit for every project under
this workspace. Today it ships a `template/docs/specs/` directory with
a `README.md` and a `_template.md`, but those reflect the *old*,
softer pattern: "specs are optional for > 1-day phases, no
historicization rule, no maintenance contract". Bootstrapped projects
therefore inherit a half-formalized version of the rule that does not
match the workspace's new contract.

This spec formalizes the workspace rule **inside repo-template** so
that any new project bootstrapped from the template ships with the
discipline pre-wired (template content, agent contracts, `validate.ps1`
check), and so the repo-template repo itself follows the same rule for
its own design work.

## 2. Goal

A new project bootstrapped via `bootstrap.ps1` at tier-2 or tier-3
**inherits the full specs discipline by default**, with:

- A `docs/specs/` directory whose `README.md` describes the mandatory
  workflow (spec-before-plan, historicization, maintenance).
- A `_template.md` that produces specs with `Status`,
  `Supersedes` / `Superseded-by`, and `Update YYYY-MM-DD` sections
  baked in.
- `AGENTS.md` + `CLAUDE.md` referencing the discipline as a hard rule,
  not a soft "do" tip.
- A `validate.ps1` check (`RT028`) verifying the strengthened
  `README.md` is in place — so projects can audit "am I still
  contract-compliant?".
- `PATTERNS.md` updated so the existing "Spec dated and phase-prefixed"
  pattern reflects the mandatory + historicized version.

The repo-template repo itself also gains its own
`docs/superpowers/specs/` (this file) so it dogfoods the rule.

## 3. Design

### Path convention

| Context | Path |
|---|---|
| repo-template repo itself | `docs/superpowers/specs/` (workspace rule) |
| Projects bootstrapped from repo-template | `docs/specs/` (existing convention, unchanged) |

Why two paths: bootstrapped projects already have `docs/specs/` (the
template ships it), and changing the path on bootstrapped projects
would be a breaking change for downstream consumers. `docs/specs/`
remains the user-facing default in template-land. `docs/superpowers/`
is used inside repo-template itself because the workspace CLAUDE.md
calls it out explicitly for the four "in-workspace" projects, and
because plans live in `docs/superpowers/plans/` matching the
superpowers skill convention.

### Lifecycle

- **Tier 1** (prototype): `docs/specs/` is trimmed by bootstrap (no
  discipline). Workspace rule says one-shot tweaks don't need specs.
- **Tier 2+**: `docs/specs/` ships with strengthened `README.md` +
  `_template.md`. Spec is mandatory before any
  `superpowers:writing-plans` invocation on a multi-file change.

### What "strengthened" means concretely

`README.md` gains: mandatory-before-writing-plans clause; explicit
"never delete" historicization rule; "update in same commit as code"
maintenance rule; spec-vs-plan comparison; statuses
(`draft / current / superseded`).

`_template.md` gains: `Status:` line at top; `Supersedes:` /
`Superseded-by:` fields; a worked example of an `## Update
YYYY-MM-DD` amendment section at the bottom.

`AGENTS.md` gains: spec-before-plan moved from "Do's" to a `## Specs`
section with a hard rule.

`CLAUDE.md` gains: a "Specs discipline" section that defers to
`AGENTS.md` (single source of truth, per template convention).

`validate.ps1` gains: `RT028` check via a marker
(`Has-Marker "docs/specs/README.md" "mandatory before any plan"`) that
distinguishes the strengthened README from a stub.

### Alternatives considered

**A — Add a new opt-in `specs-discipline` addon.** Rejected: this is a
*discipline* pattern, not a *capability*. Per `PATTERNS.md` closing:
"Discipline scales with project lifespan ; capabilities scale with
project domain." Discipline belongs in the tier, not in an opt-in
addon.

**B — Move `docs/specs/` to `docs/superpowers/specs/` in template/**
to match the workspace path exactly. Rejected: would be a breaking
change for downstream projects already using `docs/specs/`, and the
path mismatch is contained (only the repo-template repo itself uses
the `superpowers/` prefix).

**C — Strengthen `README.md` only.** Rejected: the agent contract
(`AGENTS.md`) is what drives behavior at session start. Without
updating it, the README is a wall poster nobody reads.

## 4. Scope boundaries

- **In scope**: `template/docs/specs/{README,_template}.md`,
  `template/AGENTS.md`, `template/CLAUDE.md`, `PATTERNS.md`,
  `validate.ps1` (RT028 only), and repo-template's own
  `CLAUDE.md` + `docs/superpowers/specs/`.
- **Out of scope**: existing bootstrapped projects (gitnexus, plane,
  hmm_studio, Experiment.Crypto.*) — they already received their own
  spec-discipline section in their CLAUDE.md in the previous turn.
- **Out of scope**: a new `specs-discipline` addon (see alt A).
- **Out of scope**: tier-1 changes — prototypes deliberately skip
  this discipline.

## 5. Definition of "done"

- [ ] `template/docs/specs/README.md` rewritten with mandatory +
      historicized rules.
- [ ] `template/docs/specs/_template.md` extended with `Status`,
      `Supersedes`, `Update` sections.
- [ ] `template/AGENTS.md` has a `## Specs` section with the hard
      rule.
- [ ] `template/CLAUDE.md` references the specs discipline via
      AGENTS.md.
- [ ] `PATTERNS.md` "Pattern : Spec dated and phase-prefixed" updated
      to the mandatory + historicized version.
- [ ] `validate.ps1` has check `RT028` for the strengthened README.
- [ ] repo-template's own `CLAUDE.md` already wired (done in previous
      turn).
- [ ] This spec landed under `docs/superpowers/specs/`.

## 6. Out-of-scope (anti-scope-creep)

- No new addon directory (see alt A).
- No path migration for existing bootstrapped projects.
- No retroactive backfill of specs for past features in
  bootstrapped projects.
- No automated CI enforcement beyond the `validate.ps1` check.
