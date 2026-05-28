#!/usr/bin/env bash
# ============================================================
#  claude-workspace — abre una sesión tmux lista para Claude Code
#
#  Uso:    claude-workspace [path-al-proyecto] [nombre-sesion]
#  Default path:    cwd
#  Default sesion:  basename del path
#
#  Layout (window 1 "code"):
#    +------------------------+----------------+
#    |                        |                |
#    |  shell (editor, etc.)  |   claude code  |
#    |                        |                |
#    +------------------------+----------------+
#                             |    logs/test   |
#                             +----------------+
#
#  Window 2 "git":  shell con git status
# ============================================================
set -euo pipefail

PROJECT_PATH="${1:-$PWD}"
PROJECT_PATH="$(cd "$PROJECT_PATH" && pwd)"
SESSION="${2:-$(basename "$PROJECT_PATH")}"
# tmux no admite . o : en nombres
SESSION="$(echo "$SESSION" | tr '.:' '__')"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  exec tmux attach -t "$SESSION"
fi

# Window 1: code (shell izq 60%, claude arriba-der 60%, logs abajo-der 40%)
tmux new-session  -d -s "$SESSION" -n "code" -c "$PROJECT_PATH"
tmux split-window -h -p 40 -t "$SESSION:code" -c "$PROJECT_PATH"
tmux split-window -v -p 40 -t "$SESSION:code.2" -c "$PROJECT_PATH"

# Lanzá claude en el pane de arriba-derecha si está instalado
if command -v claude >/dev/null 2>&1; then
  tmux send-keys -t "$SESSION:code.2" "claude" C-m
fi

# Window 2: git
tmux new-window -t "$SESSION:" -n "git" -c "$PROJECT_PATH"
tmux send-keys  -t "$SESSION:git" "git status" C-m

# Foco en el pane shell de la window code
tmux select-window -t "$SESSION:code"
tmux select-pane   -t "$SESSION:code.1"

exec tmux attach -t "$SESSION"
