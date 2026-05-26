# Phase X.Y — One-line spec title

**Date** : YYYY-MM-DD
**Author** : {{AUTHOR_NAME}}
**Status** : SPEC DRAFTED / IN PROGRESS / SHIPPED
**Effort estimate** : ~X days
**Prerequisites** : (other phases / ADRs that must ship first)

## 1. Context and motivation

Why does this phase exist ? What problem does it solve ? Who benefits ?

Reference the roadmap entry : `docs/roadmap.md § Phase X.Y`.

## 2. State of the art (if relevant)

Brief survey of existing solutions. Who else does this ? What do they
do well / badly ? Where's our wedge ?

Table format works well :

| Tool | Strengths | Weaknesses |
|---|---|---|
| Alternative A | ... | ... |
| Alternative B | ... | ... |

## 3. Architecture / strategies considered

If there are multiple ways to implement, list them and pick one with
justification.

### Strategy A (recommended)

Description.

### Strategy B (alternative)

Description. Why rejected (or kept as future option).

## 4. API surface / math / data contract

Be concrete. Show the public functions, classes, file formats.

```python
# Example public API
def fit(...) -> Result:
    ...
```

## 5. Limits and identifiability concerns

What configurations does this NOT handle ? What edge cases are
deliberately out of scope ?

## 6. Tests minimum

Named tests that must exist before this is considered shipped :

| Test name | What it verifies |
|---|---|
| `test_basic_fit` | The happy path works |
| `test_rejects_invalid_input` | Validation surfaces errors clearly |
| ... | ... |

## 7. Definition of "done"

- [ ] Public API implemented
- [ ] Tests pass (named above)
- [ ] CHANGELOG entry under `[Unreleased]`
- [ ] ADR written if architectural decision involved
- [ ] Documentation updated (README, roadmap)

## 8. Out-of-scope (anti-scope-creep)

Things this phase deliberately does NOT do. List them so future
sessions don't drift.

- (Example) No GPU acceleration
- (Example) No remote storage
- (Example) No multi-language interface

## 9. References

- ADR-NNNN — relevant decision
- Roadmap phase X.Y
- External papers / blog posts / similar projects
