--
--    HYPRLAND CONFIG MODULES
--
local custom = require("custom")

-----          { LOCAL }           -----
---
---	machine specific values live in <repo>/Local/local.lua (see Local/local.md).
---	The modules below read them from the `Local` global, so a clone without the
---	file falls back to the portable defaults in those modules.
local localDir = (os.getenv("HOME") or "") .. "/SertralineDots/Local"
local localPath = package.searchpath("local", localDir .. "/?.lua")
Local = localPath and dofile(localPath) or {}

-----         { COLORS }           -----
---
--- Wiki: https://wiki.hypr.land/Configuring/Variables/
require("modules.colors")

-----        { PROGRAMS }	         -----
---
--- 	programs variables and autostart apps
--- Wiki: https://wiki.hypr.land/Configuring/Keywords/
require("modules.programs")

-----      { LOOK AND FEEL }       -----
---
---	gaps,borders,rounding,shadow,etc.
---Wiki: https://wiki.hypr.land/Configuring/Variables/#decoration
require("modules.LookAndFeel")

-----  { WINDOWS AND WORKSPACES }  -----
---
---	windowrules
---Wiki: https://wiki.hypr.land/Configuring/Window-Rules/
---Wiki: https://wiki.hypr.land/Configuring/Workspace-Rules/
require("modules.WindowsAndWorkspaces")

----        { ANIMATIONS }         -----
---
---	animations setting
---Wiki: https://wiki.hypr.land/Configuring/Animations/
require("modules.animations")

----- 	       { INPUT } 	         -----
---
---	keyboard layout and touchpad gestures
---Wiki: https://wiki.hypr.land/Configuring/Variables/#input
require("modules.input")

-----       { KEYBINDINGS }        -----
---
---	set keybinds
---Wiki: https://wiki.hypr.land/Configuring/Binds/
require("modules.keybinds")

-----         { MONITORS }         -----
---
---	monitors configuration
---Wiki: https://wiki.hypr.land/Configuring/Monitors/
require("modules.monitors")

-----   { ENVIRONMENT VARIABLES }  -----
---
---	cursor size, main gpu, etc.
---Wiki: https://wiki.hypr.land/Configuring/Environment-variables/
require("modules.EnvironmentVariables")

-----         PERMISSIONS          -----
---
---	hyprland permissions settings
---Wiki: https://wiki.hypr.land/Configuring/Permissions/
require("modules.permissions")

-----           Lauout             -----
---
--- window layouts
require("modules.layout")
