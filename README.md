# tmux-dotfiles

Mi config de tmux, pensada para **trabajo remoto vía SSH** y **sesiones paralelas de Claude Code**. Sin keybinds estilo vim; copy/paste con el portapapeles nativo del terminal y soporte de clipboard sobre SSH (OSC52).

## Instalación en cualquier máquina

```bash
git clone https://github.com/agustinabdala/tmux-dotfiles.git ~/.dotfiles/tmux
cd ~/.dotfiles/tmux
./bootstrap.sh
```

El script instala tmux (si falta), instala TPM, linkea `tmux.conf` a `~/.tmux.conf` (haciendo backup si ya tenías uno) e instala los plugins. Idempotente: corrélo las veces que quieras.

Si ya estás dentro de tmux después de clonar:

```bash
tmux source ~/.tmux.conf   # y prefix + I para instalar plugins
```

## Lo esencial

- **Prefix:** `Ctrl + Espacio`
- **Recargar config:** `prefix + r`
- **Instalar / actualizar plugins:** `prefix + I` / `prefix + U`

### Panes y windows

| Acción | Atajo |
| --- | --- |
| Split vertical | `prefix + \|` |
| Split horizontal | `prefix + -` |
| Nueva window | `prefix + c` |
| Moverse entre panes | `Alt + flechas` (sin prefix) o `prefix + flechas` |
| Redimensionar pane | `prefix + Shift + flechas` |
| Zoom pane a pantalla completa | `prefix + z` |
| Cambiar de window | `Alt + 1..9` |
| Shell flotante temporal | `prefix + g` |
| Sesión scratch persistente | `prefix + G` |

### Copy / paste

- **Nativo del terminal:** mantené `Shift` mientras seleccionás con el mouse, después `Ctrl+Shift+C` para copiar y `Ctrl+Shift+V` para pegar.
- **Vía tmux:** seleccioná arrastrando el mouse (sin Shift) — al soltar copia al portapapeles del sistema (OSC52, funciona sobre SSH). Pegar con `prefix + ]`.

> El clipboard sobre SSH necesita que tu terminal local soporte OSC52. gnome-terminal, Tilix y la mayoría de los modernos lo hacen.

## Plugins incluidos

| Plugin | Para qué |
| --- | --- |
| tpm | gestor de plugins |
| tmux-sensible | defaults razonables |
| tmux-resurrect | guarda/restaura sesiones manualmente |
| tmux-continuum | autosave de sesiones cada 5 min + restore automático |
| tmux-yank | copiar al portapapeles del sistema |
| tmux-suspend | `F12` suspende el tmux local para trabajar con tmux remoto anidado |
| tmux-current-pane-hostname | muestra `user@host` en el status bar |
| tmux-prefix-highlight | avisa visualmente cuando el prefix está activo |
| tmux-notify | `prefix + m` avisa cuando termina un proceso largo |
| tmux-window-name | nombra las windows según lo que corre |

### Plugins opcionales (comentados en `tmux.conf`)

Requieren dependencias extra; descomentalos y agregá las deps en `bootstrap.sh`:

- **tmux-sessionx** — gestor de sesiones con preview (necesita `fzf`, `zoxide`)
- **tmux-thumbs** — copiar paths/hashes con hints estilo Vimium (necesita `cargo`)
- **extrakto** — fuzzy extract del scrollback con `prefix + Tab` (necesita `fzf`)

## Overrides por máquina

Para ajustes específicos de un equipo sin tocar el config versionado, creá `~/.tmux.conf.local`. Se carga automáticamente al final. Ejemplo típico en un server:

```bash
# ~/.tmux.conf.local
set -g status-right "#[fg=#f38ba8] PROD #[fg=#94e2d5]#(whoami)@#H #[fg=#f9e2af]%H:%M "
```

## Flujo recomendado (SSH + Claude Code)

1. `ssh server` y abrí una sesión nombrada por proyecto: `tmux new -s rimvision`
2. Lanzá Claude Code dentro de un pane (queda corriendo en el server).
3. `prefix + d` para desconectar — Claude sigue trabajando aunque cierres el SSH.
4. Más tarde: `ssh server && tmux attach -t rimvision`.

Con `tmux-continuum` activo, incluso si el server se reinicia, al volver a entrar tus sesiones se restauran solas.
