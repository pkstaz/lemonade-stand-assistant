# Alternative demos

Localized variants of the Lemonade Stand guardrails demo. The original English lemonade app remains at `../lemonade-stand-app/` and keeps its historical OpenShift names (`lemonade-stand-assistant` / `lemonade-stand`).

Source apps are grouped by language. Helm chart assets live under `../chart/files/` with the same layout.

Alternatives use a `lang-theme` variant id (`es-cafe`, `en-coffee`, …). Resource names follow the lemonade pattern:

| Variant id | Namespace / Helm release | App / Route |
|------------|--------------------------|-------------|
| `es-cafe` | `es-cafe-stand-assistant` | `es-cafe-stand` |
| `en-coffee` | `en-coffee-stand-assistant` | `en-coffee-stand` |
| … | `<variant>-stand-assistant` | `<variant>-stand` |

## Layout

```
alternatives/
  en/
    coffee/          # English coffee  -> en-coffee
  es/
    cafe/            # Spanish coffee (café) -> es-cafe
    mate/            # Spanish mate (Uruguay) -> es-mate
    piscola/         # Spanish piscola (Chile) -> es-piscola
    chicha/          # Spanish chicha morada (Perú) -> es-chicha
    ceviche/         # Spanish ceviche (Perú) -> es-ceviche
    tacos/           # Spanish tacos (México) -> es-tacos
    limonada/        # Spanish limonada -> es-limonada
    tequila/         # Spanish tequila (México) -> es-tequila
  pt/
    cafe/            # Portuguese coffee (café) -> pt-cafe
    cachaca/         # Portuguese cachaça -> pt-cachaca
    limonada/        # Portuguese limonada -> pt-limonada
    caipirinha/      # Portuguese caipirinha (Brasil) -> pt-caipirinha
```

## Deploy (Helm)

Install the original lemonade stack first (owns LLM + detectors + MinIO), then any alternative. Each alternative values file already sets `models.shared.enabled=true`.

```bash
# Original
helm upgrade --install lemonade-stand-assistant ./chart \
  --create-namespace -n lemonade-stand-assistant \
  -f chart/values-lemonade.yaml

# Wait for models
oc get inferenceservice -n lemonade-stand-assistant -w

# Alternatives (pick any)
helm upgrade --install en-coffee-stand-assistant ./chart \
  --create-namespace -n en-coffee-stand-assistant -f chart/values-en-coffee.yaml

helm upgrade --install es-cafe-stand-assistant ./chart \
  --create-namespace -n es-cafe-stand-assistant -f chart/values-es-cafe.yaml

helm upgrade --install es-mate-stand-assistant ./chart \
  --create-namespace -n es-mate-stand-assistant -f chart/values-es-mate.yaml

helm upgrade --install es-piscola-stand-assistant ./chart \
  --create-namespace -n es-piscola-stand-assistant -f chart/values-es-piscola.yaml

helm upgrade --install es-chicha-stand-assistant ./chart \
  --create-namespace -n es-chicha-stand-assistant -f chart/values-es-chicha.yaml

helm upgrade --install es-ceviche-stand-assistant ./chart \
  --create-namespace -n es-ceviche-stand-assistant -f chart/values-es-ceviche.yaml

helm upgrade --install es-tacos-stand-assistant ./chart \
  --create-namespace -n es-tacos-stand-assistant -f chart/values-es-tacos.yaml

helm upgrade --install es-limonada-stand-assistant ./chart \
  --create-namespace -n es-limonada-stand-assistant -f chart/values-es-limonada.yaml

helm upgrade --install es-tequila-stand-assistant ./chart \
  --create-namespace -n es-tequila-stand-assistant -f chart/values-es-tequila.yaml

helm upgrade --install pt-cafe-stand-assistant ./chart \
  --create-namespace -n pt-cafe-stand-assistant -f chart/values-pt-cafe.yaml

helm upgrade --install pt-limonada-stand-assistant ./chart \
  --create-namespace -n pt-limonada-stand-assistant -f chart/values-pt-limonada.yaml

helm upgrade --install pt-caipirinha-stand-assistant ./chart \
  --create-namespace -n pt-caipirinha-stand-assistant -f chart/values-pt-caipirinha.yaml

helm upgrade --install pt-cachaca-stand-assistant ./chart \
  --create-namespace -n pt-cachaca-stand-assistant -f chart/values-pt-cachaca.yaml
```

Standalone alternative (own GPU models): add `--set models.shared.enabled=false`.

## Editing

1. Edit sources under `alternatives/<lang>/<theme>/` **or** `chart/files/<lang>/<theme>/`.
2. Keep them in sync: chart files are what Helm mounts into the cluster.
3. Prefer editing `chart/files/...` when preparing a deploy, then copy back to `alternatives/` if you want the source tree updated.
