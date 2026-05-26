# {{PROJECT_TITLE}} — Roadmap

**Date** : {{YEAR}}-MM-DD
**Author** : {{AUTHOR_NAME}}
**Last updated** : {{YEAR}}-MM-DD

> Living strategic document. Re-edit at every phase transition. NOT a
> spec ; specs live in `docs/specs/`. NOT a changelog ; that lives in
> `CHANGELOG.md`. This is the strategic overview.

## Vision

(One paragraph : who is this for, what does it do, what is the unique
value proposition. Resist the urge to make it generic — be specific
about the niche / wedge.)

## Positioning

### The wedge

(What specifically are we good at that no one else does well ? What is
the moat ?)

### What we are NOT

(Be explicit. List the temptations to avoid. Examples : "we are not a
generic ML platform", "we don't compete with X", "we stay local-first".)

### Strategic test for new features

For any proposed feature, ask : "Does this serve our wedge, or does it
make us look like our competitors ?" If the latter, refuse.

## Overview — where we are

```
Phase    Description                      Status         Depends on    Effort
─────────────────────────────────────────────────────────────────────────────
   A     Core engine / library            PLANNED        —             ~X days
   B     UI / web layer (if any)          NOT STARTED    A             ~Y days
   V     Validation suite                 NOT STARTED    A             ~Z days
   Z.1   CI + pre-commit                  PLANNED        —             ~1 day
   Z.5   License + CITATION (if academic) NOT STARTED    —             ~1 hour
```

Status values : `NOT STARTED` / `SPEC DRAFTED` / `PLANNED` / `IN PROGRESS` /
`SHIPPED` / `DEFERRED` / `GATED`.

## Phase A — Core

**Status** : PLANNED
**Depends on** : —
**Estimated effort** : (~ X days)

### What ships
(Concrete deliverables)

### Definition of "done"
- [ ] Item 1
- [ ] Item 2

## Phase B — UI (or whatever B is)

(If applicable.)

## Phase V — Validation

(If scientific / numerical correctness matters.)

## Phase Z — Cross-cutting

### Z.1 — CI + pre-commit
### Z.2 — Documentation site
### Z.5 — License + CITATION.cff

## Decisions open to arbitrate

List unresolved strategic choices. Each gets an ADR when decided.

1. (Example) Which database backend ?
2. (Example) Self-host vs SaaS ?

## Out-of-scope appendix

> Things we deliberately do NOT do. Keep this list updated — it's the
> anti-scope-creep tool.

| Item | Why not | Reconsider if |
|---|---|---|
| (example) GraphQL API | REST is simpler for our use case | We get > 50 users with complex query needs |
| (example) Mobile app | Web is enough for the niche | Demand from > 3 users for mobile-specific features |

## Sources / inspiration

- Inherited from `repo-template` ({{YEAR}}-MM-DD bootstrap)
- (Add references to similar projects, papers, blog posts that informed
  the strategic choices)
