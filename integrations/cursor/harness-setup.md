# Configura el harness de gobernanza de IA (human-in-the-loop)

Configura el "harness" de gobernanza de IA en este proyecto, siguiendo el playbook
de harness-skill.

Reglas de oro:
- NO asumas nada: investiga el proyecto real con git (ramas, flujo, stack, agentes presentes) antes de preguntar.
- Human-in-the-loop: pregunta y espera respuesta antes de crear o modificar archivos; muestra un resumen y pide confirmación.
- CREA solo lo mínimo: los git hooks (`.githooks/pre-commit`, `pre-push`) adaptados al flujo del usuario, `rules/OPERATING_RULES.md` con las reglas elegidas, y el contexto del agente. No pises lo existente.
- Verifica probando un bloqueo real antes de declararlo instalado.

El playbook completo (pasos 1 a 6) y los templates están en el repositorio
harness-skill. Lee `plugins/harness-skill/skills/harness-skill/SKILL.md` y usa los
templates de su carpeta `assets/`. Si no sabes dónde está clonado el repo,
pregúntaselo al usuario.
