---   [##########]
---   [ MONITORS ]
---   [##########]

-- { this machine's outputs, see Local/local.lua }
for _, monitor in ipairs(Local.monitors or {}) do
	hl.monitor(monitor)
end

-- { RANDOM MONITORS }
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto-left",
	scale = 1,
})
