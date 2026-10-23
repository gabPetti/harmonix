return {
	"akinsho/toggleterm.nvim",
	version = "*",
	opts = {
		size = function(term)
			if term.direction == "horizontal" then
				return 15
			elseif term.direction == "vertical" then
				return vim.o.columns * 0.3
			end
		end,
		open_mapping = [[<c-\>]], -- Default global toggle mapping
		hide_numbers = true,
		shade_terminals = true,
		shading_factor = 2,
		start_in_insert = true,
		insert_mappings = true,
		terminal_mappings = true,
		persist_size = true,
		persist_mode = true,
		direction = "float", -- Default direction for new toggles
		close_on_exit = true,
		shell = vim.o.shell,
		float_opts = {
			border = "curved",
			winblend = 0,
			highlights = {
				border = "Normal",
				background = "Normal",
			},
		},
	},
	keys = {
		-- Basic Toggle Controls
		{ "<C-\\>", "<cmd>ToggleTerm<cr>", desc = "Toggle Terminal", mode = { "n", "t" } },
		{ "<leader>tf", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle Term (Float)" },
		{ "<leader>th", "<cmd>ToggleTerm direction=horizontal<cr>", desc = "Toggle Term (Horizontal Split)" },
		{ "<leader>tv", "<cmd>ToggleTerm direction=vertical<cr>", desc = "Toggle Term (Vertical Split)" },

		-- Numbered Terminal Instances
		{ "<leader>t1", "<cmd>1ToggleTerm<cr>", desc = "Toggle Term #1" },
		{ "<leader>t2", "<cmd>2ToggleTerm<cr>", desc = "Toggle Term #2" },
		{ "<leader>t3", "<cmd>3ToggleTerm<cr>", desc = "Toggle Term #3" },

		{
			"<leader>tc",
			function()
				local Terminal = require("toggleterm.terminal").Terminal
				local cleide = Terminal:new({
					cmd = "claude",
					direction = "vertical",
					hidden = true,
				})
				cleide:toggle()
			end,
			desc = "Toggle Claude Code",
		},
	},
	config = function(_, opts)
		require("toggleterm").setup(opts)

		-- Terminal-mode navigation keymaps
		-- Allows using standard Neovim split movements (Ctrl + h/j/k/l) from inside terminal insert mode
		function _G.set_terminal_keymaps()
			local t_opts = { buffer = 0 }
			vim.keymap.set("t", "jk", [[<C-\><C-n>]], t_opts)
			vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], t_opts)
			vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], t_opts)
			vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], t_opts)
			vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], t_opts)
			vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], t_opts)
		end

		vim.cmd("autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()")
	end,
}
