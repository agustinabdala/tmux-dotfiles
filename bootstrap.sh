#!/usr/bin/env bash
# ============================================================
#  bootstrap.sh — instala Oh My Tmux + mis overrides
#  Uso:   ./bootstrap.sh
#  Idempotente.
# ============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OMT_DIR="$HOME/.tmux"
OMT_REPO="https://github.com/gpakosz/.tmux.git"

info()  { printf "\033[0;34m[*]\033[0m %s\n" "$1"; }
ok()    { printf "\033[0;32m[✓]\033[0m %s\n" "$1"; }
warn()  { printf "\033[0;33m[!]\033[0m %s\n" "$1"; }

# 1. tmux
if ! command -v tmux >/dev/null 2>&1; then
  warn "tmux no instalado — intento instalarlo"
  if   command -v apt    >/dev/null 2>&1; then sudo apt update && sudo apt install -y tmux
  elif command -v dnf    >/dev/null 2>&1; then sudo dnf install -y tmux
  elif command -v pacman >/dev/null 2>&1; then sudo pacman -S --noconfirm tmux
  elif command -v brew   >/dev/null 2>&1; then brew install tmux
  else warn "Instalá tmux a mano y volvé a correr esto"; exit 1
  fi
fi
ok "tmux $(tmux -V | awk '{print $2}') disponible"

# 2. Clonar / actualizar gpakosz/.tmux  (Oh My Tmux!)
if [ -d "$OMT_DIR/.git" ]; then
  info "Actualizando Oh My Tmux..."
  git -C "$OMT_DIR" pull --ff-only
else
  if [ -e "$OMT_DIR" ]; then
    BACKUP="$OMT_DIR.backup.$(date +%Y%m%d%H%M%S)"
    warn "Ya existe $OMT_DIR sin git — lo muevo a $BACKUP"
    mv "$OMT_DIR" "$BACKUP"
  fi
  info "Clonando Oh My Tmux en $OMT_DIR..."
  git clone --depth 1 "$OMT_REPO" "$OMT_DIR"
fi
ok "Oh My Tmux listo"

# 3. Symlink ~/.tmux.conf -> Oh My Tmux config
if [ -e "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
  BACKUP="$HOME/.tmux.conf.backup.$(date +%Y%m%d%H%M%S)"
  warn "~/.tmux.conf existe — backup en $BACKUP"
  mv "$HOME/.tmux.conf" "$BACKUP"
fi
ln -sf "$OMT_DIR/.tmux.conf" "$HOME/.tmux.conf"
ok "~/.tmux.conf -> $OMT_DIR/.tmux.conf"

# 4. Symlink ~/.tmux.conf.local -> mis overrides versionados
if [ -e "$HOME/.tmux.conf.local" ] && [ ! -L "$HOME/.tmux.conf.local" ]; then
  BACKUP="$HOME/.tmux.conf.local.backup.$(date +%Y%m%d%H%M%S)"
  warn "~/.tmux.conf.local existe — backup en $BACKUP"
  mv "$HOME/.tmux.conf.local" "$BACKUP"
fi
ln -sf "$DOTFILES_DIR/tmux.conf.local" "$HOME/.tmux.conf.local"
ok "~/.tmux.conf.local -> $DOTFILES_DIR/tmux.conf.local"

# 5. Plugins: Oh My Tmux los autoinstala al iniciar tmux.
#    Disparamos una sesión efímera y esperamos a que terminen los clones.
info "Instalando plugins (TPM auto-install vía Oh My Tmux)..."
EPHEMERAL="_bootstrap_$$"
if tmux new-session -d -s "$EPHEMERAL" -x 200 -y 50 2>/dev/null; then
  # esperamos hasta 60s a que aparezcan los plugins declarados en tmux.conf.local
  for i in $(seq 1 30); do
    sleep 2
    plugin_count=$(find "$HOME/.tmux/plugins" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l)
    [ "$plugin_count" -ge 4 ] && break   # tpm + 3 plugins
  done
  tmux kill-session -t "$EPHEMERAL" 2>/dev/null || true
  ok "Plugins listos ($plugin_count en ~/.tmux/plugins)"
else
  warn "No pude arrancar tmux efímero; los plugins se instalarán solos al abrir tmux"
fi

# 6. claude-workspace.sh accesible globalmente
if [ -d "$HOME/.local/bin" ] || mkdir -p "$HOME/.local/bin" 2>/dev/null; then
  ln -sf "$DOTFILES_DIR/claude-workspace.sh" "$HOME/.local/bin/claude-workspace"
  ok "claude-workspace -> ~/.local/bin/claude-workspace"
  case ":$PATH:" in
    *:"$HOME/.local/bin":*) ;;
    *) warn "Agregá ~/.local/bin a tu PATH para usar 'claude-workspace' directo" ;;
  esac
fi

echo
ok "Listo. Abrí tmux con: tmux new -s main"
echo "   Prefix = Ctrl+Espacio   |   prefix + r recarga"
echo "   Workspace de proyecto:  claude-workspace ~/path/al/proyecto"
