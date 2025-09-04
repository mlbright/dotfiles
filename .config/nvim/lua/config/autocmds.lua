-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Completely disable markdown code block rendering
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    -- Clear all syntax highlighting
    vim.cmd("syntax clear")
    vim.cmd("syntax off")
    vim.bo.syntax = ""
    -- Override any potential highlight groups
    vim.cmd("highlight! clear markdownCode")
    vim.cmd("highlight! clear markdownCodeBlock")
    vim.cmd("highlight! clear markdownCodeDelimiter")
    vim.cmd("highlight! clear @markup.raw.block.markdown")
    vim.cmd("highlight! clear @markup.raw.markdown")
    vim.wo.conceallevel = 0
  end,
})
