-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- local function run_code(terminalPosition)
--   return function()
--     -- Get the current file's type and name
--     local filetype = vim.bo.filetype
--     local filename = vim.fn.expand("%")
--     local basename = vim.fn.expand("%:r") -- Filename without extension
--
--     if terminalPosition == "right" then
--       vim.cmd("vsplit")
--       local width = math.floor(vim.o.columns * 0.25)
--       vim.cmd("vertical resize " .. width)
--     else
--       vim.cmd("botright split")
--       local height = math.floor(vim.o.lines * 0.25)
--       vim.cmd("resize " .. height)
--     end
--
--     -- Run the specific command based on filetype
--     if filetype == "python" then
--       vim.cmd("terminal python " .. filename)
--     elseif filetype == "cpp" then
--       vim.cmd("terminal g++ " .. filename .. " -o " .. basename .. " && ./" .. basename)
--     elseif filetype == "javascript" then
--       vim.cmd("terminal node " .. filename)
--     elseif filetype == "sh" then
--       vim.cmd("terminal sh " .. filename)
--     elseif filetype == "scala" then
--       vim.cmd("terminal scala " .. filename)
--     else
--       vim.cmd("q") -- Close the split if language isn't configured
--       print("No run command configured for filetype: " .. filetype)
--     end
--   end
-- end

-- vim.keymap.set("n", "<leader>rb", run_code(), { desc = "Run current file in bottom terminal split" })
-- vim.keymap.set("n", "<leader>rr", run_code("right"), { desc = "Run current file in right terminal split" })

vim.keymap.set("n", "<leader>tv", [[<cmd>vsplit | term<cr>A]], { desc = "Open terminal in vertical split" })
vim.keymap.set("n", "<leader>th", [[<cmd>split | term<cr>A]], { desc = "Open terminal in horizontal split" })
vim.keymap.set("t", "<C-[>", [[<C-\><C-n>]], { desc = "Exit terminal mode with Ctrl+N" })
