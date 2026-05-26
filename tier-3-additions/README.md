# Tier-3 additions

Files to add when going from tier-2 (private tool) to tier-3 (open source).

## When to upgrade to tier-3

- You make the repo public on GitHub
- You accept external contributions
- The project becomes citable (academic context)
- You publish to a package registry (PyPI, npm, etc.)

## Files to copy

Copy these from `tier-3-additions/` into the root of your project :

| File | Purpose |
|---|---|
| `CODE_OF_CONDUCT.md` | Required for public repos. Contributor Covenant template. |
| `SECURITY.md` | How to report vulnerabilities privately. |
| `CODEOWNERS` | Auto-assign reviewers. (Place in `.github/` or root.) |
| `CITATION.cff` | Required for academic projects so users can cite. |

## Also recommended for tier-3

- **GitHub issue templates** : `.github/ISSUE_TEMPLATE/bug_report.md`,
  `feature_request.md`. Pre-fill the structure you want.
- **GitHub PR template** : `.github/PULL_REQUEST_TEMPLATE.md`
- **Funding** : `.github/FUNDING.yml` if you accept sponsorships
- **Release process** : document in CONTRIBUTING.md
- **Package publishing** : workflow for PyPI / npm releases on tag

See [PATTERNS.md § Tier-3 additions](../PATTERNS.md#tier-3-additions-open-source-projects)
for the full discussion.
