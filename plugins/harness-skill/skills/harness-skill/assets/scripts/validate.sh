#!/bin/bash
# validate.sh — validación estricta del harness (falla con exit 1 si hay problemas).
# Pensado para CI y pre-push. Los hooks locales se saltan con --no-verify;
# esto corre en el servidor y no se puede saltar.
set -u

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fail=0
err() { echo "  [FALLA] $1"; fail=1; }
ok()  { echo "  [ok]    $1"; }

echo "harness validate (estricto)"
echo ""

# 1) reglas presentes
if [ -f "$ROOT/rules/OPERATING_RULES.md" ]; then ok "reglas presentes"; else err "falta rules/OPERATING_RULES.md"; fi

# 2) hooks presentes y ejecutables
if [ -x "$ROOT/.githooks/pre-commit" ] && [ -x "$ROOT/.githooks/pre-push" ]; then
  ok "hooks presentes y ejecutables"
else
  err "hooks faltantes o no ejecutables (corre ./setup.sh)"
fi

# 3) no hay .env reales trackeados
tracked_env=$(git -C "$ROOT" ls-files | grep -E '(^|/)\.env($|\.)' | grep -vE '\.(example|template|sample|docker)$' || true)
if [ -n "$tracked_env" ]; then
  err "hay archivos .env reales trackeados:"; printf '%s\n' "$tracked_env" | sed 's/^/         - /'
else
  ok "sin .env reales trackeados"
fi

# 4) no hay dumps/backups trackeados
tracked_dumps=$(git -C "$ROOT" ls-files | grep -E '\.(dump|sql\.gz|backup|bak|tar\.gz|tgz|zip)$' || true)
if [ -n "$tracked_dumps" ]; then
  err "hay dumps/backups trackeados:"; printf '%s\n' "$tracked_dumps" | sed 's/^/         - /'
else
  ok "sin dumps/backups trackeados"
fi

echo ""
if [ "$fail" -eq 0 ]; then echo "Validación OK."; exit 0; else echo "Validación con problemas."; exit 1; fi
