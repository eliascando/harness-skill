---
name: harness-skill
description: >
  Configura un "harness" de gobernanza para agentes de IA en el proyecto del
  usuario: git hooks que bloquean push directo a main, commit de .env y secretos,
  y reescritura de historia; más una capa de contexto (reglas + estado) que el
  agente lee. Agnóstico a la herramienta y human-in-the-loop: investiga el
  proyecto, pregunta y adapta sin asumir nada. CREA los archivos necesarios (los
  hooks viven en el repo porque git los ejecuta desde ahí).
  Trigger: cuando el usuario quiere instalar, configurar o adaptar el harness;
  proteger su repo de acciones no deseadas (de agentes o humanos) como push a
  main, .env o secretos; o dice "configura el harness", "instala el harness",
  "agrega guardarraíles", "set up the harness".
license: MIT
metadata:
  author: eliascando
  version: "1.0"
---

> **Este archivo es un playbook agnóstico.** Su cuerpo funciona en cualquier
> agente (Claude Code, Cursor, opencode, Gemini, Codex). El frontmatter de arriba
> solo lo aprovecha Claude Code para auto-activarse; los demás agentes ejecutan
> los pasos de abajo. Para activarlo nativamente en cada herramienta, ver
> `integrations/` en el repositorio.

## When to Use

- El usuario quiere proteger su repo de acciones riesgosas (push directo a `main`,
  commit de `.env`/secretos, force push) **sin depender de que el agente recuerde** las reglas.
- Quiere instalar o adaptar el harness en un proyecto **nuevo o existente**.
- Quiere que las reglas se cumplan para **cualquier** agente de IA y para humanos.

## Critical Patterns

1. **No asumas nada.** Ni la rama, ni el flujo, ni las herramientas, ni el stack.
   Investiga el proyecto real con comandos antes de preguntar.
2. **Human-in-the-loop.** Pregunta y **espera respuesta** antes de crear o modificar
   archivos. Muestra un resumen y pide confirmación antes de escribir.
3. **CREA los archivos**, no clones un repo en el proyecto del usuario. Los hooks
   DEBEN vivir en el repo (git los ejecuta desde `.githooks/`). Genera **solo lo
   mínimo** adaptado al proyecto. No pises lo existente.
4. **Verifica probando.** No declares "instalado" sin probar un bloqueo real.

## Dónde están los templates

Los templates viven junto a este archivo, en `assets/`:
`assets/githooks/`, `assets/rules/`, `assets/context/`, `assets/openspec/`,
`assets/docs/`, `assets/scripts/`, `assets/ci/`. Si tu agente no tiene acceso a
esta carpeta, pídele al usuario la ruta donde clonó el repo `harness-skill`.

## Workflow

### Paso 1 — Entender el proyecto (investiga en silencio)

```bash
git rev-parse --is-inside-work-tree           # ¿es repo git? si no, ofrece git init
git branch -a; git symbolic-ref --short HEAD  # ramas: main/master/develop, actual
git log --oneline -1                          # ¿nuevo (sin commits) o existente?
ls package.json go.mod pyproject.toml Cargo.toml pom.xml 2>/dev/null  # stack
ls CLAUDE.md AGENTS.md .cursor .opencode GEMINI.md 2>/dev/null        # agentes presentes
```

Resume al usuario lo detectado en 3-4 líneas. No avances sin mostrarlo.

### Paso 2 — Preguntar (agrupa y espera respuestas)

1. ¿Proyecto **nuevo** o **existente**?
   - Nuevo: ¿qué flujo de ramas? `gitflow` (feature→develop→main),
     `trunk-based` (ramas cortas→PR→main) o `simple` (sin bloqueo).
   - Existente: confirma el flujo que **ya** usa, para no romperlo.
2. ¿Rama de producción a proteger? (detectaste: `<X>`).
3. ¿Bloquear push directo a esa rama **siempre**, **solo con develop**, o **no**?
   → `BLOCK_MODE` = `always` / `if-develop` / `off`.
4. ¿Qué reglas activar? Muestra `assets/rules/OPERATING_RULES.md`; que elija/agregue.
5. ¿Quiere la capa `openspec/` (STATUS, DECISIONS, ROADMAP, RISKS)? Sí/No.
6. ¿Qué agentes de IA usa? (Claude Code / opencode / Cursor / Gemini / Codex)
   → configura **solo** esos.

### Paso 3 — Adaptar y CREAR (con confirmación previa)

Lee los templates de `assets/` y genera en el repo del usuario, adaptados:

- `.githooks/pre-push` ← `assets/githooks/pre-push`, ajustando la sección CONFIG
  (`PROTECTED_BRANCH`, `BLOCK_MODE`) según respuestas 2 y 3.
- `.githooks/pre-commit` ← `assets/githooks/pre-commit` (aplica a todos los flujos).
- `rules/OPERATING_RULES.md` ← solo las reglas elegidas, con las palabras del usuario.
- Contexto del agente: si **no existe**, créalo desde `assets/context/*.template`.
  Si **ya existe**, **NO lo pises**: agrégale la línea que referencia las reglas
  (`@rules/OPERATING_RULES.md` o equivalente).
- Si pidió `openspec/`: copia `assets/openspec/` adaptando `STATUS.md`.

Muestra la lista de archivos a crear/modificar y **pide confirmación** antes de escribir.

### Paso 4 — Activar el enforcement

```bash
chmod +x .githooks/pre-commit .githooks/pre-push
git config core.hooksPath .githooks
```

### Paso 5 — Verificar (no afirmes sin probar)

```bash
printf 'SECRET=abc123real' > .env && git add -f .env && git commit -m test
# (debe ser BLOQUEADO por pre-commit) → luego limpia:
git reset -q HEAD .env 2>/dev/null; rm -f .env
```

### Paso 6 — Cierre

Resume qué quedó y qué le toca al usuario: afinar `rules/OPERATING_RULES.md`,
**reiniciar su agente** para cargar el contexto, y las salidas de emergencia:
`ALLOW_MAIN=1`, `ALLOW_FORCE=1`, `git commit --no-verify`.

## Commands

```bash
git config core.hooksPath .githooks && chmod +x .githooks/*   # activar hooks
# pre-push CONFIG:  PROTECTED_BRANCH="main"  BLOCK_MODE="always|if-develop|off"
ALLOW_MAIN=1 git push ...        # override: push directo puntual
ALLOW_FORCE=1 git push --force   # override: force push a rama crítica
git commit --no-verify           # override: saltar pre-commit
```

## Resources

- **Templates**: ver [assets/](assets/).
- **Instalador manual** (fallback con defaults): `assets/setup.sh`.
- **Conectar otros agentes a la capa de contexto**: `assets/docs/harnesses.md`.
