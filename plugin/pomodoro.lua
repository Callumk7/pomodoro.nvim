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

vim.api.nvim_create_user_command('PomodoroPause', function()
  vim.pomodoro.pause()
end, {})

vim.api.nvim_create_user_command('PomodoroResume', function()
  vim.pomodoro.resume()
end, {})

vim.api.nvim_create_user_command('PomodoroStop', function()
  vim.pomodoro.stop()
end, {})

-- Debug command to print current state
vim.api.nvim_create_user_command('PomodoroDebug', function()
  local state = require('pomodoro.state')
  local current = state.get_state()
  print("Pomodoro Debug State:")
  print("Mode:", current.mode)
  print("Remaining Time:", current.remaining_time)
  print("Is Running:", current.is_running)
  print("Is Paused:", current.is_paused)
  vim.pretty_print(current)
end, {})
