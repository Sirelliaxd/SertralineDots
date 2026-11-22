<h1 align="center">Sertraline Dots</h1>


![GitHub last commit](https://img.shields.io/github/last-commit/Sirelliaxd/SertralineDots?style=for-the-badge&labelColor=%2314141c&color=%23e6e6e8)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Sirelliaxd/SertralineDots?style=for-the-badge&label=CODE%20SIZE&labelColor=%2314141c&color=%23787c99)
## Showcase

<p align="center">
  <img src="GitAssets/Showcase.gif" alt="Demo" width="600" />
</p>


**! Still in beta & designed for artix (nonsystemd). There are few things specific to runit rn.*
## Installation

#### 1. Dependencies

**Pacman Install Script**
```
sudo pacman -S --needed hyprland hyprlock hyprpaper hyprshot kitty fish waybar mako \
cliphist rofi rofi-emoji wl-clipboard libnotify yazi jq quickshell ttf-jetbrains-mono-nerd \
pipewire pipewire-pulse wireplumber networkmanager network-manager-applet iproute2 curl \
iw macchanger polkit hyprpolkitagent polkit-kde-agent upower procps-ng elogind tor i2pd \
ttf-font-awesome noto-fonts-emoji fastfetch eza stow bluetui pipemixer \
grim slurp satty brightnessctl playerctl udiskie gnome-keyring dbus neovim \
xdg-desktop-portal xdg-desktop-portal-hyprland
```

**Yazi helpers** (the yazi config shells out to these for previews, search and jump)
```
sudo pacman -S --needed fd ripgrep fzf zoxide imagemagick 7zip poppler ffmpeg mediainfo \
perl-image-exiftool
```
> `fzf` and `zoxide` also need their yazi plugins: `ya pkg add yazi-rs/plugins:fzf` and `ya pkg add yazi-rs/plugins:zoxide`

**AUR Packages**
```
yay -S mullvad-vpn-bin python-pywal
```

**Extras** (fish aliases and app keybinds, swap for your own)
```
sudo pacman -S --needed nodejs android-tools lazygit cmatrix hyprshutdown cava librewolf obsidian ttf-cascadia-code-nerd
yay -S zen-browser-bin brave-bin
```
- `ttf-cascadia-code-nerd` is only needed by the deprecated waybar bar (`waybar/style.css`)

**From other sources:**
- [OpenDisplay](https://opendisplay.app/docs/linux/install/) for ipad second screen button*
#### 2. Installation 

**1. gitclone the repo in your home directory**
`git clone https://github.com/Sirelliaxd/SertralineDots`

**2. Create a `Local` folder inside root repo**
`cd ~/SertralineDots`
`mkdir Local`


**4. Porting to other distros/init (non artix or runit) + set machine specific vars**
  1. replace `loginctl` calls in `~/SertralineDots/.config/quickshell/menus/PowerDropdown.qml:41-61`
  2. Change the distro glyph (`/uf31f`) in `~/SertralineDots/.config/quickshell/Theme.qml:100` for your distros equivalent, or anything else u want.
  3. inside `~/SertralineDots/.config/quickshell/` run `touch .qmlls.ini`
  4. Change `subject.user == "stella"` in `~/SertralineDots/.config/quickshell/system/polkit/49-sertraline-network.rules:14` to your username
  5. Swap the browse, notes, matrix etc apps from `~/SertralineDots/.config/hypr/modules/programs.lua` and `~/SertralineDots/.config/hypr/modules/keybinds.lua`
  5. Delete the fish aliases u don't need in `~/SertralineDots/.config/fish/config.fish`

**5. symlink files using `stow`** (Make sure the be in the repo root!!! `~/Sertraline-Shell/` **DOUBLE CHECK**)
`stow .`

**6. OPTIONAL | Get rid of the password prompt when using macchanger & monitor mode 
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
---
**Artix/Runit note**
- The power menu uses loginctl, to port it swap it out for approperiate command
- the power menu icon is artix icon, swap it out in `SertralineDots/.config/quikcshell/Theme.qml`
- everything that is specific to this machine, to Artix/runit and to this user is listed in [local.md](./local.md)

## Features
- Topbar
- Power Menu
- Network Menu
- Bluetooth Menu
- Volume Menu
- App Launcher
- Wallpaper Changer
- Clipboard History
- Notifications (mako)

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
