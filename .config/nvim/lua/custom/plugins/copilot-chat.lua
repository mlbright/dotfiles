return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'github/copilot.vim' }, -- or zbirenbaum/copilot.lua
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
      model = 'claude-3.7-sonnet',
    },
    -- See Commands section for default commands if you want to lazy load on them
    keys = {
      { '<leader>zc', ':CopilotChat<cr>', mode = 'n', desc = 'Copilot Chat' },
      { '<leader>zR', ':CopilotChatRefresh<cr>', desc = 'Copilot Chat Refresh' },
      { '<leader>zS', ':CopilotChatSettings<cr>', desc = 'Copilot Chat Settings' },
      { '<leader>ze', ':CopilotChatExplain<cr>', mode = 'v', desc = 'Explain Code' },
      { '<leader>zr', ':CopilotChatReview<cr>', mode = 'v', desc = 'Review Code' },
      { '<leader>zf', ':CopilotChatFix<cr>', mode = 'v', desc = 'Fix Code Issues' },
      { '<leader>zt', ':CopilotChatTests<cr>', mode = 'v', desc = 'Generate Tests' },
      { '<leader>zm', ':CopilotChatCommit<cr>', mode = 'n', desc = 'Generate Commit Message' },
      { '<leader>zm', ':CopilotChatCommit<cr>', mode = 'v', desc = 'Generate Commit For Selection' },
      { '<leader>zd', ':CopilotChatDocs<cr>', mode = 'v', desc = 'Generate Documentation' },
      { '<leader>zo', ':CopilotChatOptimize<cr>', mode = 'v', desc = 'Optimize Code' },
    },
  },
}
