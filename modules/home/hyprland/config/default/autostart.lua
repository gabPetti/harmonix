-- ==> Autostart

hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user start hyprland-session.target")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("waybar")
end)

hl.on("hyprland.shutdown", function()
	os.execute("pkill hyprpaper; pkill waybar; systemctl --user stop hyprland-session.target && sleep 0.1")
end)
