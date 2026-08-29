#!/usr/bin/env bash
# legadox — instalador para Claude Code e OpenCode.
#
#   ./install.sh                  instala nos dois harnesses, no projeto atual
#   ./install.sh --global         instala nos dois, no diretorio global do usuario
#   ./install.sh --claude         só Claude Code
#   ./install.sh --opencode       só OpenCode
#   ./install.sh --global --claude   combinacoes valem
#   ./install.sh --force          sobrescreve instalacao existente sem perguntar
#   ./install.sh --dry-run        mostra o que faria, sem escrever nada
#
# Sem --claude/--opencode, instala nos dois.
#
# O repositorio ja publica as arvores no formato de cada harness — .claude/ e
# .opencode/ — entao instalar e copiar arvore para arvore. A unica parte que nao e
# copia e o settings.json do Claude Code, que pertence ao usuario e por isso e
# MESCLADO, nunca sobrescrito.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SRC="$SRC/.claude"
OPENCODE_SRC="$SRC/.opencode"

GLOBAL=0; DO_CLAUDE=0; DO_OPENCODE=0; FORCE=0; DRY=0

for arg in "$@"; do
  case "$arg" in
    --global)   GLOBAL=1 ;;
    --claude)   DO_CLAUDE=1 ;;
    --opencode) DO_OPENCODE=1 ;;
    --force)    FORCE=1 ;;
    --dry-run)  DRY=1 ;;
    -h|--help)  sed -n '2,13p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "opcao desconhecida: $arg (use --help)" >&2; exit 1 ;;
  esac
done

# sem alvo explicito, instala nos dois
if [ "$DO_CLAUDE" -eq 0 ] && [ "$DO_OPENCODE" -eq 0 ]; then DO_CLAUDE=1; DO_OPENCODE=1; fi

[ -f "$CLAUDE_SRC/skills/legadox/SKILL.md" ] \
  || { echo "erro: $CLAUDE_SRC/skills/legadox/SKILL.md nao encontrado" >&2; exit 1; }

say()  { printf '%s\n' "$*"; }
run()  { if [ "$DRY" -eq 1 ]; then say "   [dry-run] $*"; else "$@"; fi; }

# Copia as partes do legadox de uma arvore para a outra, sem tocar no que e do
# usuario. Cada destino e substituido por inteiro (a skill instalada e artefato),
# mas nada fora desses caminhos e removido.
copiar_arvore() {
  local origem="$1"
  local destino="$2"
  local sub

  for sub in agents commands skills hooks plugin; do
    [ -d "$origem/$sub" ] || continue

    case "$sub" in
      # Estes vivem em subpasta propria do legadox: troca so a nossa.
      skills|hooks)
        run mkdir -p "$destino/$sub"
        run rm -rf "$destino/$sub/legadox"
        run cp -R "$origem/$sub/legadox" "$destino/$sub/legadox"
        ;;
      # Aqui os arquivos convivem com os do usuario: copia um a um.
      *)
        run mkdir -p "$destino/$sub"
        local f
        for f in "$origem/$sub"/*; do
          [ -e "$f" ] || continue
          run cp -R "$f" "$destino/$sub/$(basename "$f")"
        done
        ;;
    esac
  done

  [ "$DRY" -eq 0 ] && chmod +x "$destino"/hooks/legadox/*.sh 2>/dev/null || true
  return 0
}

# O modo de cada hook (aviso/bloqueio) e decisao do time, tomada a partir do que o
# painel acumulou. O instalador so cria o arquivo se ele ainda nao existir.
instalar_modos() {
  local origem="$1"
  local padrao="$origem/hooks/legadox/modos.padrao.json"
  [ -f "$padrao" ] || return 0
  if [ -f ".expx/hooks.json" ]; then
    say "   .expx/hooks.json ja existe — preservado (os modos sao decisao do time)"
  else
    run mkdir -p ".expx"
    run cp "$padrao" ".expx/hooks.json"
  fi
}

# Mescla os hooks do legadox no settings.json do usuario, preservando o que ja
# existe. Sem jq nao ha merge seguro: nesse caso escreve o fragmento ao lado e
# explica, em vez de arriscar o arquivo do usuario.
merge_settings_claude() {
  local base="${1:-}"
  [ -n "$base" ] || return 0
  local alvo="$base/settings.json"
  local frag="$CLAUDE_SRC/settings.json"
  [ -f "$frag" ] || return 0

  if [ "$DRY" -eq 1 ]; then say "   [dry-run] mesclaria hooks em $alvo"; return 0; fi

  # O caminho dos scripts muda conforme o escopo da instalacao.
  local prefixo=".claude/hooks/legadox"
  [ "$GLOBAL" -eq 1 ] && prefixo="$HOME/.claude/hooks/legadox"

  local tmp_frag; tmp_frag="$(mktemp)"
  sed "s#\.claude/hooks/legadox#$prefixo#g" "$frag" > "$tmp_frag"

  if ! command -v jq >/dev/null 2>&1; then
    cp "$tmp_frag" "$base/hooks-legadox.json"; rm -f "$tmp_frag"
    say "   ! jq nao encontrado — hooks NAO foram mesclados."
    say "     O fragmento ficou em $base/hooks-legadox.json; copie o bloco \"hooks\""
    say "     para o seu settings.json a mao."
    return 0
  fi

  mkdir -p "$base"
  [ -f "$alvo" ] || echo '{}' > "$alvo"
  cp "$alvo" "$alvo.bak-legadox"

  local tmp_out; tmp_out="$(mktemp)"
  # Remove entradas antigas do legadox (reinstalacao) e acrescenta as novas,
  # preservando integralmente os hooks de terceiros no mesmo matcher.
  if jq -s '
      .[0] as $atual | .[1] as $novo
      | ($atual.hooks // {}) as $h
      | reduce ($novo.hooks | keys[]) as $ev (
          $atual;
          .hooks[$ev] = (
            (($h[$ev] // [])
              | map(.hooks |= map(select((.command // "") | contains("hooks/legadox") | not)))
              | map(select((.hooks | length) > 0)))
            + $novo.hooks[$ev]
          )
        )
    ' "$alvo" "$tmp_frag" > "$tmp_out" 2>/dev/null && [ -s "$tmp_out" ]; then
    mv "$tmp_out" "$alvo"
    say "   settings.json mesclado (backup em settings.json.bak-legadox)"
  else
    rm -f "$tmp_out"
    cp "$tmp_frag" "$base/hooks-legadox.json"
    say "   ! nao foi possivel mesclar o settings.json — nada foi alterado."
    say "     O fragmento ficou em $base/hooks-legadox.json."
  fi
  rm -f "$tmp_frag"
}

# Pergunta antes de sobrescrever instalacao existente, como antes.
confirmar_sobrescrita() {
  local destino="$1"
  [ -e "$destino/skills/legadox" ] || return 0
  [ "$FORCE" -eq 1 ] && return 0
  if [ -t 0 ]; then
    printf '   já existe. sobrescrever? [s/N] '
    read -r ans </dev/tty
    case "$ans" in [sSyY]*) return 0 ;; *) say "   pulado."; return 1 ;; esac
  fi
  say "   já existe — pulado (use --force para sobrescrever)."
  return 1
}

instalar_harness() {
  local nome="$1" origem="$2" destino="$3"

  say ""
  say "→ $nome"
  say "   destino: $destino"

  # Rodar o instalador dentro do proprio repositorio do legadox copiaria a arvore
  # sobre ela mesma. Nao ha o que instalar: a fonte ja esta no lugar.
  local abs_destino
  abs_destino="$(cd "$(dirname "$destino")" 2>/dev/null && pwd)/$(basename "$destino")" || abs_destino=""
  if [ -n "$abs_destino" ] && [ "$abs_destino" = "$origem" ]; then
    say "   é a propria fonte — nada a fazer."
    return 0
  fi

  confirmar_sobrescrita "$destino" || return 0

  copiar_arvore "$origem" "$destino"
  instalar_modos "$origem"

  if [ "$DRY" -eq 0 ]; then
    local n_sk n_cmd n_ag n_hk
    n_sk=$(find "$destino/skills/legadox" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    n_cmd=$(find "$destino/commands" -name 'legadox*.md' 2>/dev/null | wc -l | tr -d ' ')
    n_ag=$(find "$destino/agents" -name '*.md' 2>/dev/null | wc -l | tr -d ' ')
    n_hk=$(find "$destino/hooks/legadox" -name '*.sh' 2>/dev/null | wc -l | tr -d ' ')
    say "   ok — $n_sk arquivos de skill, $n_cmd comandos, $n_ag agentes, $n_hk hooks"
  fi
}

say "legadox — instalando ($([ "$GLOBAL" -eq 1 ] && echo global || echo projeto))"

if [ "$DO_CLAUDE" -eq 1 ]; then
  if [ "$GLOBAL" -eq 1 ]; then
    instalar_harness "Claude Code" "$CLAUDE_SRC" "$HOME/.claude"
    merge_settings_claude "$HOME/.claude"
  else
    instalar_harness "Claude Code" "$CLAUDE_SRC" ".claude"
    merge_settings_claude ".claude"
  fi
fi

if [ "$DO_OPENCODE" -eq 1 ]; then
  if [ "$GLOBAL" -eq 1 ]; then
    instalar_harness "OpenCode" "$OPENCODE_SRC" "$HOME/.config/opencode"
  else
    instalar_harness "OpenCode" "$OPENCODE_SRC" ".opencode"
  fi
  # No OpenCode nao ha settings.json a mesclar: os hooks entram pelo plugin em
  # plugin/legadox.js, que o proprio OpenCode carrega sozinho.
fi

# AGENTS.md: e por ele que o agente do OpenCode sabe que deve acionar a skill
if [ "$GLOBAL" -eq 0 ] && [ -f "$SRC/AGENTS.md" ] && [ ! -f "AGENTS.md" ]; then
  say ""
  run cp "$SRC/AGENTS.md" "AGENTS.md"
  [ "$DRY" -eq 0 ] && say "→ AGENTS.md copiado para a raiz do projeto"
fi

say ""
say "Reinicie a sessao do seu harness para a skill ser carregada."
say "Depois rode /legadox-perfil para gerar o mapa do projeto e ligar o modo legado."
