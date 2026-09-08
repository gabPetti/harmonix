local shader_path = os.getenv("HOME") .. "/archaic/themes/dynamic/hypr/rounded-corners.glsl"

-- ==> ANIMATIONS

hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })

hl.animation({
	leaf = "windows",
	enabled = true,
	speed = 6,
	bezier = "wind",
	style = "slide",
})

hl.animation({
	leaf = "windowsIn",
	enabled = true,
	speed = 6,
	bezier = "winIn",
	style = "slide",
})

hl.animation({
	leaf = "windowsOut",
	enabled = true,
	speed = 5,
	bezier = "winOut",
	style = "slide",
})

hl.animation({
	leaf = "windowsMove",
	enabled = true,
	speed = 5,
	bezier = "wind",
	style = "slide",
})

hl.animation({
	leaf = "border",
	enabled = true,
	speed = 1,
	bezier = "liner",
})

hl.animation({
	leaf = "borderangle",
	enabled = true,
	speed = 30,
	bezier = "liner",
	style = "loop",
})

hl.animation({
	leaf = "fade",
	enabled = true,
	speed = 10,
	bezier = "default",
})

hl.animation({
	leaf = "workspaces",
	enabled = true,
	speed = 5,
	bezier = "wind",
})

hl.config({
	animations = {
		enabled = true,
	},
	general = {
		gaps_in = 3,
		gaps_out = 8,
		border_size = 3,
		-- col = {
		-- 	active_border = {
		-- 		colors = { colors.color1, colors.color2 },
		-- 		angle = 45,
		-- 	},
		-- 	inactive_border = colors.background,
		-- },
		resize_on_border = true,
	},
	decoration = {
		shadow = {
			enabled = false,
		},
		screen_shader = shader_path,
		dim_special = 0.3,
		rounding = 10,
		blur = {
			special = true,
			enabled = true,
			size = 6,
			passes = 3,
			new_optimizations = true,
			ignore_opacity = true,
			xray = false,
		},
	},
})

-- hl.on("config.reloaded", function()
-- 	hl.exec_cmd("hyprctl setcursor Bibata-Modern-Classic 20")
-- 	hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'")
-- 	hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size 20")
-- 	hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'Tela-circle-dracula'")
-- 	hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
-- end)
