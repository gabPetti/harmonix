-- ==> Autostart

hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user start hyprland-session.target")
	hl.exec_cmd("systemctl --user start hyprpaper")
	hl.exec_cmd("systemctl --user start quickshell")
end)

hl.on("hyprland.shutdown", function()
	os.execute("pkill hyprpaper; pkill quickshell; systemctl --user stop hyprland-session.target && sleep 0.1")
end)
