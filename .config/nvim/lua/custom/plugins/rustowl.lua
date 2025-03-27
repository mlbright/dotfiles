return {
  { -- INFO: Visualizes ownership movement and lifetimes of variables
    'cordx56/rustowl',
    dependencies = { 'neovim/nvim-lspconfig' },
    -- need to cd first to ensure cargo honors rust-toolchain.toml
    build = 'cd rustowl && cargo install --path . --locked && cargo clean',
    ft = { 'rust' },
    config = function()
      local lspconfig = require 'lspconfig'
      lspconfig.rustowlsp.setup {}
    end,
  },
}
