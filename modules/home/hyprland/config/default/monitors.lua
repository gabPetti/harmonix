-- ##==> Monitors
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1.2,
})

hl.monitor({
  output = "eDP-1",
  mode = "preferred",
  position = "0x0",
  scale = 1.2,
  disabled = false,
})

hl.monitor({
  output = "HDMI-A-1",
  mode = "preferred",
  position = "0x-900",
  scale = 1.2,
  disabled = false,
})

hl.workspace_rule({ workspace = 1, monitor = "eDP-1", default = true })
for i = 2, 10 do
  hl.workspace_rule({ workspace = i, monitor = "HDMI-A-1", default = (i == 2) })
end
