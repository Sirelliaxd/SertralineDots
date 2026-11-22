---   [#######################]
---   [ ENVIRONMENT VARIABLES ]
---   [#######################]

--    ###{ cursor }###
hl.env("HYPRCURSOR_THEME", "sayanouta_linux_cursorpack")
hl.env("XCURSOR_THEME", "sayanouta_linux_cursorpack")

hl.env("XCURSOR_SIZE", "27")
hl.env("HYPRCURSOR_SIZE", "27")

--    ###{ toolkit backend }###
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")

--    ###{ XDG }##
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

--    ###{ Qt }###
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("QT_QPA_PLATFORM", "wayland:xcb")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_QPA_PLATFORMTHEME", "qt4ct")

---   ###{ this machine, see Local/local.lua }###
for name, value in pairs(Local.env or {}) do
	hl.env(name, value)
end

---   ###{ distro glyph for the shell }###
-- .config/quickshell/Theme.qml reads this through Quickshell.env, so the power
-- menu icon follows the distro instead of being hardcoded to one glyph.
local distroGlyphs = {
	artix = "\u{f31f}",
	arch = "\u{f303}",
	debian = "\u{f306}",
	ubuntu = "\u{f31b}",
	fedora = "\u{f30a}",
	gentoo = "\u{f30d}",
	void = "\u{f32e}",
	nixos = "\u{f313}",
}
local osRelease = io.open("/etc/os-release", "r")
local distroId = ""
if osRelease then
	for line in osRelease:lines() do
		local id = line:match('^ID="?([%w_]+)"?')
		if id then
			distroId = id
			break
		end
	end
	osRelease:close()
end
hl.env("SERTRALINE_DISTRO_GLYPH", distroGlyphs[distroId] or "\u{f31f}")

-- ###{HYPRSHOT DIR}
-- HOME relative, so no absolute path is written down
hl.env("HYPRSHOT_DIR", (os.getenv("HOME") or "") .. "/Pictures/Screenshots/")

-- hl.config({ xwayland = { force_zero_scaling = true } })
