# Debian 13 + Sway Run Book (Minimal & Intentional Setup)

---

## 1. Base System

During the Debian installer:

- Select **SSH server**
- Select **standard system utilities**
- Do **not** select a desktop environment

---

## 2. Core Tools

```bash
sudo apt update && sudo apt install -y \
  build-essential git curl wget unzip p7zip-full \
  htop vim tmux stow tree jq fzf ripgrep bat fd-find \
  firefox-esr
```

---

## 3. Sway & Wayland Core

```bash
sudo apt install -y \
  sway swaylock swayidle swaybg waybar wl-clipboard xwayland grim slurp
```

---

## 4. Portals for Flatpak, Pickers, Sharing

```bash
sudo apt install -y \
  xdg-desktop-portal xdg-desktop-portal-wlr
```

---

## 5. Terminals & Editor

```bash
sudo apt install -y \
  foot kitty pluma
```

---

## 6. Files & Storage

```bash
sudo apt install -y \
  thunar thunar-volman thunar-archive-plugin \
  tumbler ffmpegthumbnailer \
  gvfs gvfs-backends gvfs-fuse \
  udisks2 file-roller udiskie \
  gnome-disk-utility
```

---

## 7. Fonts & Theming

```bash
sudo apt install -y \
  fonts-dejavu fonts-noto fonts-noto-color-emoji \
  fonts-font-awesome nwg-look
```

---

## 8. Audio & Notifications

```bash
sudo apt install -y \
  pipewire pipewire-audio wireplumber libspa-0.2-bluetooth \
  alsa-utils sway-notification-center pavucontrol libnotify-bin
```

---

## 9. Bluetooth

```bash
sudo apt install -y \
  bluez blueman
```

---

## 10. Network

```bash
sudo apt install -y \
  network-manager
```

---

## 11. PolicyKit Agent

```bash
sudo apt install -y \
  lxqt-policykit
```

---

## 12. Media Tools

```bash
sudo apt install -y \
  qimgv mpv
```

---

## 13. Launchers & Utilities

```bash
sudo apt install -y \
  wofi wlogout swappy cliphist
```

---

## 14. Power & Display

```bash
sudo apt install -y \
  brightnessctl gammastep
```

---

## 15. Flatpak

```bash
sudo apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
```

---

## 16. Post-install Setup

### Aliases for Debian naming

```bash
echo "alias bat='batcat'" >> ~/.bashrc
echo "alias fd='fdfind'" >> ~/.bashrc
```

### Starting Sway

**Option A: Auto-start from TTY (no display manager)**

```bash
echo 'if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = "1" ]; then
  exec sway
fi' >> ~/.bash_profile
```

**Option B: With greetd + tuigreet**

```bash
sudo apt install -y greetd tuigreet
sudo systemctl enable --now greetd
# Edit /etc/greetd/config.toml to run: exec "sway"
```

### Sway config essentials

Create or extend `~/.config/sway/config`:

```conf
# Background
exec_always --no-startup-id swaybg -i /usr/share/backgrounds/gnome/adwaita-day.png -m fill

# Idle + lock
exec --no-startup-id swayidle -w \
  timeout 300 'swaylock -f -c 000000' \
  timeout 600 'swaymsg "output * power off"' \
  resume 'swaymsg "output * power on"' \
  before-sleep 'swaylock -f -c 000000'

# Notifications
exec --no-startup-id swaync

# Network applet
exec --no-startup-id nm-applet --indicator

# Bluetooth applet
exec --no-startup-id blueman-applet

# Automount USB devices
exec --no-startup-id udiskie -t

# Status bar
exec --no-startup-id waybar
```

### Daily Workflow

- **System updates:**
  ```bash
  sudo apt update && sudo apt full-upgrade -y
  ```

- **Flatpak updates:**
  ```bash
  flatpak update -y
  ```

- **Service management:**
  ```bash
  # Check statuses
  systemctl --user status pipewire wireplumber
  systemctl status NetworkManager
  systemctl status bluetooth

  # Restart if needed
  systemctl --user restart pipewire
  sudo systemctl restart NetworkManager
  sudo systemctl restart bluetooth
  ```

- **Power management & brightness:**
  ```bash
  # Lower brightness to 50%
  brightnessctl set 50%

  # Night light (e.g., 4500K)
  gammastep -O 4500
  ```

---

# Package Inventory (with one-line explanations)

### Base
- **build-essential** – Compiler and build tools (gcc, g++, make).  
- **git** – Distributed version control system.  
- **curl** – Transfers data via URLs.  
- **wget** – Downloads files from the web.  
- **unzip** – Extract `.zip` archives.  
- **p7zip-full** – Tools for `.7z` and other archive formats.  
- **htop** – Interactive process monitor.  
- **vim** – Text editor.  
- **tmux** – Terminal multiplexer.  
- **stow** – Symlink manager (useful for dotfiles).  
- **tree** – Directory tree viewer.  
- **jq** – JSON processor.  
- **fzf** – Fuzzy finder for the command line.  
- **ripgrep (rg)** – Fast text search across files.  
- **bat** – `cat` alternative with syntax highlighting (`batcat` binary).  
- **fd-find** – Fast file search (`fdfind` binary).  
- **firefox-esr** – Web browser (for GitHub and general browsing).  

### Sway & Wayland
- **sway** – Wayland tiling window manager.  
- **swaylock** – Screen locker.  
- **swayidle** – Idle timeout manager.  
- **swaybg** – Wallpaper setter.  
- **waybar** – Status bar for Wayland.  
- **wl-clipboard** – Wayland clipboard utilities (`wl-copy`, `wl-paste`).  
- **xwayland** – Run X11 apps under Wayland.  
- **grim** – Screenshot tool.  
- **slurp** – Region selector (for screenshots/screen recording).  

### Portals
- **xdg-desktop-portal** – Portal service for sandboxed apps.  
- **xdg-desktop-portal-wlr** – Wayland portal backend for Sway.  

### Terminals & Editor
- **foot** – Lightweight Wayland terminal.  
- **kitty** – GPU-accelerated terminal emulator.  
- **pluma** – MATE’s simple text editor.  

### Files & Storage
- **thunar** – Lightweight file manager.  
- **thunar-volman** – Automount support in Thunar.  
- **thunar-archive-plugin** – Archive integration.  
- **tumbler** – Thumbnail generation service.  
- **ffmpegthumbnailer** – Thumbnails for video files.  
- **gvfs, gvfs-backends, gvfs-fuse** – Virtual filesystem & mounting support.  
- **udisks2** – Disk management service (needed for automount).  
- **file-roller** – GUI archive manager.  
- **udiskie** – Automount tool for removable media.  
- **gnome-disk-utility** – Disk/partition management GUI.  

### Fonts & Theming
- **fonts-dejavu** – Common sans/serif/mono font family.  
- **fonts-noto** – Comprehensive Unicode font family.  
- **fonts-noto-color-emoji** – Color emoji support.  
- **fonts-font-awesome** – Icon font for status bars/GTK themes.  
- **nwg-look** – GTK theme switcher for Wayland.  

### Audio & Notifications
- **pipewire** – Modern audio/video server.  
- **pipewire-audio** – PipeWire audio support.  
- **wireplumber** – PipeWire session manager.  
- **libspa-0.2-bluetooth** – Bluetooth audio support.  
- **alsa-utils** – ALSA mixer and sound tools.  
- **sway-notification-center (swaync)** – Wayland notification daemon.  
- **pavucontrol** – GTK volume control/mixer.  
- **libnotify-bin** – Command-line tool `notify-send` for desktop notifications.  

### Bluetooth
- **bluez** – Linux Bluetooth stack.  
- **blueman** – Bluetooth manager UI.  

### Network
- **network-manager** – Network connection manager.  

### Media
- **qimgv** – Lightweight image viewer.  
- **mpv** – Media player.  

### Launchers & Utilities
- **wofi** – Wayland application launcher (used for Mod+D).  
- **wlogout** – Logout/power menu for Wayland.  
- **swappy** – Wayland screenshot editor.  
- **cliphist** – Clipboard manager for wl-clipboard.  

### Power & Display
- **brightnessctl** – Control screen backlight brightness.  
- **gammastep** – Night-light style color temperature adjustment.  

### Flatpak
- **flatpak** – Universal package manager for sandboxed apps.  
- **flathub remote** – Popular Flatpak repository with desktop apps.  
- **flathub apps**
  - Eyedropper
  - Vesktop
  - Obsidian
  - Signal Desktop   

### Apps Installed
- **VS Codium** - https://vscodium.com/
- 