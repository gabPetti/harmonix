hl.config({
	general = {
		col = {
			active_border = {
				colors = { "{{colors.primary.default.hex}}", "{{colors.tertiary.default.hex}}" },
				angle = 45,
			},
			inactive_border = "{{colors.background.default.hex}}",
		},
	},
	misc = {
		background_color = "rgba({{colors.surface.default.hex_stripped}}FF)",
	},
})

-- hl.window_rule({
-- 	match = { pin = 1 },
-- 	border_color = "rgba({{colors.primary.default.hex_stripped}}AA) rgba({{colors.primary.default.hex_stripped}}77)",
-- })
