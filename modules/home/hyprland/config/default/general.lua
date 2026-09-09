hl.config({
  -- ##==> Inputs
  input = {
    kb_layout = "br",
    kb_options = "ctrl:swapcaps,altwin:swap_lalt_lwin",
    touchpad = {
      natural_scroll = true,
    },
  },

  -- ##==> Layouts
  dwindle = {
    preserve_split = true
  },

  master = {
    new_status = "master",
  },

  general = {
    layout = "dwindle",
  },

  -- ##==> Misc
  misc = {
    vrr = 0,
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
    force_default_wallpaper = 0,
    anr_missed_pings = 5,
    allow_session_lock_restore = true,
  },

  -- ##==> XWayland
  xwayland = {
    force_zero_scaling = true,
  },
})
