-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {

    {
        'github/copilot.vim',
        -- lazy = true,
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

    
}
