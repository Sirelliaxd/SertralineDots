---   [######################]
---   [ PROGRAMS & AUTOSTART ]
---   [######################]

-- { VARIABLES }
Terminal = "kitty"
FileManager = "kitty yazi"
-- Menu = "rofi -show drun"
Menu = "qs ipc call applauncher toggle"
Browser = "zen-browser"
SecondaryBrowser = "brave"
ThirdBrowser = "librewolf"
Notes = "kitty nvim ~/Notes/"
ScreenShot = "hyprshot -m region"
ScreenShotNoSave = "hyprshot -m region --clipboard-only"
ScreenShotAlt = 'grim -g "$(slurp)" -t ppm - | satty --filename - --fullscreen'
NotesAlt = "obsidian"

-- { AUTOSTART }
hl.on("hyprland.start", function()
	hl.exec_cmd("hyprpaper & mako")
	hl.exec_cmd("udiskie  & nm-applet")
	hl.exec_cmd("wl-paste --watch cliphist store")
	hl.exec_cmd("pipewire & pipewire-pulse")
	hl.exec_cmd("wireplumber")
	-- hl.exec_cmd("waybar")
	hl.exec_cmd("quickshell")
	hl.exec_cmd("/usr/lib/hyprpolkitagent/hyprpolkitagent")
	if Local.vpnTeardown then
		hl.exec_cmd(Local.vpnTeardown)
	end
	hl.exec_cmd("hyprctl setcursor sayanouta_linux_cursorpack 26")
end)
