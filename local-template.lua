-- Copy it into place and fill it in: cp local-template.lua Local/local.lua

return {
	-- one entry per output, from `hyprctl monitors`
	monitors = {
		{ output = "", mode = "", position = "", scale = 1 },
	},

	-- from `ls -l /dev/dri`
	env = {
		GBM_BACKEND = "",
		__GLX_VENDOR_LIBRARY_NAME = "",
		LIBVA_DRIVER_NAME = "",
		AQ_DRM_DEVICES = "",
	},

	-- from `localectl status`
	kbLayout = "",

	-- this laptop's touchpad
	touchpad = {
		natural_scroll = true,
	},

	-- backlight and mute keys, from `hyprctl devices`
	keys = {
		brightnessUp = "",
		brightnessDown = "",
		muteSink = "",
		muteSource = "",
	},

	-- optional: a command to run at session start, e.g. bringing a VPN down
	vpnTeardown = "",
}
