// legadox — ponte de hooks para o OpenCode.
//
// A logica de cada hook mora UMA vez so, nos scripts de shell em hooks/legadox/.
// Este arquivo so traduz: recebe o evento do OpenCode, monta o mesmo JSON que o
// Claude Code entrega no stdin, invoca o script, e traduz a saida de volta.
//
// Duplicar a logica aqui criaria duas fontes divergindo com o tempo.
//
// Mapeamento dos mecanismos, conforme o contrato expx-eventos v1:
//
//   Claude Code                          OpenCode
//   PreToolUse, exit 2 bloqueia          tool.execute.before, lancar excecao
//   PreToolUse, aviso (exit 0 + stderr)  nao existe no before  -> vai para o after
//   PostToolUse, additionalContext       tool.execute.after, anexado ao output
//
// A lacuna real e o modo AVISO no before: o OpenCode so sabe passar em silencio ou
// lancar. Por isso o aviso e anexado no after, sempre prefixado, para o modelo nao
// confundir o aviso com a saida da propria ferramenta.

import { spawnSync } from "node:child_process"
import { existsSync } from "node:fs"
import { join } from "node:path"

const FERRAMENTAS_DE_ESCRITA = new Set(["write", "edit", "multiedit", "patch"])

// Ordem importa: os dois primeiros nascem em bloqueio.
const HOOKS_PRE = [
  "zona-de-risco",
  "aprovacao-em-raio-alto",
  "caracterizacao-antes",
  "orcamento-de-mudanca",
  "raio-antes-do-plano",
  "reversao-declarada",
]
const HOOKS_POST = ["sem-colateral"]

function dirDosHooks(raiz) {
  for (const base of [".opencode", ".claude"]) {
    const d = join(raiz, base, "hooks", "legadox")
    if (existsSync(join(d, "comum", "legadox-comum.sh"))) return d
  }
  return null
}

// O OpenCode usa filePath (camelCase); os scripts esperam o formato do Claude Code.
function montarEvento(nomeEvento, ferramenta, args) {
  const a = args || {}
  return JSON.stringify({
    hook_event_name: nomeEvento,
    tool_name: ferramenta,
    cwd: process.cwd(),
    tool_input: {
      file_path: a.filePath ?? a.file_path ?? a.path ?? "",
      content: a.content ?? "",
      new_string: a.newString ?? a.new_string ?? "",
    },
  })
}

function rodar(script, evento, raiz) {
  const r = spawnSync("bash", [script], {
    input: evento,
    encoding: "utf8",
    timeout: 10000,
    env: { ...process.env, CLAUDE_PROJECT_DIR: raiz },
  })
  // Regra 3 do contrato: hook de metodo que quebra nao trava o trabalho.
  if (r.error) return { codigo: 0, stderr: "", stdout: "" }
  return { codigo: r.status ?? 0, stderr: r.stderr || "", stdout: r.stdout || "" }
}

// O aviso do PostToolUse vem como JSON no stdout; o do PreToolUse, em stderr.
function extrairTexto({ stdout, stderr }) {
  if (stdout) {
    try {
      const j = JSON.parse(stdout)
      const t = j?.hookSpecificOutput?.additionalContext
      if (t) return t
    } catch {
      /* stdout que nao e JSON: cai para o stderr */
    }
  }
  return stderr.trim()
}

export const LegadoxPlugin = async ({ directory }) => {
  const raiz = directory || process.cwd()
  const dir = dirDosHooks(raiz)
  if (!dir) return {}

  // Avisos colhidos no before, entregues no after (ver nota do topo).
  const pendentes = []

  return {
    "tool.execute.before": async (input, output) => {
      const ferramenta = String(input?.tool || "").toLowerCase()
      if (!FERRAMENTAS_DE_ESCRITA.has(ferramenta)) return

      const evento = montarEvento("PreToolUse", input.tool, output?.args)

      for (const nome of HOOKS_PRE) {
        const script = join(dir, `${nome}.sh`)
        if (!existsSync(script)) continue

        const r = rodar(script, evento, raiz)
        const texto = extrairTexto(r)

        // exit 2 = bloqueio. No OpenCode, bloquear e lancar.
        if (r.codigo === 2) {
          throw new Error(
            `[legadox/${nome} — acao bloqueada]\n${texto || "regra do legadox violada"}`,
          )
        }
        // exit 0 com mensagem = aviso: nao bloqueia, e entregue no after.
        if (texto) pendentes.push(texto)
      }
    },

    "tool.execute.after": async (input, output) => {
      const ferramenta = String(input?.tool || "").toLowerCase()
      if (!FERRAMENTAS_DE_ESCRITA.has(ferramenta)) return

      const evento = montarEvento("PostToolUse", input.tool, input?.args)

      for (const nome of HOOKS_POST) {
        const script = join(dir, `${nome}.sh`)
        if (!existsSync(script)) continue
        const texto = extrairTexto(rodar(script, evento, raiz))
        if (texto) pendentes.push(texto)
      }

      if (pendentes.length === 0) return
      const aviso = pendentes.splice(0).join("\n\n")
      output.title = output.title || ""
      output.output =
        `${output.output || ""}\n\n[legadox/hooks — aviso, a acao NAO foi bloqueada]\n${aviso}`
    },
  }
}

export default LegadoxPlugin
