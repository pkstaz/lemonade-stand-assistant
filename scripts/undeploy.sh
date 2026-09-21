#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <variant>

Variants:
  lemonade | coffee | cafe | mate | piscola | cafept | cachaca
EOF
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

variant="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"

case "${variant}" in
  lemonade|lemon)
    NS="lemonade-stand-assistant"
    RELEASE="lemonade-stand-assistant"
    ;;
  coffee)
    NS="coffee-assistant"
    RELEASE="coffee-assistant"
    ;;
  cafe)
    NS="asistente-cafe"
    RELEASE="asistente-cafe"
    ;;
  mate|yerba)
    NS="asistente-mate"
    RELEASE="asistente-mate"
    ;;
  piscola|pisco|chile)
    NS="asistente-piscola"
    RELEASE="asistente-piscola"
    ;;
  cafept|cafe-pt|cafep)
    NS="assistente-cafe"
    RELEASE="assistente-cafe"
    ;;
  cachaca|cachaça|caipirinha)
    NS="assistente-cachaca"
    RELEASE="assistente-cachaca"
    ;;
  *)
    echo "Unknown variant: ${variant}" >&2
    usage
    exit 1
    ;;
esac

echo "Uninstalling release=${RELEASE} namespace=${NS}"
helm uninstall "${RELEASE}" -n "${NS}" || true

if [[ "${DELETE_NAMESPACE:-false}" == "true" ]]; then
  echo "Deleting namespace ${NS}"
  oc delete namespace "${NS}" --wait=false || true
fi
