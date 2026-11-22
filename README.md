<h1 align="center">Sertraline Dots</h1>


![GitHub last commit](https://img.shields.io/github/last-commit/Sirelliaxd/SertralineDots?style=for-the-badge&labelColor=%2314141c&color=%23e6e6e8)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Sirelliaxd/SertralineDots?style=for-the-badge&label=CODE%20SIZE&labelColor=%2314141c&color=%23787c99)
## Showcase

<p align="center">
  <img src="GitAssets/Showcase.gif" alt="Demo" width="600" />
</p>

**Designed for Artix** (with cross-distro install steps below)
## Installation

**Needs Hyprland >= 0.57.2 and Quickshell >= 0.3.2.** Run `./check-deps.sh` afterwards: it checks both versions plus every binary the configs call, and lists what is missing.

The package names below are Arch/Artix ones. On any other distro, treat `./check-deps.sh` as the list and map its **binaries** to your own packages; it does not know your package manager, and a few names are Arch shaped (`7z` is `7zz` on Debian, `bluetui` and `pipemixer` are AUR only).

Clone into `~/SertralineDots`. The Lua config looks for the machine specific `Local/local.lua` at that exact path (`~/SertralineDots/Local`), so a clone somewhere else silently falls back to the portable defaults until you change the path in `.config/hypr/hyprland.lua:11`.

#### 1. Dependencies

**Pacman Install Script**
```
sudo pacman -S --needed hyprland hyprlock hyprpaper hyprshot kitty fish waybar mako \
cliphist rofi rofi-emoji wl-clipboard libnotify yazi jq quickshell ttf-jetbrains-mono-nerd \
pipewire pipewire-pulse wireplumber networkmanager network-manager-applet iproute2 curl \
iw macchanger polkit hyprpolkitagent upower procps-ng elogind tor i2pd \
ttf-font-awesome noto-fonts-emoji fastfetch eza stow bluetui pipemixer \
grim slurp satty brightnessctl playerctl udiskie gnome-keyring dbus neovim \
xdg-desktop-portal xdg-desktop-portal-hyprland xdg-utils
```
> Fonts are not covered by `check-deps.sh`: without `ttf-jetbrains-mono-nerd` (bar, menus, terminal), `ttf-font-awesome` (the deprecated waybar bar)

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

**System services** (any distro, any init)

The configs assume these are up. The repo ships no unit files, so enable them with your init (`systemctl enable --now`, runit service dirs, `rc-update add`, ...):
```
dbus                    session bus, used by quickshell, polkit and mako
elogind or logind       sessions, and the power menu's loginctl (hibernate also needs swap configured)
udev                    device nodes and the seat
NetworkManager          the network menu and its applet
bluetoothd              the bluetooth menu
pipewire, wireplumber   the volume menu (pipewire-pulse as well on some distros)
upower                  the battery readout
udisks2                 udiskie, for automounting
polkitd                 the authentication agent the autostart starts
xdg-desktop-portal      with xdg-desktop-portal-hyprland as the backend, for screenshots and screencast
tor, i2pd               optional, the network menu footer shows them as running or stopped
```
> Without dbus, logind or NetworkManager the menus still open, they just stay empty. That is the first thing to check on a fresh machine.

#### 2. Installation 

**1. gitclone the repo in your home directory**
`git clone https://github.com/Sirelliaxd/SertralineDots`

**2. Setup**
  1. Create a `Local` folder inside root repo
    `cd ~/SertralineDots`
    `mkdir Local`
    - **Copy the `local-template.lua` into that dir**
    `cp local-template.lua Local/local.lua`
  2. Everything machine specific is a value in `Local/local.lua`; the template lists the fields.
  > ![NOTE] you can remove the `Local` dir from .gitignore if you want to backup machine your machine specific details on github
  3. Inside `~/SertralineDots/.config/quickshell/` run `touch .qmlls.ini`
  4. Swap the browse, notes, matrix etc apps from `~/SertralineDots/.config/hypr/modules/programs.lua` and `~/SertralineDots/.config/hypr/modules/keybinds.lua`
  5. Delete the fish aliases u don't need in `~/SertralineDots/.config/fish/config.fish`
  6. Run `./check-deps.sh` and install whatever it reports as missing

**Machine specific lines that stay in the config**

Three things cannot move to `Local/local.lua`: hyprlang cannot read Lua, and the polkit agent is a path rather than a value. Change them in place:
```
.config/hypr/hyprpaper.conf:6      monitor = eDP-1        the output the wallpaper is pinned to
.config/hypr/hyprlock.conf:81      text = $LAYOUT[pl]     the layout list shown on the lock screen
.config/hypr/modules/programs.lua  the polkit agent in the autostart
```
- `hyprpaper.conf`: the wallpapers itself ships with the repo (the default being `~/.config/Wallpapers/saya1.png`) and the rule below the pin already covers every other output, so on a single screen machine you can delete the pinned block outright.
- `hyprlock.conf`: keep the list in step with `kbLayout` in `Local/local.lua` (`pl` here).
- `programs.lua`: the agent is `/usr/lib/hyprpolkitagent/hyprpolkitagent` on Arch; point it at wherever your distro installs it.

Everything else that is machine specific is a value in `Local/local.lua`.

**5. symlink files using `stow`** (Make sure the be in the repo root!!! `~/Sertraline-Shell/` **DOUBLE CHECK**)
`stow .`

**6. OPTIONAL | Get rid of the password prompt when using macchanger & monitor mode 
from the network menu**

The no-password polkit rule in `~/SertralineDots/.config/quickshell/system/polkit/49-sertraline-network.rules` needs your user in the `wheel` group

*Installing polkit rules*
```
cd ~/SertralineDots/.config/quickshell
sudo install -m 644 system/polkit/org.sertraline.network.policy /usr/share/polkit-1/actions/
sudo install -m 644 system/polkit/49-sertraline-network.rules /etc/polkit-1/rules.d/
sudo pkill polkitd                # elogind / Artix: polkit has no service manager here
# on systemd: sudo systemctl restart polkit
```

*Verifying*
```
pkaction | grep sertraline                     # the three actions are known to polkit
time pkexec iw dev wlan0 info                  # root, no dialog, milliseconds
pkexec macchanger -r nonexistent0              # authorised, then macchanger's own "No such device"
timeout 3 pkexec macchanger -s nonexistent0    # NOT in the policy: waits for authentication
```

**7. Start the session**
Log out and back in through your display manager, or start Hyprland directly. The autostart in `.config/hypr/modules/programs.lua` brings up hyprpaper, mako, udiskie, the polkit agent and quickshell. If the bar never appears, check `hyprctl configerrors` first, then the shell's log at `/run/user/<uid>/quickshell/by-id/*/log.log`.

>![NOTE]
> For more information on this and the dots in general refer to the [Docs](./Docs/index.md) & [Polkit](./Docs/Quickshell/Misc/PrivilegedActions.md) (*docs are work in progress*)
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
> Deprecated but still shipped: `waybar` (superseded by the quickshell bar, only its config is left) and the rofi menus (clipboard, emoji, wallpaper, cheatsheet). Do not wire up both bars.

>![NOTE]
> More info on all these features can(*will when i make them*) be found in the [docs](./Docs/index.md)

*The phone icon on the topbar is a OpenDisplay toggle for ipad as a second screen*
## Plans/ToDo
- [x] Migrate the topbar from waybar to quickshell
- [x] Merge the dots and quickshell repos into one
- [x] Make the dots easier to implement (more portable)
- [ ] Make a default keybinds guide
- [ ] Write the docs
- [ ] Migrate the Wallpaper changer to quickshell
- [ ] Make a theme changer
- [ ] Migrate the clipboard history from rofi to quickshell
- [ ] Make a notification manager
- [ ] Make a keybindings menu + changer
- [ ] Make a theme editor
- [ ] Make a installer script

---
#### Credits
- *Saya no Uta Cursor Pack* - [@m370lanza](https://x.com/m370lanza) on **X/Twitter**
- *Volume OSD* - Quickshell official [examples](https://github.com/quickshell-mirror/quickshell-examples/tree/master/volume-osd)
- Referenced for *Cpu/Ram/Network Proc's in QS config* - [@tony](https://www.youtube.com/watch?v=g_I4hwCuDyQ) on **YouTube**
- *Battery Topbar Widget* - [@saneaspect](https://www.youtube.com/watch?v=Vlpyz4c4Xdw&t=2815s) on **YouTube**
