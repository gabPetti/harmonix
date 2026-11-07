local map = vim.keymap.set

-- Esc clears the search highlight on the way out.
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Window navigation without the <C-w> prefix, in terminal mode as well as
-- normal: <Cmd> runs the command from either mode, where <C-w>h would be sent
-- to the shell instead. Means a terminal split can be left without pressing
-- Esc Esc first -- at the cost of the readline bindings on the same keys
-- inside the terminal (notably <C-l> to clear); <C-w> still reaches the shell.
map({ "n", "t" }, "<C-h>", "<Cmd>wincmd h<CR>", { desc = "Go to left window" })
map({ "n", "t" }, "<C-j>", "<Cmd>wincmd j<CR>", { desc = "Go to lower window" })
map({ "n", "t" }, "<C-k>", "<Cmd>wincmd k<CR>", { desc = "Go to upper window" })
map({ "n", "t" }, "<C-l>", "<Cmd>wincmd l<CR>", { desc = "Go to right window" })

-- Window management
map("n", "<leader>w-", "<C-w>s", { desc = "Split window below" })
map("n", "<leader>w|", "<C-w>v", { desc = "Split window right" })
map("n", "<leader>wd", "<C-w>c", { desc = "Close window" })
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>b#<cr>", { desc = "Switch to other buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Files
-- <cmd>write<cr> leaves insert mode on the way out, so the cursor ends up in
-- normal mode whichever mode the save was triggered from.
map({ "n", "i", "x", "s" }, "<C-s>", "<cmd>write<cr><Esc>", { desc = "Save file" })
map("n", "<leader>fs", "<cmd>write<cr>", { desc = "Save file" })
map({ "n", "x" }, "<leader>fa", "<cmd>wall<cr>", { desc = "Save all files" })
map("n", "<leader>qq", "<cmd>qall<cr>", { desc = "Quit all" })

-- Move the current line / selection up and down, re-indenting as it goes.
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("x", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("x", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- Keep the selection after shifting it, so > / < can be repeated.
map("x", "<", "<gv", { desc = "Shift left" })
map("x", ">", ">gv", { desc = "Shift right" })

-- Centre the view when jumping, so the cursor never ends up at a screen edge.
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up" })
map("n", "n", "nzzzv", { desc = "Next search match" })
map("n", "N", "Nzzzv", { desc = "Previous search match" })

-- Yank to a vim-only register, for when something should *not* leave the
-- editor (clipboard = unnamedplus makes plain y/p the system-clipboard path).
map({ "n", "x" }, "<leader>y", [["zy]], { desc = "Yank to vim register z" })
map({ "n", "x" }, "<leader>p", [["zp]], { desc = "Paste from vim register z" })

-- Paste over a selection without losing what is in the register, so the same
-- yank can be pasted repeatedly.
map("x", "<leader>P", [["_dP]], { desc = "Paste without yanking" })

-- Delete into the black hole register, for throwing text away without
-- clobbering the unnamed register.
map({ "n", "x" }, "<leader>d", [["_d]], { desc = "Delete without yanking" })

-- Diagnostics
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>xq", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Toggles
map("n", "<leader>uw", function()
  vim.opt_local.wrap = not vim.wo.wrap
end, { desc = "Toggle wrap" })
map("n", "<leader>us", function()
  vim.opt_local.spell = not vim.wo.spell
end, { desc = "Toggle spell" })
map("n", "<leader>ur", function()
  vim.opt_local.relativenumber = not vim.wo.relativenumber
end, { desc = "Toggle relative numbers" })
-- virtual_lines shows the full message under the code; virtual_text is the
-- compact default. One or the other, never both.
map("n", "<leader>ud", function()
  local lines = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = lines, virtual_text = not lines and { prefix = "●", spacing = 2 } or false })
end, { desc = "Toggle diagnostic virtual lines" })

-- <C-[> and <Esc> are the same keycode in terminal mode, so a single Esc would
-- leave terminal mode immediately. Require a double-tap instead, so terminal
-- apps that use Esc themselves (vim, fzf, …) keep working.
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode (press Esc twice)" })
