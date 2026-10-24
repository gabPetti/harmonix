-- █░█ █▀▀ █░░█ █▀▀▄ ░▀░ █▀▀▄ █▀▀▄ ░▀░ █▀▀▄ █▀▀▀ █▀▀
-- █▀▄ █▀▀ █▄▄█ █▀▀▄ ▀█▀ █░░█ █░░█ ▀█▀ █░░█ █░▀█ ▀▀█
-- ▀░▀ ▀▀▀ ▄▄▄█ ▀▀▀░ ▀▀▀ ▀░░▀ ▀▀▀░ ▀▀▀ ▀░░▀ ▀▀▀▀ ▀▀▀

-- ==> GLOBAL VARIABLES
local term = "kitty"
local scripts_path = os.getenv("HOME") .. "/.config/hypr/scripts"

-- ==> SYSTEM BINDS
hl.bind("SUPER + Return", hl.dsp.exec_cmd(term), { description = "Open terminal" })
hl.bind("SUPER + L", hl.dsp.focus({ workspace = "empty" }), { description = "Open first empty workspace" })
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

-- ==> QUICKSHELL LAUNCHER
-- Both modes live in the same Quickshell window; these just ask it to open.
hl.bind("SUPER + A", hl.dsp.exec_cmd("qs -c harmonix ipc call launcher apps"), { description = "Open app launcher" })
hl.bind(
	"SUPER + ALT + W",
	hl.dsp.exec_cmd("qs -c harmonix ipc call launcher wallpapers"),
	{ description = "Open wallpaper picker" }
)
hl.bind(
	"SUPER + ALT + P",
	hl.dsp.exec_cmd("kitty -e " .. scripts_path .. "/power"),
	{ description = "Open power manager" }
)
hl.bind(
	"SUPER + ALT + N",
	hl.dsp.exec_cmd("kitty -e " .. scripts_path .. "/network menu"),
	{ description = "Open network manager" }
)
hl.bind(
	"SUPER + ALT + B",
	hl.dsp.exec_cmd("kitty -e " .. scripts_path .. "/bluetooth menu"),
	{ description = "Open bluetooth manager" }
)

-- ==> SYSTEM CONTROLS
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume raise"),
	{ description = "Increase volume", repeating = true, locked = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("swayosd-client --output-volume lower"),
	{ description = "Decrease volume", repeating = true, locked = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"),
	{ description = "Toggle audio mute", locked = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),
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
	hl.dsp.exec_cmd("swayosd-client --brightness raise"),
	{ description = "Increase brightness", locked = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("swayosd-client --brightness lower"),
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
hl.bind("SUPER + CTRL + L", hl.dsp.focus({ direction = "right" }), { description = "Previous workspace" }) -- hl.bind("SUPER + K", function() hl.dsp.focus({ workspace = "e+1" }) hl.dsp.exec_cmd("swayosd-client --custom-message 'Workspace " .. tostring(1) .. "'") end, { auto_consuming = true, description = "Scroll workspaces forward" })
-- hl.bind("SUPER + J", hl.dsp.focus({ workspace = "e-1" }), { description = "Scroll workspaces back" })
-- Scroll Workspaces Forward
hl.bind("SUPER + K", function()
	hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))
	local ws = hl.get_active_workspace().id
	hl.dispatch(hl.dsp.exec_cmd("swayosd-client --custom-message '" .. tostring(ws) .. "'"))
end, { auto_consuming = true, description = "Next workspace" })

-- Scroll Workspaces Backward
hl.bind("SUPER + J", function()
	hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))
	local ws = hl.get_active_workspace().id
	hl.dispatch(hl.dsp.exec_cmd("swayosd-client --custom-message '" .. tostring(ws) .. "'"))
end, { auto_consuming = true, description = "Previous workspace" })

hl.bind("SUPER + Tab", hl.dsp.focus({ workspace = "e+1" }), { description = "Scroll workspaces forward" })
hl.bind("SUPER + S", hl.dsp.workspace.toggle_special(), { description = "Show special workspace" })
hl.bind(
	"SUPER + SHIFT + S",
	hl.dsp.window.move({ workspace = "special" }),
	{ description = "Move window to special workspace" }
)

------------------------------------------------------------------------------------------------
