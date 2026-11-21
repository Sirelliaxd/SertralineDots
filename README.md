<h1 align="center">Sertraline Dots</h1>


![GitHub last commit](https://img.shields.io/github/last-commit/Sirelliaxd/SertralineDots?style=for-the-badge&labelColor=%2314141c&color=%23e6e6e8)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Sirelliaxd/SertralineDots?style=for-the-badge&label=REPO%20SIZE&labelColor=%2314141c&color=%23787c99)
## Showcase

<p align="center">
  <img src="GitAssets/Showcase.mp4" alt="Demo" width="600" />
</p>

## Installation

#### 1. Dependencies

**Pacman Install Script**
```
sudo pacman -S --needed hyprland kitty hyprpaper fish waybar fish mako cliphist rofi \
rofi-emoji wl-clipboard yazi jq quickshell ttf-jetbrains-mono-nerd pipewire \
pipewire-pulse wireplumber networkmanager network-manager-applet iproute2 curl \
iw macchanger polkit hyprpolkitagent upower procps-ng elogind tor i2pd ttf-font-awesome \
noto-fonts-emoji fastfetch eza stow bluetui nmtui pipemixer
```

**AUR Packages**
```
yay -S mullvad-vpn-bin
```
**From other sources:**
- [OpenDisplay](https://opendisplay.app/docs/linux/install/) for ipad second screen button*
#### 2. Installation 

**1. gitclone the repo in you're home directory**
`git clone https://github.com/Sirelliaxd/SertralineDots`

**2. symlink files using `stow`** (Make sure the be in the repo root!!! `~/Sertraline-Shell/` **DOUBLE CHECK**)
`stow .`

**3. OPTIONAL | Get rid of the password prompt when using macchanger & monitor mode 
from the network menu**

*Installing polkit rules*
```
cd ~/SertralineDots/.config/quickshell
sudo install -m 644 system/polkit/org.sertraline.network.policy /usr/share/polkit-1/actions/
sudo install -m 644 system/polkit/49-sertraline-network.rules /etc/polkit-1/rules.d/
sudo pkill polkitd
```

*Verifying*
```
pkaction | grep sertraline                     # the three actions are known to polkit
time pkexec iw dev wlan0 info                  # root, no dialog, milliseconds
pkexec macchanger -r nonexistent0              # authorised, then macchanger's own "No such device"
timeout 3 pkexec macchanger -s nonexistent0    # NOT in the policy: waits for authentication
```

>![NOTE]
> For more information on this and the dots in general refer to the [Docs](./Docs/index.md) & [Polkit](./Docs/Quickshell/Misc/PrivilegedActions.md)

## Features
- Topbar
- Power Menu
- Network Menu
- Bluetooth Menu
- Volume Menu
- App Launcher
- Wallpaper Changer
- Clipboard History

>![NOTE]
> More info on all these features can(*will when i make them*) be found in the [docs](./Docs/index.md)

*The phone icon on the topbar is a OpenDisplay toggle for ipad as a second screen*
## Plans/ToDo
- [x] Migrate the topbar from waybar to quickshell
- [x] Merge the dots and quickshell repos into one
- [ ] Make a default keybinds guide
- [ ] Write the docs
- [ ] Migrate the Wallpaper changer to quickshell
- [ ] Make a theme changer
- [ ] Migrate the clipboard history from rofi to quickshell
- [ ] Make a notification manager
- [ ] Make a keybindings menu + changer
- [ ] Make a theme editor
- [ ] Make a installer script
- [ ] Make the installer script (and the dots as a whole) cross-distro

---
#### Credits
- *Saya no Uta Cursor Pack* - [@m370lanza](https://x.com/m370lanza) on **X/Twitter**
- *Volume OSD* - Quickshell official [examples](https://github.com/quickshell-mirror/quickshell-examples/tree/master/volume-osd)
- Referenced for *Cpu/Ram/Network Proc's in QS config* - [@tony](https://www.youtube.com/watch?v=g_I4hwCuDyQ) on **YouTube**
- *Battery Topbar Widget* - [@saneaspect](https://www.youtube.com/watch?v=Vlpyz4c4Xdw&t=2815s) on **YouTube**
