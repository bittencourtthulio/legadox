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

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_SRC="$SRC/skill"
CMD_SRC="$SRC/commands"

GLOBAL=0; DO_CLAUDE=0; DO_OPENCODE=0; FORCE=0; DRY=0

for arg in "$@"; do
  case "$arg" in
    --global)   GLOBAL=1 ;;
    --claude)   DO_CLAUDE=1 ;;
    --opencode) DO_OPENCODE=1 ;;
    --force)    FORCE=1 ;;
    --dry-run)  DRY=1 ;;
    -h|--help)  sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "opcao desconhecida: $arg (use --help)" >&2; exit 1 ;;
  esac
done

# sem alvo explicito, instala nos dois
if [ "$DO_CLAUDE" -eq 0 ] && [ "$DO_OPENCODE" -eq 0 ]; then DO_CLAUDE=1; DO_OPENCODE=1; fi

[ -f "$SKILL_SRC/SKILL.md" ] || { echo "erro: $SKILL_SRC/SKILL.md nao encontrado" >&2; exit 1; }

say()  { printf '%s\n' "$*"; }
run()  { if [ "$DRY" -eq 1 ]; then say "   [dry-run] $*"; else "$@"; fi; }

install_target() {
  local harness="$1" skills_dir="$2" cmds_dir="$3"
  local skill_dest="$skills_dir/legadox"

  say ""
  say "→ $harness"
  say "   skill:    $skill_dest"
  say "   commands: $cmds_dir"

  if [ -e "$skill_dest" ] && [ "$FORCE" -eq 0 ]; then
    if [ -t 0 ]; then
      printf '   já existe. sobrescrever? [s/N] '
      read -r ans </dev/tty
      case "$ans" in [sSyY]*) ;; *) say "   pulado."; return 0 ;; esac
    else
      say "   já existe — pulado (use --force para sobrescrever)."
      return 0
    fi
  fi

  run mkdir -p "$skills_dir" "$cmds_dir"
  run rm -rf "$skill_dest"
  run cp -R "$SKILL_SRC" "$skill_dest"
  for f in "$CMD_SRC"/*.md; do run cp "$f" "$cmds_dir/$(basename "$f")"; done

  if [ "$DRY" -eq 0 ]; then
    local n_ref n_asset n_cmd
    n_ref=$(find "$skill_dest/references" -name '*.md' | wc -l | tr -d ' ')
    n_asset=$(find "$skill_dest/assets" -name '*.md' | wc -l | tr -d ' ')
    n_cmd=$(find "$cmds_dir" -name 'legadox*.md' | wc -l | tr -d ' ')
    say "   ok — SKILL.md + $n_ref references + $n_asset templates + $n_cmd comandos"
  fi
}

say "legadox — instalando ($([ "$GLOBAL" -eq 1 ] && echo global || echo projeto))"

if [ "$DO_CLAUDE" -eq 1 ]; then
  if [ "$GLOBAL" -eq 1 ]; then
    install_target "Claude Code" "$HOME/.claude/skills" "$HOME/.claude/commands"
  else
    install_target "Claude Code" ".claude/skills" ".claude/commands"
  fi
fi

if [ "$DO_OPENCODE" -eq 1 ]; then
  if [ "$GLOBAL" -eq 1 ]; then
    install_target "OpenCode" "$HOME/.config/opencode/skills" "$HOME/.config/opencode/commands"
  else
    install_target "OpenCode" ".opencode/skills" ".opencode/commands"
  fi
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
