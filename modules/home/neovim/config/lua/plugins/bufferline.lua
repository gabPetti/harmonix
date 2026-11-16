return {
  -- Buffer tabs along the top: one tab per open file, with a ● marker on
  -- modified buffers. The cycle keys live here rather than in keymaps.lua
  -- because :bnext follows buffer numbers, which drifts from the visible tab
  -- order as soon as buffers are closed or moved.
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    -- mini.icons' nvim-web-devicons mock (editor.lua) has to be in place
    -- before setup, or the tabs lose their filetype icons.
    dependencies = { "echasnovski/mini.nvim" },
    opts = {
      options = {
        -- Closing through Snacks keeps the window layout, same as <leader>bD.
        close_command = function(n)
          Snacks.bufdelete(n)
        end,
        right_mouse_command = function(n)
          Snacks.bufdelete(n)
        end,
        diagnostics = "nvim_lsp",
        -- A single tab carries no information, and hiding it keeps the
        -- dashboard free of an empty strip; tabs appear with the second file.
        always_show_bufferline = false,
      },
    },
    -- stylua: ignore
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin buffer" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close other buffers" },
    },
  },
}
