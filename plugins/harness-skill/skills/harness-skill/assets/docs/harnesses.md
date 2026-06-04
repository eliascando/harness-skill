# Conectar tu agente AI

Las reglas viven en `rules/OPERATING_RULES.md` (fuente única). El **enforcement**
(git hooks) ya cubre cualquier herramienta sin configuración extra. Lo de abajo
es solo la capa de **contexto**: que el agente *lea* las reglas.

Principio: **nadie duplica el texto de las reglas; cada herramienta las referencia.**

| Herramienta | Archivo de entrada | Mecanismo |
|---|---|---|
| Claude Code | `CLAUDE.md` | `@import` de las reglas |
| opencode | `.opencode/opencode.json` | campo `instructions` + plugin enforcer |
| Cursor | `.cursor/rules/project.mdc` | rules file que referencia |
| Gemini CLI | `GEMINI.md` | archivo de contexto |
| Codex | `AGENTS.md` | instrucciones del repo |

`setup.sh` crea `CLAUDE.md` y `AGENTS.md` automáticamente. Para los demás:

## Cursor

```md
<!-- .cursor/rules/project.mdc -->
---
description: Reglas operativas del proyecto
alwaysApply: true
---
Seguí rules/OPERATING_RULES.md.
Antes de tocar el repo, leé openspec/STATUS.md.
```

## Gemini CLI

```bash
printf '# Contexto\n\nSeguí rules/OPERATING_RULES.md\nEstado: openspec/STATUS.md\n' > GEMINI.md
```

## opencode

Corré `INSTALL_OPENCODE=1 ./setup.sh` (o creá la carpeta `.opencode/` antes de
correr setup). Esto instala `opencode.json` + el plugin `rules-enforcer.ts`.

---

El enforcement por git hooks aplica a **todas** estas herramientas por igual,
porque vive en git, no en el harness de cada una.
