local function augroup(name)
  return vim.api.nvim_create_augroup("harmonix_" .. name, { clear = true })
end

-- Briefly highlight whatever was just yanked, as feedback for motions whose
-- reach isn't obvious.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Reopen a file on the line it was left on, unless that line no longer exists
-- (file shrank) or the buffer is a commit message, where line 1 is the point.
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_location"),
  callback = function(event)
    local exclude = { "gitcommit", "gitrebase" }
    if vim.tbl_contains(exclude, vim.bo[event.buf].filetype) then
      return
    end
    local mark = vim.api.nvim_buf_get_mark(event.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(event.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- `q` to close throwaway windows, which otherwise need :q and have no reason
-- to be a real buffer in the list.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "help", "qf", "man", "checkhealth", "lspinfo", "notify", "query" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Wrap and spell-check prose, where long lines are paragraphs rather than code.
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_prose"),
  pattern = { "markdown", "gitcommit", "text", "tex" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- Create the parent directory when writing to a path that doesn't exist yet,
-- instead of failing the write.
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+://") then -- oil://, fugitive://, …
      return
    end
    vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(event.match) or event.match, ":p:h"), "p")
  end,
})

-- Pick up changes made outside nvim (git checkout, formatter, another editor).
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- options.lua enables spell globally, which is right for real files and wrong
-- for everything else: terminals, pickers, help and quickfix would be a wall of
-- red squiggles. Every such buffer has a non-empty 'buftype', so one rule
-- covers them all.
--
-- 'spell' is window-local, and the window a buffer ends up in is not
-- necessarily the current one when the event fires (toggleterm spawns the job
-- before splitting, and opens a brand new float on every toggle). So the work
-- is deferred and applied to every window actually showing the buffer, rather
-- than to whatever window happens to be current.
vim.api.nvim_create_autocmd({ "TermOpen", "BufWinEnter", "WinEnter" }, {
  group = augroup("spell_only_in_files"),
  callback = function(event)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(event.buf) or vim.bo[event.buf].buftype == "" then
        return
      end
      for _, win in ipairs(vim.fn.win_findbuf(event.buf)) do
        vim.api.nvim_set_option_value("spell", false, { win = win, scope = "local" })
      end
    end)
  end,
})

-- Terminal buffers: no numbers or sign column, and start typing straight away.
vim.api.nvim_create_autocmd("TermOpen", {
  group = augroup("terminal_ui"),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd("startinsert")
  end,
})
