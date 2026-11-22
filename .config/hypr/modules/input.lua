---   [#######]
---   [ INPUT ]
---   [#######]

hl.config({
	input = {
		kb_layout = Local.kbLayout or "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",

		follow_mouse = 1,

		sensitivity = -0.2, -- -1.0 - 1.0, 0 means no modification.

		touchpad = Local.touchpad,
	},
})
-- TODO: pipipipo do jutra

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})
