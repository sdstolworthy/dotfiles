require('amazonq').setup({
  inline_suggest = true,
  filetypes = {
      'amazonq', 'bash', 'java', 'python', 'typescript', 'javascript', 'csharp', 'ruby', 'kotlin', 'sh', 'sql', 'c',
      'cpp', 'go', 'rust', 'lua',
  },
  on_chat_open = function()
    vim.cmd[[
      vertical topleft split
      set wrap breakindent nonumber norelativenumber nolist
    ]]
  end,
  -- Enable debug mode (for development).
  debug = false,
})
