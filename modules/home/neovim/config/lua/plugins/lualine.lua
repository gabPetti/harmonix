return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        options = {
          theme = "tokyonight",
          globalstatus = true, -- matches laststatus=3 in options.lua
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          disabled_filetypes = { statusline = { "dashboard", "snacks_dashboard" } },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = {
            { "diagnostics" },
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1 }, -- path relative to cwd
          },
          lualine_x = {
            -- Which LSP clients are attached, as a reminder when one silently
            -- failed to start.
            {
              function()
                local names = {}
                for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
                  table.insert(names, client.name)
                end
                return table.concat(names, " ")
              end,
              icon = " ",
            },
            { "diff" },
          },
          lualine_y = { { "progress" }, { "location" } },
          lualine_z = {
            function()
              return os.date("%R")
            end,
          },
        },
        extensions = { "lazy", "trouble", "quickfix", "toggleterm", "man" },
      }
    end,
  },
}
