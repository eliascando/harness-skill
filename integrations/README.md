# Instalar en tu agente

`harness-skill` es un **playbook agnóstico**: su núcleo
(`plugins/harness-skill/skills/harness-skill/SKILL.md` + `assets/`) lo puede
ejecutar cualquier agente. Cada herramienta tiene su forma de registrar un comando
que dispara ese playbook. Primero cloná el repo en algún lugar accesible:

```bash
git clone https://github.com/eliascando/harness-skill ~/harness-skill
```

(o dentro de tu proyecto). Luego, según tu agente:

## Claude Code — marketplace (instalación nativa)

```text
/plugin marketplace add eliascando/harness-skill
/plugin install harness-skill@harness-skill
```

Luego, en cualquier proyecto: `configura el harness`. La skill se auto-activa.

## opencode

Copiá el comando a tu proyecto (o a `~/.config/opencode/commands/`):

```bash
mkdir -p .opencode/commands
cp ~/harness-skill/integrations/opencode/harness-setup.md .opencode/commands/
```

Invocá con `/harness-setup`.

## Gemini CLI

```bash
mkdir -p .gemini/commands
cp ~/harness-skill/integrations/gemini/harness-setup.toml .gemini/commands/
```

Invocá con `/harness-setup` (corré `/commands reload` si ya estaba abierto).

## Cursor

```bash
mkdir -p .cursor/commands
cp ~/harness-skill/integrations/cursor/harness-setup.md .cursor/commands/
```

Invocá el comando `harness-setup` desde el chat de Cursor.

## Cualquier otro agente

No hace falta un comando: abrí tu agente en la raíz del proyecto y pedile:

```text
Lee el SKILL.md de harness-skill (en <ruta donde lo clonaste>) y configura el
harness en mi proyecto: investigá mi contexto, preguntame y no asumas nada.
```

---

> Los formatos de comando pueden variar según la versión de cada herramienta.
> Si tu herramienta cambió la ubicación o el formato, ajustá el adaptador — el
> contenido (el prompt que dispara el playbook) es el mismo.
