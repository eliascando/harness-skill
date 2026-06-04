#!/bin/bash
# setup.sh — instala el harness en tu repositorio.
#
# Configura:
#   - git hooks (enforcement real, agnostico a la herramienta AI)
#   - el archivo de contexto para tu(s) agente(s) AI (Claude Code, opencode, etc.)
#
# Uso:
#   ./setup.sh              instala / reinstala (sobrescribe la config generada)
#   ./setup.sh --check      reporta que existe/falta, NO modifica nada
#   ./setup.sh --uninstall  desactiva los hooks
#
# Por defecto instala en el repo actual (donde corres el script).
set -e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
HARNESS_DIR="$(cd "$(dirname "$0")" && pwd)"

if [ -z "$REPO_ROOT" ]; then
  echo "No estas dentro de un repositorio git. Corre 'git init' primero."
  exit 1
fi

MODE="install"
case "$1" in
  --check)     MODE="check" ;;
  --uninstall) MODE="uninstall" ;;
  ""|--force)  MODE="install" ;;
  *) echo "Uso: $0 [--check|--uninstall]"; exit 2 ;;
esac

echo "harness setup ($MODE)"
echo "  repo:    $REPO_ROOT"
echo "  harness: $HARNESS_DIR"
echo ""

# ── MODO --check ─────────────────────────────────────────────────────
if [ "$MODE" = "check" ]; then
  hp=$(git -C "$REPO_ROOT" config core.hooksPath 2>/dev/null || true)
  if [ "$hp" = ".githooks" ] && [ -x "$REPO_ROOT/.githooks/pre-commit" ]; then
    echo "  [ok]   git hooks instalados"
  else
    echo "  [--]   git hooks NO instalados (se instalarian)"
  fi
  [ -f "$REPO_ROOT/CLAUDE.md" ]  && echo "  [ok]   CLAUDE.md presente"  || echo "  [--]   CLAUDE.md falta (se crearia)"
  [ -f "$REPO_ROOT/AGENTS.md" ]  && echo "  [ok]   AGENTS.md presente"  || echo "  [--]   AGENTS.md falta (se crearia)"
  echo ""
  echo "--check no modifica nada. Para instalar: ./setup.sh"
  exit 0
fi

# ── MODO --uninstall ─────────────────────────────────────────────────
if [ "$MODE" = "uninstall" ]; then
  if [ "$(git -C "$REPO_ROOT" config core.hooksPath 2>/dev/null)" = ".githooks" ]; then
    git -C "$REPO_ROOT" config --unset core.hooksPath
    echo "  [ok]   core.hooksPath desactivado (los archivos en .githooks/ no se borran)"
  fi
  echo "Listo. El contexto (CLAUDE.md / AGENTS.md / reglas) NO se borra."
  exit 0
fi

# ── MODO install ─────────────────────────────────────────────────────

# 1) git hooks
echo "▸ git hooks (enforcement)"
mkdir -p "$REPO_ROOT/.githooks"
cp "$HARNESS_DIR/githooks/pre-push"   "$REPO_ROOT/.githooks/pre-push"
cp "$HARNESS_DIR/githooks/pre-commit" "$REPO_ROOT/.githooks/pre-commit"
chmod +x "$REPO_ROOT/.githooks/pre-push" "$REPO_ROOT/.githooks/pre-commit"
git -C "$REPO_ROOT" config core.hooksPath .githooks
echo "  [ok]   hooks copiados + core.hooksPath=.githooks"

# 2) reglas (fuente unica de verdad)
echo "▸ reglas"
mkdir -p "$REPO_ROOT/rules"
[ -f "$REPO_ROOT/rules/OPERATING_RULES.md" ] || cp "$HARNESS_DIR/rules/OPERATING_RULES.md" "$REPO_ROOT/rules/OPERATING_RULES.md"
echo "  [ok]   rules/OPERATING_RULES.md (editalo con tus reglas)"

# 2b) estructura de conocimiento + utilidades (no pisa lo existente)
echo "▸ openspec / docs / scripts"
for d in openspec docs scripts; do
  if [ -d "$REPO_ROOT/$d" ]; then
    echo "  [--]   $d/ ya existe, no se toca"
  else
    cp -R "$HARNESS_DIR/$d" "$REPO_ROOT/$d"
    echo "  [ok]   $d/ copiado"
  fi
done
chmod +x "$REPO_ROOT/scripts/"*.sh 2>/dev/null || true

# 3) contexto para agentes AI
echo "▸ contexto para agentes AI"
if [ ! -f "$REPO_ROOT/CLAUDE.md" ]; then
  cp "$HARNESS_DIR/context/CLAUDE.md.template" "$REPO_ROOT/CLAUDE.md"
  echo "  [ok]   CLAUDE.md creado (Claude Code)"
fi
if [ ! -f "$REPO_ROOT/AGENTS.md" ]; then
  cp "$HARNESS_DIR/context/AGENTS.md.template" "$REPO_ROOT/AGENTS.md"
  echo "  [ok]   AGENTS.md creado (Codex, otros)"
fi
# opencode (opcional)
if [ -d "$REPO_ROOT/.opencode" ] || [ "$INSTALL_OPENCODE" = "1" ]; then
  mkdir -p "$REPO_ROOT/.opencode/plugins"
  cp "$HARNESS_DIR/context/opencode/opencode.json"             "$REPO_ROOT/.opencode/opencode.json"
  cp "$HARNESS_DIR/context/opencode/plugins/rules-enforcer.ts" "$REPO_ROOT/.opencode/plugins/rules-enforcer.ts"
  echo "  [ok]   .opencode/ configurado (opencode)"
fi

echo ""
echo "Listo. Que quedo activo:"
echo "  - git hooks   -> bloquean push a main, force push, .env y secretos"
echo "  - CLAUDE.md / AGENTS.md -> el agente lee tus reglas al iniciar"
echo ""
echo "Siguientes pasos:"
echo "  1. Edita rules/OPERATING_RULES.md con TUS reglas."
echo "  2. Reinicia tu agente AI para que cargue el contexto."
echo "  3. Verifica:  ./scripts/doctor.sh"
echo "  4. Otros agentes (Cursor, Gemini): ver docs/harnesses.md"
