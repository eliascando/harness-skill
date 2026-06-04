# Flujo de trabajo para agentes

Cómo debe trabajar un agente AI (o un humano) en este proyecto. No reemplaza las
reglas: las operacionaliza. Fuente de verdad: `rules/OPERATING_RULES.md`.

## 1. Antes de empezar

Leé, en este orden:

1. `rules/OPERATING_RULES.md` — reglas operativas.
2. `openspec/STATUS.md` — estado actual y próximos pasos.
3. `README` del módulo/área que vas a tocar.

Verificá tu entorno:

```bash
./scripts/doctor.sh     # diagnóstico del entorno y del harness
```

## 2. Durante el trabajo

- No toques `.env` reales. Versioná solo plantillas.
- No hagas push directo a `main`. Flujo: rama → PR a `develop` → PR a `main`.
- No reescribas historia en `main`/`develop`.
- Verificá antes de afirmar: evidencia desde código/datos/logs, no suposiciones.
- Un paso crítico que puede fallar debe poder ABORTAR (nada de fallas silenciosas).

## 3. Antes de cerrar (definición de "terminado")

- [ ] Código correcto + pruebas/typecheck en verde
- [ ] Verificación de runtime si tocó deploy
- [ ] Documentación sincronizada con el estado real
- [ ] Rollback entendible

## 4. Enforcement: no se confía, se bloquea

| Regla | Mecanismo |
|---|---|
| No push directo a `main` | `pre-push` (bloqueo) |
| No force push a `main`/`develop` | `pre-push` (bloqueo, override `ALLOW_FORCE=1`) |
| No `.env` reales / secretos | `pre-commit` (bloqueo) + plugin opencode |
| Cambios de infra | `pre-commit` (aviso) |

Overrides de emergencia, siempre documentados:
`ALLOW_MAIN=1`, `ALLOW_FORCE=1`, `git commit --no-verify`.
