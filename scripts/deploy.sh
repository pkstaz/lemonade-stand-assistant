#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHART="${REPO_ROOT}/chart"

SHARED_MODELS=0
SHARED_NS="lemonade-stand-assistant"
STANDALONE=0
PASSTHROUGH=()

usage() {
  cat <<EOF
Usage: $(basename "$0") <variant> [options] [helm upgrade args...]

Variants (language / theme -> namespace):
  lemonade   English  / lemons     -> lemonade-stand-assistant
  coffee     English  / coffee     -> coffee-assistant
  cafe       Spanish  / coffee     -> asistente-cafe
  mate       Spanish  / mate (UY)  -> asistente-mate
  piscola    Spanish  / piscola(CL)-> asistente-piscola
  cafept     Portuguese / café     -> assistente-cafe
  cachaca    Portuguese / cachaça  -> assistente-cachaca

Options:
  --share-models [=NS]  Reuse LLM + HAP + prompt-injection (+ MinIO) from NS
                        (default NS: lemonade-stand-assistant). Keeps Lingua local.
  --standalone          Deploy a full model stack in this variant namespace
                        (default for lemonade; others share by default)

Examples:
  $(basename "$0") lemonade
  $(basename "$0") cafe                 # shares models from lemonade by default
  $(basename "$0") cafe --standalone    # own LLM/detectors
  $(basename "$0") mate --share-models=lemonade-stand-assistant
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

variant="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --share-models)
      SHARED_MODELS=1
      shift
      ;;
    --share-models=*)
      SHARED_MODELS=1
      SHARED_NS="${1#*=}"
      shift
      ;;
    --standalone)
      STANDALONE=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      PASSTHROUGH+=("$1")
      shift
      ;;
  esac
done

case "${variant}" in
  lemonade|lemon)
    VALUES="${CHART}/values-lemonade.yaml"
    NS="lemonade-stand-assistant"
    RELEASE="lemonade-stand-assistant"
    APP="lemonade-stand"
    ;;
  coffee)
    VALUES="${CHART}/values-coffee.yaml"
    NS="coffee-assistant"
    RELEASE="coffee-assistant"
    APP="coffee-assistant"
    ;;
  cafe)
    VALUES="${CHART}/values-cafe.yaml"
    NS="asistente-cafe"
    RELEASE="asistente-cafe"
    APP="asistente-cafe"
    ;;
  mate|yerba)
    VALUES="${CHART}/values-mate.yaml"
    NS="asistente-mate"
    RELEASE="asistente-mate"
    APP="asistente-mate"
    ;;
  piscola|pisco|chile)
    VALUES="${CHART}/values-piscola.yaml"
    NS="asistente-piscola"
    RELEASE="asistente-piscola"
    APP="asistente-piscola"
    ;;
  cafept|cafe-pt|cafep)
    VALUES="${CHART}/values-cafept.yaml"
    NS="assistente-cafe"
    RELEASE="assistente-cafe"
    APP="assistente-cafe"
    ;;
  cachaca|cachaça|caipirinha)
    VALUES="${CHART}/values-cachaca.yaml"
    NS="assistente-cachaca"
    RELEASE="assistente-cachaca"
    APP="assistente-cachaca"
    ;;
  *)
    echo "Unknown variant: ${variant}" >&2
    usage
    exit 1
    ;;
esac

# Secondary variants share lemonade models by default (unless --standalone)
if [[ "${variant}" != "lemonade" && "${variant}" != "lemon" && "${STANDALONE}" -eq 0 ]]; then
  SHARED_MODELS=1
fi
if [[ "${STANDALONE}" -eq 1 ]]; then
  SHARED_MODELS=0
fi

ensure_namespace() {
  local ns="$1"
  if command -v oc >/dev/null 2>&1; then
    if ! oc get namespace "${ns}" >/dev/null 2>&1; then
      echo "Creating namespace ${ns}..."
      oc create namespace "${ns}"
    fi
  elif command -v kubectl >/dev/null 2>&1; then
    if ! kubectl get namespace "${ns}" >/dev/null 2>&1; then
      echo "Creating namespace ${ns}..."
      kubectl create namespace "${ns}"
    fi
  else
    echo "Warning: oc/kubectl not found; relying on helm --create-namespace" >&2
  fi
}

HELM_EXTRA=()
if [[ "${SHARED_MODELS}" -eq 1 ]]; then
  echo "Sharing LLM/detectors from namespace=${SHARED_NS} (Lingua stays local)"
  HELM_EXTRA+=(
    --set models.shared.enabled=true
    --set models.shared.namespace="${SHARED_NS}"
    --set model.name=llama32
  )
fi

echo "Deploying variant=${variant} release=${RELEASE} namespace=${NS}"

ensure_namespace "${NS}"

helm upgrade --install "${RELEASE}" "${CHART}" \
  -n "${NS}" \
  -f "${VALUES}" \
  "${HELM_EXTRA[@]}" \
  "${PASSTHROUGH[@]+"${PASSTHROUGH[@]}"}"

echo
echo "Chat URL:"
echo "  https://$(oc get route "${APP}" -n "${NS}" --template='{{.spec.host}}' 2>/dev/null || echo "<pending>")"
echo "Dashboard URL:"
echo "  https://$(oc get route shiny-dashboard -n "${NS}" --template='{{.spec.host}}' 2>/dev/null || echo "<pending>")"
