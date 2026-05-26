# Architecture Decision Records

Numbered records of architecturally significant decisions, with the
*why* explicit so future contributors (and future-you) don't re-debate.

## Format

Each ADR is `NNNN-name-of-decision.md`, numbered sequentially.

The structure of each ADR is defined in [`_template.md`](_template.md).

## Index

- [0001 — (the first decision)](0001-first-decision.md) — TODO : write this

## When to write an ADR

A decision deserves an ADR when :
- It would take > 30 minutes to re-debate six months later
- It commits the project to a stack / format / dependency
- It defines a boundary (e.g. "we don't do X")
- It supersedes an earlier decision

A decision does NOT deserve an ADR when :
- It's a routine implementation choice
- It's reversible at near-zero cost
- It's already captured in a spec or the code itself

## Lifecycle

1. **DRAFT** : sketch in `notes/decisions.md` first (private working area)
2. **ACCEPTED** : promoted to `docs/decisions/NNNN-name.md`
3. **SUPERSEDED-BY-NNNN** : when revisited, mark old ADR with this status
   and link to the new one (don't delete the old one)
