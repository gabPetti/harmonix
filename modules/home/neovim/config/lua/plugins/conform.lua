return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			java = { "google-java-format" },
			nix = { "nixpkgs-fmt" },
			python = { "black" },
			javascript = { "prettierd" },
			typescript = { "prettierd" },
			javascriptreact = { "prettierd" },
			typescriptreact = { "prettierd" },
			fish = {},
		},

		formatters = {
			["nixpkgs-fmt"] = {
				command = "nixpkgs-fmt",
			},
		},
	},
}
