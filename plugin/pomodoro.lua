-- Pomodoro timer plugin for Neovim
if vim.g.loaded_pomodoro == 1 then
  return
end
vim.g.loaded_pomodoro = 1

-- Load the main module
vim.pomodoro = require('pomodoro')

-- Register commands
vim.api.nvim_create_user_command('PomodoroStart', function()
  vim.pomodoro.start()
end, {})

vim.api.nvim_create_user_command('PomodoroStop', function()
  vim.pomodoro.stop()
end, {})
