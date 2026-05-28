#!/usr/bin/env bash
# ============================================================
#  bootstrap.sh — instala esta config de tmux en cualquier máquina
#  Uso:   ./bootstrap.sh
#  Idempotente: podés correrlo las veces que quieras.
# ============================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TPM_DIR="$HOME/.tmux/plugins/tpm"

info()  { printf "\033[0;34m[*]\033[0m %s\n" "$1"; }
ok()    { printf "\033[0;32m[✓]\033[0m %s\n" "$1"; }
warn()  { printf "\033[0;33m[!]\033[0m %s\n" "$1"; }

# ------------------------------------------------------------
# 1. Instalar tmux si falta
# ------------------------------------------------------------
if ! command -v tmux >/dev/null 2>&1; then
  warn "tmux no está instalado. Intentando instalarlo..."
  if   command -v apt    >/dev/null 2>&1; then sudo apt update && sudo apt install -y tmux
  elif command -v dnf    >/dev/null 2>&1; then sudo dnf install -y tmux
  elif command -v pacman >/dev/null 2>&1; then sudo pacman -S --noconfirm tmux
  elif command -v brew   >/dev/null 2>&1; then brew install tmux
  else warn "No detecté gestor de paquetes. Instalá tmux a mano y volvé a correr esto."; exit 1
  fi
fi
ok "tmux $(tmux -V | awk '{print $2}') disponible"

# ------------------------------------------------------------
# 2. Instalar TPM (Tmux Plugin Manager)
# ------------------------------------------------------------
if [ ! -d "$TPM_DIR" ]; then
  info "Clonando TPM..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
fi
ok "TPM instalado"

# ------------------------------------------------------------
# 3. Linkear tmux.conf (con backup del existente)
# ------------------------------------------------------------
if [ -e "$HOME/.tmux.conf" ] && [ ! -L "$HOME/.tmux.conf" ]; then
  BACKUP="$HOME/.tmux.conf.backup.$(date +%Y%m%d%H%M%S)"
  warn "Ya existe ~/.tmux.conf — lo guardo en $BACKUP"
  mv "$HOME/.tmux.conf" "$BACKUP"
fi
ln -sf "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"
ok "~/.tmux.conf -> $DOTFILES_DIR/tmux.conf"

# ------------------------------------------------------------
# 4. (Opcional) deps para plugins comentados
#    Descomentá lo que quieras usar.
# ------------------------------------------------------------
# install_opt() { command -v "$1" >/dev/null 2>&1 || warn "Para algunos plugins instalá: $1"; }
# install_opt fzf      # tmux-sessionx, extrakto
# install_opt zoxide   # tmux-sessionx
# install_opt fpp      # tmux-fpp
# install_opt cargo    # tmux-thumbs (rust)

# ------------------------------------------------------------
# 5. Instalar plugins vía TPM (sin abrir tmux interactivo)
# ------------------------------------------------------------
info "Instalando plugins..."
"$TPM_DIR/bin/install_plugins" || warn "Si falló, abrí tmux y apretá prefix + I"
ok "Plugins instalados"

echo
ok "Listo. Abrí tmux (o 'tmux source ~/.tmux.conf' si ya estás dentro)."
echo "   Prefix = Ctrl+Espacio   |   prefix + r recarga la config"
