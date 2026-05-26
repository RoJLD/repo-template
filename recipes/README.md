# Recipes — named pack combinations

Pre-defined combinations of `tier` + `addons` that match common project
profiles. Saves you from remembering each addon manually.

## Available recipes

| Recipe | Tier | Addons | Real-world match |
|---|---|---|---|
| `prototype` | 1 | — | One-shot scripts, < 1 week lifespan |
| `private-tool` | 2 | — | Robin's default for new projects |
| `ai-pair-programming` | 2 | `code-intel`, `devcontainer` | Solo project optimized for Claude pair-programming |
| `ml-research` | 2 | `ml`, `academic`, `code-intel` | hmm_studio core, crypto experiments |
| `web-service` | 2 | `web`, `devcontainer` | API / dashboard, collaborator-friendly |
| `oss-library` | 3 | `supply-chain` | Public Python package on PyPI |
| `academic-library` | 3 | `academic`, `supply-chain` | Citable Python package + docs site |
| `full-stack-research` | 3 | `ml`, `academic`, `web`, `devcontainer`, `supply-chain`, `code-intel` | hmm_studio profile (the magnum opus) |
| `cloud-deployment` | 2 | `web`, `devcontainer`, `infra`, `supply-chain` | Deployed service with IaC |

## Usage

```powershell
.\bootstrap.ps1 -Name "my-proj" -Title "My Proj" -Description "X." -Recipe ml-research
```

The recipe expands to `-Tier` and `-Addons` automatically.

## When to add a new recipe

If you've used the same combination of addons three times → add a recipe.
The bootstrap script auto-discovers `recipes/*.json`, no code change needed.

## When NOT to use a recipe

Don't force-fit a project to a recipe. If your project is 80% match,
take the closest recipe and add the missing addon via `-Addons` on top
(currently you have to write the full list out — TODO : implement
`-Addons +foo,-bar` delta syntax).

## Recipe format

JSON files describing the combination :

```json
{
  "name": "ai-pair-programming",
  "description": "Solo project optimized for Claude / Cursor pair-programming",
  "tier": 2,
  "addons": ["code-intel", "devcontainer"],
  "example_projects": ["any Robin project where Claude is daily co-pilot"]
}
```

The bootstrap script reads the JSON and applies the corresponding flags.
