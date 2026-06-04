import type { Plugin } from "@opencode-ai/plugin";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";

/**
 * rules-enforcer — refuerza OPERATING_RULES.md a nivel del agente.
 *
 * Complementa los git hooks: los frena ANTES de ejecutar el comando, con un
 * mensaje que el agente entiende y puede corregir en la misma vuelta.
 *
 * Verifica:
 *   1. No push directo a la rama protegida (solo en repos con `develop`).
 *   2. Aviso ante cambios de infraestructura (documentar).
 *   3. Bloqueo de edicion de archivos .env reales.
 */

const PROTECTED = process.env.PROTECTED_BRANCH || "main";

function repoHasDevelopBranch(workdir?: string): boolean {
  const dir = workdir ?? process.cwd();
  const gitDir = join(dir, ".git");
  try {
    if (existsSync(join(gitDir, "refs", "heads", "develop"))) return true;
    if (existsSync(join(gitDir, "refs", "remotes", "origin", "develop"))) return true;
    const packed = readFileSync(join(gitDir, "packed-refs"), "utf8");
    if (packed.includes("refs/heads/develop") || packed.includes("refs/remotes/origin/develop")) return true;
  } catch {
    /* packed-refs puede no existir */
  }
  return false;
}

export default (async () => {
  return {
    "tool.execute.before": async (input, output) => {
      const tool = input.tool;
      const args = output.args || {};

      // 1) Bloquear push directo a la rama protegida
      if (tool === "bash" && args.command) {
        const cmd: string = args.command;
        const pushRe = new RegExp(`git\\s+push\\s+.*origin\\s+${PROTECTED}\\b`);
        if (pushRe.test(cmd) && repoHasDevelopBranch(input.args?.workdir)) {
          console.error(`[harness] BLOQUEADO: push directo a ${PROTECTED}`);
          console.error("[harness] Flujo correcto: rama -> PR a develop -> validar -> PR a " + PROTECTED);
          output.args.command =
            `echo "[harness] BLOQUEADO: push directo a ${PROTECTED} (ver OPERATING_RULES.md)" && exit 1`;
          return;
        }
        if (/git\s+push\s+.*--force/.test(cmd) && !/develop/.test(cmd)) {
          console.warn("[harness] AVISO: force push detectado. Si es rollback de emergencia, documentalo.");
        }
      }

      // 2) Aviso ante cambios de infraestructura
      if ((tool === "edit" || tool === "write") && args.filePath) {
        const path: string = args.filePath;
        const isInfra = [/docker-compose/, /Dockerfile/, /\.github\/workflows/, /nginx\.conf/, /\.tf$/]
          .some((re) => re.test(path));
        if (isInfra) {
          console.warn(`[harness] AVISO: cambio de infra: ${path}. Recorda sincronizar docs / openspec.`);
        }
      }

      // 3) Bloquear edicion de .env reales (permite plantillas)
      if ((tool === "edit" || tool === "write") && args.filePath) {
        const base = (args.filePath as string).split("/").pop() || (args.filePath as string);
        const isTemplate = /\.(example|docker|sample|template)$/.test(base);
        const isEnv = base === ".env" || /^\.env\./.test(base) || /\.env$/.test(base);
        if (isEnv && !isTemplate) {
          console.error(`[harness] BLOQUEADO: ${args.filePath} es un .env real`);
          throw new Error(
            `[harness] Edicion de .env real bloqueada: ${args.filePath}. Usa .env.example.`,
          );
        }
      }
    },
  };
}) satisfies Plugin;
