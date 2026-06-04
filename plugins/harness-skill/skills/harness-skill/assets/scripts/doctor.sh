#!/bin/bash
# doctor.sh — diagnóstico del harness (informativo, no falla nunca).
# Reporta el estado de hooks, contexto y herramientas. Ideal para onboarding.

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
echo "harness doctor"
echo "  repo: $ROOT"
echo ""

ok()   { echo "  [ok]   $1"; }
miss() { echo "  [--]   $1"; }

# git hooks
hp=$(git -C "$ROOT" config core.hooksPath 2>/dev/null || true)
if [ "$hp" = ".githooks" ] && [ -x "$ROOT/.githooks/pre-commit" ] && [ -x "$ROOT/.githooks/pre-push" ]; then
  ok "git hooks instalados (core.hooksPath=.githooks)"
else
  miss "git hooks NO instalados — corre ./setup.sh"
fi

# contexto
[ -f "$ROOT/rules/OPERATING_RULES.md" ] && ok "rules/OPERATING_RULES.md" || miss "rules/OPERATING_RULES.md falta"
[ -f "$ROOT/CLAUDE.md" ] && ok "CLAUDE.md (Claude Code)" || miss "CLAUDE.md falta"
[ -f "$ROOT/AGENTS.md" ] && ok "AGENTS.md" || miss "AGENTS.md falta"
[ -f "$ROOT/openspec/STATUS.md" ] && ok "openspec/STATUS.md" || miss "openspec/STATUS.md falta"

# modo de bloqueo de push (según la CONFIG del hook instalado)
has_develop=false
if git -C "$ROOT" rev-parse --verify --quiet refs/heads/develop >/dev/null 2>&1 \
   || git -C "$ROOT" rev-parse --verify --quiet refs/remotes/origin/develop >/dev/null 2>&1; then
  has_develop=true
fi
# [^"]* captura solo el valor entre las primeras comillas (ignora comentarios con comillas)
mode=$(sed -nE 's/^BLOCK_MODE="([^"]*)".*/\1/p' "$ROOT/.githooks/pre-push" 2>/dev/null | head -1)
prot=$(sed -nE 's/^PROTECTED_BRANCH="([^"]*)".*/\1/p' "$ROOT/.githooks/pre-push" 2>/dev/null | head -1)
case "$mode" in
  always)     ok "bloqueo de push directo a '${prot:-main}': SIEMPRE (BLOCK_MODE=always)" ;;
  if-develop) if $has_develop; then ok "bloqueo de push a '${prot:-main}': activo (if-develop + develop existe)";
              else miss "bloqueo de push: INACTIVO (BLOCK_MODE=if-develop pero no hay rama develop)"; fi ;;
  off)        miss "bloqueo de push directo: desactivado (BLOCK_MODE=off)" ;;
  *)          miss "no pude leer BLOCK_MODE del hook (¿hooks instalados?)" ;;
esac

# herramientas opcionales
command -v gh >/dev/null 2>&1 && ok "gh CLI disponible" || miss "gh CLI no instalado (opcional)"

echo ""
echo "Diagnóstico informativo. Para validación estricta (CI): ./scripts/validate.sh"
exit 0
