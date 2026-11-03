-- Formatter binaries come from modules/home/neovim/default.nix, not Mason, so
-- every entry here must have a matching package in that file.
local prettier = { "prettierd", "prettier", stop_after_first = true }

return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = { "n", "x" },
        desc = "Format buffer/selection",
      },
      {
        "<leader>uf",
        function()
          vim.g.disable_autoformat = not vim.g.disable_autoformat
          vim.notify((vim.g.disable_autoformat and "Disabled" or "Enabled") .. " format on save")
        end,
        desc = "Toggle format on save",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        nix = { "nixpkgs_fmt" }, -- conform's recipe name; the binary is nixpkgs-fmt
        python = { "black" },
        java = { "google-java-format" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        javascript = prettier,
        javascriptreact = prettier,
        typescript = prettier,
        typescriptreact = prettier,
        json = prettier,
        jsonc = prettier,
        yaml = prettier,
        css = prettier,
        html = prettier,
        markdown = prettier,
      },
      -- A function rather than a table so <leader>uf can switch it off for the
      -- session without reloading the config.
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        return { timeout_ms = 1000, lsp_format = "fallback" }
      end,
    },
  },
}
