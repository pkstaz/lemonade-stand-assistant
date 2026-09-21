#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $(basename "$0") <variant>

Uninstalls the Helm release and deletes the variant namespace.

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

delete_namespace() {
  local ns="$1"
  if command -v oc >/dev/null 2>&1; then
    oc delete namespace "${ns}" --wait=false
  elif command -v kubectl >/dev/null 2>&1; then
    kubectl delete namespace "${ns}" --wait=false
  else
    echo "Warning: oc/kubectl not found; namespace ${ns} was not deleted" >&2
    return 1
  fi
}

echo "Uninstalling release=${RELEASE} namespace=${NS}"
helm uninstall "${RELEASE}" -n "${NS}" || true

echo "Deleting namespace ${NS}"
delete_namespace "${NS}" || true
