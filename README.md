# Sway Setup Runbook

Personal installation guide for recreating my Sway environment on Debian.

## Core System Packages

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Core Sway environment
sudo apt install -y sway waybar wlogout swaybg swayidle swaylock

# Essential tools
sudo apt install -y grim slurp wl-clipboard brightnessctl playerctl

# Terminal and applications
sudo apt install -y kitty foot firefox-esr

# Audio and media
sudo apt install -y pavucontrol pulseaudio

# File management and utilities
sudo apt install -y nemo ranger tree htop btop

# Development tools
sudo apt install -y git vim geany geany-plugins codium

# Launchers and menus
sudo apt install -y wofi

# System utilities
sudo apt install -y network-manager-gnome stow
```

## Additional Packages

```bash
# Media and graphics
sudo apt install -y mpv qimgv

# System monitoring
sudo apt install -y powertop cpu-x

# Network tools
sudo apt install -y traceroute whois

# Archive tools
sudo apt install -y file-roller

# CLI utilities
sudo apt install -y fd-find ripgrep bat fzf tmux

# Themes and appearance
sudo apt install -y gtk2-engines-murrine nwg-look

# Fonts
sudo apt install -y fonts-inter fonts-noto-mono
```

## Flatpak Applications

```bash
# Add Flathub repository
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Install applications
flatpak install -y flathub dev.vencord.Vesktop
flatpak install -y flathub md.obsidian.Obsidian
flatpak install -y flathub org.gnome.TextEditor
```

## Configuration Setup

```bash
# Clone dotfiles repository
cd ~
git clone [YOUR_REPO_URL] dotfiles-sway

# Install configurations using stow
cd dotfiles-sway
stow sway waybar wlogout wofi

# Verify symlinks were created
ls -la ~/.config/ | grep "^l"
```

## Stow Management

```bash
# Install new configs
cd ~/dotfiles-sway
stow [package-name]

# Remove configs  
stow -D [package-name]

# Restow (useful after updates)
stow -R [package-name]

# Install all packages at once
stow */
```

## Post-Installation

```bash
# Remove nm-applet from autostart if present
mkdir -p ~/.config/autostart
echo "[Desktop Entry]
Hidden=true" > ~/.config/autostart/nm-applet.desktop

# Set default terminal (optional)
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/kitty 50

# Enable user services if needed
systemctl --user enable pipewire-pulse
```

## Verification Commands

```bash
# Check Sway installation
sway --version

# Test Waybar config
waybar --config ~/.config/waybar/config --style ~/.config/waybar/style.css

# Verify audio
pactl info

# Check display management
swaymsg -t get_outputs
```

## Key Applications Summary

| Category | Application | Package/Flatpak |
|----------|-------------|------------------|
| Window Manager | Sway | `sway` |
| Status Bar | Waybar | `waybar` |
| Terminal | Kitty | `kitty` |
| Browser | Firefox ESR | `firefox-esr` |
| File Manager | Nemo | `nemo` |
| Editor | Geany | `geany` |
| IDE | VSCodium | `codium` |
| Launcher | Wofi | `wofi` |
| Chat | Vesktop | Flatpak |
| Notes | Obsidian | Flatpak |

## First Boot Checklist

- [ ] Log into Sway session
- [ ] Test audio with `pavucontrol`
- [ ] Verify network with `nmtui`
- [ ] Check display settings with `nwg-look`
- [ ] Test screenshot with `grim`
- [ ] Configure git: `git config --global user.name/email`
- [ ] Import SSH keys or generate new ones
- [ ] Test Flatpak applications

## Troubleshooting

### Waybar not starting
```bash
killall waybar
waybar &
```

### Audio not working
```bash
systemctl --user restart pipewire-pulse
pavucontrol
```

### Display issues
```bash
swaymsg reload
```

### Network issues
```bash
sudo systemctl restart NetworkManager
nmtui
```