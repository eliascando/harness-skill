# OPERATING_RULES.md — Reglas operativas del proyecto

> Esta es la **fuente única de verdad** de cómo se trabaja en este proyecto.
> Editá estas reglas con las tuyas. Todo lo demás (CLAUDE.md, AGENTS.md, etc.)
> **referencia** este archivo en vez de duplicar su contenido.

Aplican **siempre**: sin importar qué agente AI (Claude Code, opencode, Cursor,
Gemini, Codex…) ni si el trabajo es backend, frontend, infra, datos o docs.

---

## 1. Documentación al día o la tarea NO está terminada

Cada vez que se agregue, corrija o elimine algo relevante, se actualiza en la
misma sesión la documentación afectada (README, docs de arquitectura, estado).
Si cambia arquitectura, flujo, entorno, CI/CD o configuración, la doc queda
sincronizada antes de cerrar la tarea.

## 2. Verificá antes de afirmar

No se asume: se verifica con evidencia real (código, base de datos, logs,
procesos). La documentación puede estar desactualizada; los hechos no. Si no
estás seguro, investigá antes de afirmar.

## 3. Branching

- `develop` = integración / validación.
- `main` = producción.
- Todo cambio entra por: rama → PR a `develop` → validar → PR a `main`.
- **Push directo a `main` está bloqueado** por el hook (override documentado).

## 4. Las variables de entorno son secretas

- `.env`, `.env.production` y equivalentes **no se commitean**.
- Versioná solo plantillas: `.env.example` / `.env.template`.
- Los secretos reales viven en el gestor de secretos / variables del entorno.

## 5. Un paso crítico que puede fallar debe poder ABORTAR

Nada de `|| true` ni `|| echo "ok"` que convierten una falla en silencio.
Si un paso de CI/deploy/migración falla, el proceso se detiene y es visible.

## 6. Cambios de infraestructura se documentan

Si tocás CI/CD, contenedores, proxy, infra como código o migraciones, dejá la
documentación y el rollback claros en la misma sesión.

## 7. Toda regla dura tiene una salida de emergencia documentada

Los hooks permiten overrides para emergencias reales, pero su uso debe quedar
registrado:

- `ALLOW_MAIN=1 git push …` — push directo a la rama protegida.
- `ALLOW_FORCE=1 git push --force …` — force push a `main`/`develop`.
- `git commit --no-verify` — saltear validaciones de pre-commit.

## 8. Definición de "terminado"

Una tarea no está cerrada si falta cualquiera de estas piezas:

- [ ] Código correcto + pruebas/typecheck relevantes en verde
- [ ] Verificación de runtime (health/smoke) si tocó deploy
- [ ] Documentación sincronizada con el estado real
- [ ] Rollback entendible (tag/imagen/commit estable identificable)

---

> Personalizá, agregá o quitá reglas según tu proyecto. Lo importante es que
> **vivan en un solo lugar** y que el enforcement (hooks) las respalde.
