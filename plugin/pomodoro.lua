-- Pomodoro timer plugin for Neovim
if vim.g.loaded_pomodoro == 1 then
  return
end
vim.g.loaded_pomodoro = 1

-- Load the main module
vim.pomodoro = require('pomodoro')
