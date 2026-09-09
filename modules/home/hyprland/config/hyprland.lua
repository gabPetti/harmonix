-- █▀▀ █▀▀█ █░░█ █▀▀█ █▀▀ █▀▀
-- ▀▀█ █░░█ █░░█ █▄▄▀ █░░ █▀▀
-- ▀▀▀ ▀▀▀▀ ░▀▀▀ ▀░▀▀ ▀▀▀ ▀▀▀

-- Helper function to safely load files without crashing the desktop
local function safe_load(module_name)
	local success, err = pcall(require, module_name)

	if not success then
		if type(err) == "string" and string.find(err, "not found") then
			print("Theme file [" .. module_name .. "] not found. Using defaults.")
			return -- Silently exit the function without triggering the notification
		end

		local safe_err = string.gsub(err, "'", "")

		os.execute(
			"notify-send -u critical 'Hyprland Theme Error' 'Failed to load: " .. module_name .. "\n" .. safe_err .. "'"
		)
		print("Error loading [" .. module_name .. "]: " .. tostring(err))
	end
end

safe_load("default.autostart")
safe_load("default.keybindings")
safe_load("default.windowrules")
safe_load("default.general")
safe_load("default.monitors")
safe_load("default.devices")
safe_load("default.appearance")
