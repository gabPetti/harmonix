-- Pasting images from the clipboard, and viewing them in the buffer.
--
-- Two destinations, picked per buffer:
--
--   * inside an Obsidian vault -> <vault>/attachments, linked relatively, so
--     the note keeps working when Obsidian opens it (Obsidian cannot display
--     an image that lives outside the vault, relative or not).
--   * anywhere else -> ~/Pictures/Attachments, linked absolutely, since a
--     relative path from an arbitrary file would be a pile of ../.. that
--     breaks as soon as the file moves.
--
-- Viewing is snacks.image (enabled in snacks.lua), which draws the image
-- inline over the link via kitty's graphics protocol. It only recognises
-- links in the filetypes it ships tree-sitter queries for -- the `renderable`
-- list below -- so that is also where the paste mapping is bound.
local global_dir = vim.fn.expand("~/Pictures/Attachments")

local renderable = {
  "markdown",
  "html",
  "css",
  "scss",
  "javascript",
  "javascriptreact",
  "typescriptreact",
  "vue",
  "svelte",
  "typst",
  "norg",
  "tex",
}

local function vault_of_current()
  return vim.fs.root(vim.fn.expand("%:p:h"), ".obsidian")
end

-- Attachment directory for the current buffer. Inside a vault this is returned
-- relative to the note's own directory ("../attachments" one folder deep):
-- img-clip only rewrites the inserted path to be note-relative when the note's
-- directory differs from nvim's cwd, so handing it a note-relative dir_path is
-- what keeps the link relative in both cases.
local function dir_path()
  local note = vim.fn.expand("%:p:h")
  local vault = vault_of_current()
  if not vault then
    return global_dir
  end

  -- vim.fs.relpath only resolves descendants, and <vault>/attachments is a
  -- sibling of any nested note folder, so count the levels up by hand.
  local parts, dir = {}, note
  while dir ~= vault do
    local parent = vim.fs.dirname(dir)
    if parent == dir then -- walked off the top without finding the vault
      return vim.fs.joinpath(vault, "attachments")
    end
    table.insert(parts, "..")
    dir = parent
  end
  table.insert(parts, "attachments")
  return table.concat(parts, "/")
end

return {
  -- Images are hidden while inserting, so the line being edited shows the
  -- actual ![](…) link instead of a picture sitting on top of it.
  --
  -- snacks has no mode switch of its own: its inline renderer only ever drops
  -- the image on the *cursor line* (image/inline.lua `conceal`), and only for
  -- images it was told to conceal -- so it cannot clear a whole buffer, which
  -- is what "not while inserting" actually needs.
  --
  -- So the placements are cleared outright and rebuilt on the way out,
  -- via the BufWinEnter that snacks' updater already listens for. Both calls
  -- are public API, and rebuilding re-reads nothing: converted images are
  -- cached on disk. Only buffers that actually had images are touched.
  {
    "folke/snacks.nvim",
    init = function()
      local group = vim.api.nvim_create_augroup("harmonix_image_insert", { clear = true })

      vim.api.nvim_create_autocmd("InsertEnter", {
        group = group,
        callback = function(event)
          if not vim.b[event.buf].snacks_image_attached then
            return
          end
          Snacks.image.placement.clean(event.buf)
          vim.b[event.buf].harmonix_images_cleared = true
        end,
      })

      vim.api.nvim_create_autocmd("InsertLeave", {
        group = group,
        callback = function(event)
          if not vim.b[event.buf].harmonix_images_cleared then
            return
          end
          vim.b[event.buf].harmonix_images_cleared = nil
          vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = event.buf })
        end,
      })
    end,
  },

  {
    "HakonHarnes/img-clip.nvim",
    -- `cmd` rather than `keys`, because the mapping below is buffer-local and
    -- lazy needs a trigger it can see.
    cmd = { "PasteImage" },
    init = function()
      -- <leader>p is "paste from register z" globally (lua/config/keymaps.lua).
      -- Binding it per-buffer keeps the requested key for images without
      -- taking it away everywhere else.
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("harmonix_img_clip", { clear = true }),
        pattern = renderable,
        callback = function(event)
          vim.keymap.set("n", "<leader>p", "<cmd>PasteImage<cr>", {
            buffer = event.buf,
            desc = "Paste image from clipboard",
          })
        end,
      })
    end,
    opts = {
      default = {
        dir_path = dir_path,
        -- Both of these are per-buffer decisions, so they are functions:
        -- img-clip resolves any option by calling it when it is one.
        relative_to_current_file = function()
          return vault_of_current() ~= nil
        end,
        use_absolute_path = function()
          return vault_of_current() == nil
        end,
        -- Obsidian-style automatic names, so pasting is one keypress. Set
        -- prompt_for_file_name = true to be asked for a name instead.
        file_name = "pasted-%Y%m%d-%H%M%S",
        prompt_for_file_name = false,
        -- Leaves the cursor in the alt-text slot of ![](…) after pasting.
        insert_mode_after_paste = false,
      },
      filetypes = {
        -- Nothing to encode given the file names above, and leaving paths
        -- un-encoded keeps them readable and resolvable by snacks.image.
        markdown = { url_encode_path = false },
      },
    },
  },
}
