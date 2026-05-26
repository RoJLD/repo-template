# Examples

Canonical example configurations + datasets for `{{PROJECT_NAME}}`.

Each example is :
- Self-contained (no external data dependencies)
- Reproducible (fixed seeds where applicable)
- Small (< 1 MB) so the repo stays lightweight

## Structure

```
examples/
├── README.md
├── basic/                # 30-second tour
│   ├── config.yaml
│   └── data.csv
└── advanced/             # Real use case demo
    ├── config.yaml
    └── ...
```

## Usage

```bash
{{PROJECT_NAME}}-cli run examples/basic/config.yaml examples/basic/data.csv
```

(Adapt to your project's CLI / API.)
