# Debian 13 + Sway Run Book (Minimal & Intentional Setup)

---

## 1. Base System

During the Debian installer:
- Select **SSH server**
- Select **standard system utilities**
- Do **not** select a desktop environment

---

# Sway Configuration for Debian 13 Trixie

A minimal, utilitarian Sway desktop environment with Waybar, managed using GNU Stow.

## Features

- **Sway** - Tiling Wayland compositor
- **Waybar** - Minimal, clean status bar with idle inhibitor
- **Wofi** - Wayland-native application launcher (Everforest theme)
- **SwayNC** - Notification daemon with control center
- **Kitty** - GPU-accelerated terminal
- **Dual 4K monitor support** - Pre-configured for DP-1 (horizontal) + DP-2 (vertical)

---

## Quick Start

### 1. Fresh Debian 13 Trixie Minimal Install

Run the automated installation script:

```bash
cd ~/sway-config/sway-scripts
chmod +x debian_install.sh
./debian_install.sh
```

### 2. Clone This Repository

```bash
cd ~
https://github.com/philipbhaworth/sway-config.git
cd sway-config
```

### 3. Deploy Configurations with Stow

```bash
cd ~/sway-config

# Deploy Sway config
stow debian13-sway

# Deploy Waybar
stow waybar

# Deploy SwayNC
stow swaync

# Deploy Wofi
stow wofi

# Optional: Deploy shell config
stow bash
# OR
stow zsh-linux
```

### 4. Setup Wallpapers

```bash
mkdir -p ~/wallpapers
cp /path/to/your/wallpaper.png ~/wallpapers/walls09.png
```

### 5. Make Scripts Executable

```bash
chmod +x ~/sway-config/sway-scripts/*.sh
```

### 6. Start Sway

```bash
# From TTY (Ctrl+Alt+F2)
sway

# Or use a display manager (see Display Manager section)
```

---

## Package Installation Details

The `debian_install.sh` script installs:

### Core Sway Environment
- sway, swaybg, swayidle, swaylock
- waybar, xwayland
- wl-clipboard, grim, slurp, swappy

### Tools & Applications
- wofi (launcher)
- kitty (terminal)
- thunar (file manager) + gvfs, udisks2, thunar-volman, tumbler
- swaync (notifications)

### Audio & Media
- pipewire, pipewire-pulse, wireplumber
- pavucontrol, playerctl, pamixer

### System Utilities
- brightnessctl (backlight control)
- power-profiles-daemon

### Fonts
- fonts-font-awesome (Waybar icons)
- fonts-noto, fonts-noto-mono

### Development
- stow (dotfile management)
- git

---

## Additional Software Installation

### Code Editors

#### VSCodium (Open Source VS Code)

```bash
# Add repository
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg

echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' \
    | sudo tee /etc/apt/sources.list.d/vscodium.list

# Install
sudo apt update && sudo apt install codium
```

#### Sublime Text

```bash
# Add repository
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg \
    | gpg --dearmor \
    | sudo dd of=/usr/share/keyrings/sublimehq-archive.gpg

echo "deb [signed-by=/usr/share/keyrings/sublimehq-archive.gpg] https://download.sublimetext.com/ apt/stable/" \
    | sudo tee /etc/apt/sources.list.d/sublime-text.list

# Install
sudo apt update && sudo apt install sublime-text
```

### Flatpak Setup

```bash
# Install Flatpak
sudo apt install flatpak

# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Reboot or re-login for PATH updates
```

#### Flatpak Applications

```bash
# Vesktop (Discord client)
flatpak install flathub dev.vencord.Vesktop

# Signal
flatpak install flathub org.signal.Signal

# Zen Browser
flatpak install flathub io.github.zen_browser.zen

# Obsidian
flatpak install flathub md.obsidian.Obsidian

# Spotify
flatpak install flathub com.spotify.Client
```

### Starting Sway

This setup uses TTY login (no display manager):

```bash
# Login to TTY (Ctrl+Alt+F2 if in graphical environment)
# After login, start Sway:
sway
```

**Optional: Auto-start Sway on login**

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
# Auto-start Sway on TTY1
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec sway
fi
```

### Additional Development Tools

```bash
# Essential CLI tools
sudo apt install vim curl wget tmux net-tools tree

# Build essentials
sudo apt install build-essential

# Python development
sudo apt install python3-pip python3-venv

# Container tools (Docker alternative)
sudo apt install podman podman-compose
```

---

## Configuration Structure

```
~/sway-config/
├── debian13-sway/        # Debian-specific Sway config
│   └── .config/sway/config
├── waybar/               # Status bar config
│   └── .config/waybar/
│       ├── config
│       └── style.css
├── swaync/              # Notification daemon
│   └── .config/swaync/
│       ├── config.json
│       └── style.css
├── wofi/                # Application launcher
│   └── .config/wofi/
│       ├── config
│       └── style.css
├── bash/                # Bash shell config
│   └── .bashrc
├── zsh-linux/           # Zsh shell config
│   └── .zshrc
└── sway-scripts/        # Utility scripts
    ├── debian_install.sh
    ├── power-menu.sh
    └── package_checker.sh
```

---

## Key Bindings

### Window Management
- `Super + h/j/k/l` - Focus window (vim-style)
- `Super + Shift + h/j/k/l` - Move window
- `Super + 1-0` - Switch workspace
- `Super + Shift + 1-0` - Move window to workspace
- `Super + q` - Close window
- `Super + Shift + f` - Fullscreen

### Applications
- `Super + Return` - Terminal (Kitty)
- `Super + d` - Application launcher (Wofi)
- `Super + f` - File manager (Thunar)
- `Super + c` - VSCodium
- `Super + x` - Sublime Text

### Layout
- `Super + b` - Split horizontal
- `Super + v` - Split vertical
- `Super + s` - Stacking layout
- `Super + w` - Tabbed layout
- `Super + e` - Toggle split layout

### System
- `Super + Shift + r` - Reload Sway config
- `Super + Shift + e` - Exit Sway
- `Print` - Screenshot (full screen)
- `Super + Shift + s` - Screenshot (region selector)

### Media Keys
- `XF86AudioRaiseVolume` - Volume up
- `XF86AudioLowerVolume` - Volume down
- `XF86AudioMute` - Mute toggle
- `XF86MonBrightnessUp/Down` - Brightness control
- `XF86AudioPlay/Pause/Next/Prev` - Media controls

---

## Monitor Configuration

Current setup for dual 4K monitors:

```bash
# LG HDR 4K (left, horizontal)
output DP-1 resolution 3840x2160 position 0,0 scale 1

# Acer KG272K (right, vertical)
output DP-2 resolution 3840x2160 transform 90 position 3840,0 scale 1
```

To adjust for your setup:

1. List available outputs:
   ```bash
   swaymsg -t get_outputs
   ```

2. Edit `~/.config/sway/config` and modify output configuration

3. Reload Sway: `Super + Shift + r`

---

## Troubleshooting

### Waybar Icons Missing

```bash
sudo apt install fonts-font-awesome
fc-cache -fv
swaymsg reload
```

### SwayNC Not Starting

```bash
pkill swaync
swaync &
```

### Stow Conflicts

If stow reports conflicts with existing files:

```bash
# Backup existing configs
mkdir ~/config-backup
mv ~/.config/sway ~/config-backup/
mv ~/.config/waybar ~/config-backup/

# Then re-run stow
cd ~/sway-config
stow debian13-sway waybar swaync wofi
```

### Check Deployed Symlinks

```bash
cd ~/sway-config
stow -n -v debian13-sway  # Dry run - shows what would be linked
```

### Remove Deployed Configs

```bash
cd ~/sway-config
stow -D debian13-sway  # Removes symlinks
```

### Audio Not Working

```bash
# Check PipeWire status
systemctl --user status pipewire pipewire-pulse wireplumber

# Restart PipeWire
systemctl --user restart pipewire pipewire-pulse wireplumber
```

### Brightness Control Not Working

```bash
# Add user to video group
sudo usermod -aG video $USER

# Re-login for changes to take effect
```

---

## Customization

### Change Wallpaper

Place your wallpaper in `~/wallpapers/` and edit `~/.config/sway/config`:

```bash
output * bg ~/wallpapers/your-wallpaper.png fill
```

### Modify Waybar Appearance

Edit `~/.config/waybar/style.css` for colors and styling.

Edit `~/.config/waybar/config` for modules and layout.

### Wofi Theme

The Everforest theme is in `~/.config/wofi/style.css`.

Color scheme:
- Background: `#38423d`
- Accent: `#a7c080`
- Text: `#d3c6aa`

### Gaps and Borders

Edit `~/.config/sway/config`:

```bash
gaps inner 10      # Space between windows
gaps outer 5       # Space from screen edge
smart_gaps on      # Disable gaps when single window
smart_borders on   # Disable borders when single window
```

---

## System Information

**Tested on:**
- Debian 13 (Trixie)
- Kernel: 6.x
- Sway: Latest available in Debian repos

**Hardware:**
- Dual 4K monitors (DP-1 + DP-2)
- Keyboard with media keys
- Backlight control support

---

## Contributing

Feel free to fork and customize for your own setup. Pull requests welcome for:
- Bug fixes
- Debian-specific improvements
- Additional utility scripts
- Documentation improvements

---

## License

MIT License - See LICENSE file for details

---

## Acknowledgments

- Sway developers
- Waybar project
- Everforest color scheme
- Debian community
