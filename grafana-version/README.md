# Grafana monitoring variant

This folder is an **alternate packaging** of the Lemonade Stand Assistant that uses **Grafana** for guardrail metrics instead of the default **R Shiny** dashboard in the main chart.

It is **not** related to the multi-language demo variants under `../alternatives/` (café, mate, piscola, cachaça, etc.).

## What is included

- `chart/` – Helm chart for the lemonade assistant (Grafana-era layout)
- `grafana/` – Grafana Operator + dashboard Helm chart
- `lemonade-stand-app/` – FastAPI chat app snapshot used with this variant
- `docs/` – architecture and Grafana dashboard screenshots

Source lineage: originally based on [eformat/lemonade-stand-assistant](https://github.com/eformat/lemonade-stand-assistant).

## When to use this

Use this if you prefer Grafana / OpenShift monitoring (Prometheus/Thanos) and can install the Grafana Operator (often needs elevated privileges).

For the default experience in this repo, use the main chart + Shiny dashboard:

```bash
./scripts/deploy.sh lemonade
```

## Deploy Grafana dashboard (this variant)

```bash
NAMESPACE="lemonade-stand-assistant"
helm install lemonade-grafana ./grafana --namespace ${NAMESPACE}
```

See `grafana/README.md` for details.
