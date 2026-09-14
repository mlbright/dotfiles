return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")

      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/" },
        },
      })

      -- Search with custom path
      vim.keymap.set("n", "<leader>fG", function()
        builtin.live_grep({
          prompt_title = "Grep from Directory",
          cwd = vim.fn.input("Directory: ", vim.fn.expand("~"), "dir"),
        })
      end)

      -- Quick search from cwd
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
    end,
  },
}
