#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CHART="${REPO_ROOT}/chart"

usage() {
  cat <<EOF
Usage: $(basename "$0") <variant> [helm upgrade args...]

Variants (language / theme -> namespace):
  lemonade   English  / lemons     -> lemonade-stand-assistant
  coffee     English  / coffee     -> coffee-assistant
  cafe       Spanish  / coffee     -> asistente-cafe
  mate       Spanish  / mate (UY)  -> asistente-mate
  piscola    Spanish  / piscola(CL)-> asistente-piscola
  cafept     Portuguese / café     -> assistente-cafe
  cachaca    Portuguese / cachaça  -> assistente-cachaca

Examples:
  $(basename "$0") lemonade
  $(basename "$0") coffee
  $(basename "$0") cafe
  $(basename "$0") cafept
  $(basename "$0") cachaca
  $(basename "$0") mate --set model.api_key=secret
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

variant="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
shift

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

echo "Deploying variant=${variant} release=${RELEASE} namespace=${NS}"

ensure_namespace "${NS}"

helm upgrade --install "${RELEASE}" "${CHART}" \
  -n "${NS}" \
  -f "${VALUES}" \
  "$@"

echo
echo "Chat URL:"
echo "  https://$(oc get route "${APP}" -n "${NS}" --template='{{.spec.host}}' 2>/dev/null || echo "<pending>")"
echo "Dashboard URL:"
echo "  https://$(oc get route shiny-dashboard -n "${NS}" --template='{{.spec.host}}' 2>/dev/null || echo "<pending>")"
