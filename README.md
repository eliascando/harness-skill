# harness-skill

Un **harness** de gobernanza para agentes de IA, empaquetado como una skill que
**cualquier agente** puede usar (Claude Code, Cursor, opencode, Gemini, Codex).
Configura reglas que **se cumplen solas** porque viven en git, no en la memoria
del modelo.

Una regla que solo le *dices* a la IA es una sugerencia, no una ley: la lee, la
respeta un rato, y eventualmente la olvida. Este harness la convierte en algo que
se bloquea de verdad — push directo a `main`, `.env` reales, secretos y
reescritura de historia quedan frenados por git hooks que corren igual para
**cualquier** agente y para humanos.

En vez de clonar archivos a tu repo, la skill **investiga tu proyecto, te
pregunta y genera solo lo mínimo adaptado**. Human-in-the-loop: no asume nada.

> Inspirado en patrones de gobernanza de agentes ya existentes en la comunidad.
> Esta es una implementación concreta, agnóstica y empaquetada como skill.

## Instalación: un prompt

La forma más simple. Copia esto y pégaselo a tu agente (Claude Code, Cursor,
opencode, Gemini, Codex…) en la raíz de tu proyecto:

```text
Instala el harness de https://github.com/eliascando/harness-skill en este
proyecto: clónalo en una carpeta temporal, lee
plugins/harness-skill/skills/harness-skill/SKILL.md y sigue ese playbook.
Investiga mi proyecto, pregúntame lo necesario (human-in-the-loop) y crea solo
los archivos mínimos adaptados. No asumas nada.
```

El agente clona el repo, lee el playbook y configura todo **contigo**: detecta tu
contexto, te pregunta y crea solo lo mínimo. Eso es todo.

> ¿Prefieres un comando reutilizable (`/harness-setup`) o el marketplace de Claude
> Code? Ver [Independiente de la herramienta](#independiente-de-la-herramienta).

## Independiente de la herramienta

El núcleo es un **playbook** en markdown
(`plugins/harness-skill/skills/harness-skill/SKILL.md`) que cualquier agente
ejecuta. No depende de Claude: el marketplace de Claude es **una** forma de
instalarlo, no la única. Cada herramienta tiene su adaptador en
[`integrations/`](integrations/).

| Herramienta | Instalación | Invocación |
|---|---|---|
| Claude Code | `/plugin marketplace add eliascando/harness-skill` → `/plugin install harness-skill@harness-skill` | `configura el harness` (auto-activa) |
| opencode | copiar `integrations/opencode/harness-setup.md` a `.opencode/commands/` | `/harness-setup` |
| Gemini CLI | copiar `integrations/gemini/harness-setup.toml` a `.gemini/commands/` | `/harness-setup` |
| Cursor | copiar `integrations/cursor/harness-setup.md` a `.cursor/commands/` | `harness-setup` |
| Cualquier otro | "Lee el SKILL.md de harness-skill y configura el harness" | — |

Guía detallada por herramienta: [`integrations/README.md`](integrations/README.md).

## Qué hace al instalarlo en tu proyecto

1. **Detecta** tu contexto — repo nuevo o existente, ramas (`main`/`master`/`develop`),
   flujo, stack y qué agentes ya usas.
2. **Pregunta** lo que necesita — rama a proteger, modo de bloqueo, qué reglas
   activar, si quieres la capa `openspec/`, qué agentes configurar.
3. **Crea solo lo mínimo**, adaptado, sin pisar lo que ya tengas.
4. **Verifica** probando un bloqueo real antes de declararlo listo.

Lo que deja en tu proyecto (lo imprescindible, no más):

```
tu-proyecto/
+ .githooks/{pre-commit,pre-push}   # enforcement (git los ejecuta desde aquí)
+ rules/OPERATING_RULES.md          # tus reglas (fuente única de verdad)
+ CLAUDE.md / AGENTS.md             # contexto del agente (referencia las reglas)
  (opcional, si lo pides) openspec/, docs/, scripts/
```

Los hooks **deben** vivir en tu repo: así funciona git. Todo lo demás es opcional
y se genera adaptado, no clonado.

## Qué bloquea

| Regla | Mecanismo | Configurable |
|---|---|---|
| Push directo a la rama protegida | `pre-push` | `BLOCK_MODE` = `always` / `if-develop` / `off` |
| Force / reescritura de historia | `pre-push` | override `ALLOW_FORCE=1` |
| Commit de `.env` reales | `pre-commit` | permite `*.example` / `*.template` |
| Dumps / backups / comprimidos | `pre-commit` | — |
| Secretos reales en el contenido | `pre-commit` | permite placeholders |
| Cambios de infraestructura | `pre-commit` | aviso, no bloqueo |

Toda regla dura tiene **salida de emergencia con registro** (`ALLOW_MAIN=1`,
`ALLOW_FORCE=1`, `git commit --no-verify`). Un guardarraíl, no una cárcel.

## Por qué funciona: dos capas separadas

1. **Contexto (soft)** — lo que el agente *lee*. Se puede olvidar.
   Vive en `rules/OPERATING_RULES.md`; cada herramienta lo referencia.
2. **Enforcement (hard)** — lo que *bloquea* una acción. No se negocia.
   Git hooks + (opcional) plugin de opencode + CI.

> Usás tu agente para **configurar** el harness una vez; el harness resultante
> protege contra **cualquier** agente y contra errores humanos.

## Estructura del repositorio

```
.claude-plugin/marketplace.json          marketplace de Claude Code
plugins/harness-skill/
  .claude-plugin/plugin.json             plugin de Claude Code
  skills/harness-skill/
    SKILL.md                             el playbook agnóstico (cerebro)
    assets/                              templates: githooks, rules, context, openspec, docs, scripts, ci
integrations/                            adaptadores: opencode, gemini, cursor
README.md  LICENSE
```

## Licencia

MIT. Úsalo, modifícalo y compártelo libremente.
