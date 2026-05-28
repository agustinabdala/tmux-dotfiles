# tmux-dotfiles

Mi setup de tmux para **trabajo remoto vía SSH** + **sesiones paralelas de Claude Code**, basado en [Oh My Tmux!](https://github.com/gpakosz/.tmux) con mis overrides en `tmux.conf.local`.

## Instalación en cualquier máquina

```bash
git clone https://github.com/agustinabdala/tmux-dotfiles.git ~/.dotfiles/tmux
cd ~/.dotfiles/tmux
./bootstrap.sh
tmux new -s main
```

El script:
1. Instala tmux si falta.
2. Clona `gpakosz/.tmux` en `~/.tmux` (o `git pull` si ya estaba).
3. Linkea `~/.tmux.conf` → `~/.tmux/.tmux.conf`.
4. Linkea `~/.tmux.conf.local` → mis overrides versionados (este repo).

Idempotente — corrélo de nuevo y queda actualizado.

## Lo esencial

- **Prefix:** `Ctrl + Espacio`
- **Recargar config:** `prefix + r`

### Panes y windows

| Acción | Atajo |
| --- | --- |
| Split vertical | `prefix + \|` |
| Split horizontal | `prefix + -` |
| Nueva window | `prefix + c` |
| Moverse entre panes | `Alt + flechas` (sin prefix) |
| Cambiar de window | `Alt + 1..9` (sin prefix) |
| Zoom pane a pantalla completa | `prefix + z` |
| Cerrar pane | `prefix + x` |

### Copy / paste

- **Mouse:** arrastrá para seleccionar → al soltar copia al portapapeles del sistema (OSC52).
- **Línea entera:** triple click sobre la línea.
- **Sin mouse:** `prefix + [` → flechas → `Space` para empezar selección → `Enter` para copiar.
- **Pegar dentro de tmux:** `prefix + ]`.
- **Pegar en apps locales:** `Ctrl+V` o `Ctrl+Shift+V`.
- **Si OSC52 falla** (terminal no soporta): mantené `Shift` mientras seleccionás con el mouse — eso usa la selección nativa del terminal.

## ¿Qué es OSC52?

Secuencia de escape que tmux emite cuando copiás. Tu **terminal local** (gnome-terminal, Alacritty, Kitty, iTerm2, WezTerm, Windows Terminal) la intercepta y mete el texto en el **portapapeles de tu máquina local**. Resultado: copiás en el server remoto, pegás con `Ctrl+V` en tu navegador local. Sin xclip, sin SSH agent forwarding.

## Overrides locales por máquina (sin tocar el repo)

Si querés ajustes específicos de un equipo, editá `tmux.conf.local` (versionado, este repo) o agregá un segundo archivo no versionado y `source-file`-eálo al final.

## Flujo recomendado (SSH + Claude Code)

1. `ssh server` → `tmux new -s rimvision`.
2. Lanzá Claude Code dentro de un pane.
3. `prefix + d` desconecta — Claude sigue corriendo en el server.
4. Más tarde: `ssh server && tmux attach -t rimvision`.

## Volver a empezar / desinstalar

```bash
rm -rf ~/.tmux ~/.tmux.conf ~/.tmux.conf.local
```
