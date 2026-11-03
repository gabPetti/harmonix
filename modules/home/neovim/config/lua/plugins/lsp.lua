-- Language servers all come from modules/home/neovim/default.nix (no Mason),
-- so every server named here must have a matching package in that file.
--
-- nvim-lspconfig is used only for the per-server defaults it ships as
-- `lsp/<name>.lua` (cmd, filetypes, root markers); starting and configuring
-- servers is done with nvim's own vim.lsp.config / vim.lsp.enable.
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      -- Completion capabilities for every server, from blink.cmp.
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities({}, false),
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            -- The nvim runtime files are the library; LuaLS resolves `vim`
            -- and the api from them instead of flagging it as undefined.
            workspace = { checkThirdParty = false },
            codeLens = { enable = true },
            hint = { enable = true },
            doc = { privateName = { "^_" } },
          },
        },
      })

      vim.lsp.config("nixd", {
        -- nixd needs real Nix expressions to introspect. The flake path is
        -- resolved from the buffer's project root at attach time, so nothing
        -- here hardcodes /home/<user>/harmonix.
        before_init = function(_, config)
          local flake = config.root_dir
          if not flake or vim.fn.filereadable(flake .. "/flake.nix") == 0 then
            return
          end
          local function expr(attr)
            return ('(builtins.getFlake "%s").%s'):format(flake, attr)
          end
          config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
            nixd = {
              nixpkgs = { expr = expr("inputs.nixpkgs.legacyPackages.${builtins.currentSystem}") },
              options = {
                -- `laptop` is this flake's only host; see CLAUDE.md.
                nixos = { expr = expr("nixosConfigurations.laptop.options") },
                home_manager = {
                  expr = expr("nixosConfigurations.laptop.options.home-manager.users.type.getSubOptions []"),
                },
              },
            },
          })
        end,
        settings = {
          -- Formatting itself is driven by conform.nvim; this is what nixd
          -- uses when something asks it to format directly.
          nixd = { formatting = { command = { "nixpkgs-fmt" } } },
        },
      })

      vim.lsp.enable({ "lua_ls", "nixd", "jdtls" })

      -- nvim 0.11+ already maps grn/gra/grr/gri/gO and K; these are the gaps.
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("harmonix_lsp_attach", { clear = true }),
        callback = function(event)
          local function map(lhs, rhs, desc, mode)
            vim.keymap.set(mode or "n", lhs, rhs, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", vim.lsp.buf.definition, "Goto definition")
          map("gD", vim.lsp.buf.declaration, "Goto declaration")
          map("gy", vim.lsp.buf.type_definition, "Goto type definition")
          map("<leader>cr", vim.lsp.buf.rename, "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
          map("<leader>cs", vim.lsp.buf.signature_help, "Signature help")

          local client = vim.lsp.get_client_by_id(event.data.client_id)

          -- Inlay hints are off until asked for: useful when reading unfamiliar
          -- code, visual noise the rest of the time.
          if client and client:supports_method("textDocument/inlayHint") then
            map("<leader>uh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
            end, "Toggle inlay hints")
          end

          -- Highlight the other references to whatever is under the cursor.
          if client and client:supports_method("textDocument/documentHighlight") then
            local group = vim.api.nvim_create_augroup("harmonix_lsp_highlight_" .. event.buf, { clear = true })
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              group = group,
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              group = group,
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })
    end,
  },

  -- Scaffolding/annotations for the nvim Lua API and plugin types, so lua_ls
  -- knows about `vim.*` and the config's own `require`s.
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },
}
