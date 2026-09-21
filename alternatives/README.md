# Alternative demos

Localized variants of the Lemonade Stand guardrails demo. The original English lemonade app remains at `../lemonade-stand-app/`.

Source apps are grouped by language. Helm chart assets live under `../chart/files/` with the same layout.

## Layout

```
alternatives/
  en/
    coffee/          # English coffee
  es/
    cafe/            # Spanish coffee (café)
    mate/            # Spanish mate (Uruguay)
    piscola/         # Spanish piscola (Chile)
  pt/
    cafe/            # Portuguese coffee (café)
    cachaca/         # Portuguese cachaça
```

## Deploy

From the repo root:

```bash
./scripts/deploy.sh lemonade   # EN / lemons (default original)
./scripts/deploy.sh coffee     # EN / coffee
./scripts/deploy.sh cafe       # ES / café
./scripts/deploy.sh mate       # ES / mate
./scripts/deploy.sh piscola    # ES / piscola
./scripts/deploy.sh cafept     # PT / café
./scripts/deploy.sh cachaca    # PT / cachaça
```

Each variant uses its own OpenShift namespace and release name.

## Editing

1. Edit sources under `alternatives/<lang>/<theme>/` **or** `chart/files/<lang>/<theme>/`.
2. Keep them in sync: chart files are what Helm mounts into the cluster.
3. Prefer editing `chart/files/...` when preparing a deploy, then copy back to `alternatives/` if you want the source tree updated.
