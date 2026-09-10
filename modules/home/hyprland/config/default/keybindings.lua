-- █░█ █▀▀ █░░█ █▀▀▄ ░▀░ █▀▀▄ █▀▀▄ ░▀░ █▀▀▄ █▀▀▀ █▀▀
-- █▀▄ █▀▀ █▄▄█ █▀▀▄ ▀█▀ █░░█ █░░█ ▀█▀ █░░█ █░▀█ ▀▀█
-- ▀░▀ ▀▀▀ ▄▄▄█ ▀▀▀░ ▀▀▀ ▀░░▀ ▀▀▀░ ▀▀▀ ▀░░▀ ▀▀▀▀ ▀▀▀

-- ==> GLOBAL VARIABLES
local term = "kitty"
local bin = os.getenv("ARCHAIC_BIN") or (os.getenv("HOME") .. "/bin")

-- ==> SYSTEM BINDS
hl.bind("SUPER + Return", hl.dsp.exec_cmd(term), { description = "Open terminal" })
hl.bind("SUPER + L", hl.dsp.focus({ workspace = "empty" }), { description = "Open first empty workspace" })
hl.bind("SUPER + Print", hl.dsp.exec_cmd("sh " .. bin .. "/screenshot.sh"), { description = "Take screenshot GUI" })
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -z --clipboard-only -m region"), { description = "Take screenshot" })
hl.bind("SUPER + C", hl.dsp.exec_cmd("hyprpicker -f hex -a"), { description = "Pick color" })
hl.bind("SUPER + N", hl.dsp.exec_cmd("swaync-client -t"), { description = "Toggle Sway notification manager" })

-- ==> FIREFOX BINDS
hl.bind("CTRL + J", function()
	local window = hl.get_active_window()
	if window and window.class == "firefox" then
		hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL", key = "Tab", window = "activewindow" }))
	else
		return { ok = false }
	end
end, { auto_consuming = true })
hl.bind("CTRL + K", function()
	local window = hl.get_active_window()
	if window and window.class == "firefox" then
		hl.dispatch(hl.dsp.send_shortcut({ mods = "CTRL + SHIFT", key = "Tab", window = "activewindow" }))
	else
		return { ok = false }
	end
end, { auto_consuming = true })

-- ==> ROFI MENUS
hl.bind("SUPER + A", hl.dsp.exec_cmd("rofi -show drun"), { description = "Open Rofi" })
hl.bind(
	"SUPER + ALT + W",
	hl.dsp.exec_cmd("sh " .. bin .. "/rofi-menus/wallpaper-selector.sh"),
	{ description = "Open wallpaper menu" }
)
hl.bind(
	"SUPER + ALT + T",
	hl.dsp.exec_cmd("sh " .. bin .. "/rofi-menus/theme-selector.sh"),
	{ description = "Open theme menu" }
)
hl.bind(
	"SUPER + ALT + V",
	hl.dsp.exec_cmd("sh " .. bin .. "/rofi-menus/clipboard-manager.sh"),
	{ description = "Open clipboard manager" }
)
hl.bind(
	"SUPER + ALT + P",
	hl.dsp.exec_cmd("sh " .. bin .. "/rofi-menus/powermenu.sh"),
	{ description = "Open power manager" }
)
hl.bind(
	"SUPER + ALT + N",
	hl.dsp.exec_cmd("sh " .. bin .. "/rofi-menus/network-manager.sh"),
	{ description = "Open network manager" }
)
hl.bind(
	"SUPER + ALT + E",
	hl.dsp.exec_cmd("sh " .. bin .. "/rofi-menus/rofimoji.sh"),
	{ description = "Open network manager" }
)

-- ==> SYSTEM CONTROLS
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
	{ description = "Increase volume", repeating = true, locked = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ description = "Decrease volume", repeating = true, locked = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ description = "Toggle audio mute", locked = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("sh " .. bin .. "/volume.sh --device input --action toggle"),
	{ description = "Toggle microphone mute", locked = true }
)
hl.bind(
	"XF86AudioPlay",
	hl.dsp.exec_cmd("playerctl play-pause"),
	{ description = "Play or pause media", locked = true }
)
hl.bind(
	"XF86AudioPause",
	hl.dsp.exec_cmd("playerctl play-pause"),
	{ description = "Play or pause media", locked = true }
)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { description = "Next track", locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { description = "Previous track", locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { description = "Stop playback", locked = true })
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("brightnessctl set +5%"),
	{ description = "Increase brightness", locked = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("brightnessctl set 5%-"),
	{ description = "Decrease brightness", locked = true }
)

-- ==> HYPRLOCK
hl.bind("SUPER + ALT + L", hl.dsp.exec_cmd("hyprlock"), { description = "Lock the system" })

-- ==> WINDOW BINDS
hl.bind("SUPER + Q", hl.dsp.window.close(), { description = "Close window" })
hl.bind("SUPER + SHIFT + Q", hl.dsp.window.kill(), { description = "Kill window" })
hl.bind("SUPER + Space", hl.dsp.window.float({ action = "toggle" }), { description = "Toggle floating mode" })
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "maximized" }), { description = "Toggle Fullscreen" })
hl.bind(
	"SUPER + SHIFT + K",
	hl.dsp.window.move({ workspace = "+1" }),
	{ description = "Move window to next workspace" }
)
hl.bind(
	"SUPER + SHIFT + J",
	hl.dsp.window.move({ workspace = "-1" }),
	{ description = "Move window to prior workspace" }
)
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { description = "Resize with mouse", mouse = true })
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { description = "Move window with mouse", mouse = true })

-- ==> WORKSPACE BINDS
hl.bind("SUPER + CTRL + K", hl.dsp.focus({ direction = "up" }), { description = "Next workspace" })
hl.bind("SUPER + CTRL + J", hl.dsp.focus({ direction = "down" }), { description = "Previous workspace" })
hl.bind("SUPER + CTRL + H", hl.dsp.focus({ direction = "left" }), { description = "Next workspace" })
hl.bind("SUPER + CTRL + L", hl.dsp.focus({ direction = "right" }), { description = "Previous workspace" })
hl.bind("SUPER + K", hl.dsp.focus({ workspace = "e+1" }), { description = "Scroll workspaces forward" })
hl.bind("SUPER + J", hl.dsp.focus({ workspace = "e-1" }), { description = "Scroll workspaces back" })
hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "e+1" }), { description = "Scroll workspaces forward" })
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special(), { description = "Show special workspace" })
hl.bind(
	"SUPER + SHIFT + S",
	hl.dsp.window.move({ workspace = "special" }),
	{ description = "Move window to special workspace" }
)

------------------------------------------------------------------------------------------------
