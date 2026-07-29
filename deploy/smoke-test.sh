#!/usr/bin/env bash
# Post-deploy smoke test.
#
# A finished rollout only proves the pods started. This asks the deployed
# build the three questions that separate "running" from "working": is it
# ready, does the compliance contract still hold, and does an ineligible
# URL still get refused.
#
# Usage: deploy/smoke-test.sh https://api.vidora.example
set -euo pipefail

BASE_URL="${1:?informe a URL base, ex.: https://api.vidora.example}"
TIMEOUT="${SMOKE_TIMEOUT_SECONDS:-10}"
ATTEMPTS="${SMOKE_ATTEMPTS:-30}"

fail() {
  echo "SMOKE FAIL: $*" >&2
  exit 1
}

echo "→ Aguardando readiness em $BASE_URL"
for attempt in $(seq 1 "$ATTEMPTS"); do
  if curl -fsS --max-time "$TIMEOUT" "$BASE_URL/health/ready" > /dev/null; then
    echo "  pronto (tentativa $attempt)"
    break
  fi
  if [ "$attempt" -eq "$ATTEMPTS" ]; then
    fail "readiness não respondeu 200 em $((ATTEMPTS * 2))s"
  fi
  sleep 2
done

echo "→ Liveness"
curl -fsS --max-time "$TIMEOUT" "$BASE_URL/health/live" > /dev/null \
  || fail "liveness não respondeu 200"

echo "→ Catálogo de adaptadores (trilha de auditoria da seção 2.2)"
adapters=$(curl -fsS --max-time "$TIMEOUT" "$BASE_URL/eligibility/adapters")
echo "$adapters" | grep -q 'legalBasis' \
  || fail "o catálogo não expõe a base legal dos adaptadores"

# The product's core promise, checked against the running deployment: a URL
# behind DRM must be refused. A build that ships with this broken is worse
# than a build that does not ship.
echo "→ Recusa de conteúdo protegido"
status=$(curl -sS --max-time "$TIMEOUT" -o /tmp/smoke-drm.json -w '%{http_code}' \
  -X POST "$BASE_URL/analysis" \
  -H 'Content-Type: application/json' \
  -d '{"url":"https://drm.example.com/filme"}' || true)

case "$status" in
  200|202)
    grep -q '"eligible":false' /tmp/smoke-drm.json \
      || fail "uma URL com DRM não foi recusada — resposta: $(cat /tmp/smoke-drm.json)"
    ;;
  4*)
    # A validation or rate-limit refusal is also a refusal.
    ;;
  *)
    fail "resposta inesperada da análise: HTTP $status"
    ;;
esac

echo "SMOKE OK: $BASE_URL"
