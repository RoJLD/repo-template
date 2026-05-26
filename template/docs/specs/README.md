# Specs

Detailed implementation plans for phases requiring > 1 day of work.
Smaller features don't need a spec ; just write the code and update
CHANGELOG.

## Naming

Specs are dated and phase-prefixed :

```
docs/specs/YYYY-MM-DD-phase-X-name.md
```

Examples :
- `2026-05-22-phase-a10-gmm-nhmm.md`
- `2026-05-26-phase-i-integrations.md`

The date is the spec creation date (NOT the ship date — that goes in
CHANGELOG).

## Structure

Use [`_template.md`](_template.md) as the starting point. The structure
covers : context, state of the art, architecture, math/API contract,
tests, definition of done, out-of-scope.

## Why specs are separate from ADRs

- **ADRs** = architectural decisions (the *why*)
- **Specs** = implementation plans (the *how* and *what*)
- **Roadmap** = strategic overview (the *when* and *priority*)
- **CHANGELOG** = what shipped (the *history*)

Specs link to ADRs they implement and to the roadmap phase they fulfill.
