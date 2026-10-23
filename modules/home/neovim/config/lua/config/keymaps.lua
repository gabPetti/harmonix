-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Note: <C-[> and <Esc> are the same keycode in terminal mode, so a mapping
-- on <C-[> alone made a single Esc exit terminal mode immediately.
-- Require a double-tap instead, so terminal apps that use a single Esc for
-- their own actions (vim, fzf, etc.) keep working.
vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode (press Esc twice)" })
