-- nvim-treesitter's `main` branch: parsers are installed explicitly and
-- highlighting is started per filetype, instead of the old `highlight.enable`
-- module. `tree-sitter` and `gcc` (needed to build parsers) come from
-- modules/home/neovim/default.nix.
local ensure_installed = {
  "bash",
  "c",
  "css",
  "diff",
  "git_config",
  "gitcommit",
  "gitignore",
  "html",
  "java",
  "javascript",
  "json",
  "lua",
  "luadoc",
  "markdown",
  "markdown_inline",
  "nix",
  "printf",
  "python",
  "qmljs",
  "query",
  "regex",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "xml",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      -- Install whatever is missing in the background; already-installed
      -- parsers are skipped, so this is a no-op on a warm config.
      require("nvim-treesitter").install(ensure_installed)

      -- jsonc has no parser of its own upstream; the json one handles it.
      vim.treesitter.language.register("json", "jsonc")

      -- The main branch leaves starting highlighting to the user. One FileType
      -- rule covers every filetype that happens to have a parser installed;
      -- pcall because filetypes without one would otherwise error.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("harmonix_treesitter_start", { clear = true }),
        callback = function(event)
          if pcall(vim.treesitter.start, event.buf) then
            -- Tree-sitter-aware indent and fold expressions, per buffer.
            vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
