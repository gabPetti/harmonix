-- Entry point. Order matters: options (including the leader keys) have to be
-- set before lazy.nvim loads any plugin, because `keys = {}` specs capture
-- <leader> at spec-definition time.
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
