-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {

  {
    'github/copilot.vim',
    -- lazy = true,
    init = function()
      -- By default copilot.vim shells out to `npx @github/copilot-language-server`
      -- to fetch the newest server. That package's `bin` path points outside its
      -- own directory, so npx fails to link it ("copilot-language-server: command
      -- not found", exit 127). Setting this to 0 uses the copy bundled with the
      -- plugin instead, which works and needs no network.
      vim.g.copilot_npx_command = 0
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'github/copilot.vim' }, -- or zbirenbaum/copilot.lua
      { 'nvim-lua/plenary.nvim', branch = 'master' }, -- for curl, log and async functions
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
  -- NOTE: nvim-treesitter itself is configured in init.lua. Adding a second
  -- spec with a `config` function here would override that one entirely, so
  -- add new parsers to `ensure_installed` in init.lua instead.

  -- Add nvim-treesitter-context for better context awareness
  {
    'nvim-treesitter/nvim-treesitter-context',
    config = function()
      require('treesitter-context').setup {
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      }
    end,
  },
}
