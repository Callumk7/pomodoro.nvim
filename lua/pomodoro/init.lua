-- Main pomodoro module
local M = {}

-- Module version
M.version = '0.1.0'

-- Load submodules
M.timer = require('pomodoro.timer')
M.state = require('pomodoro.state')
M.ui = require('pomodoro.ui')

-- Initialize the plugin
function M.setup(opts)
  opts = opts or {}
  
  -- Initialize all submodules
  M.timer.setup()
  M.state.setup()
  M.ui.setup()
end

-- Start pomodoro timer
function M.start()
  M.timer.start()
end

-- Stop pomodoro timer
function M.stop()
  M.timer.stop()
end

return M
