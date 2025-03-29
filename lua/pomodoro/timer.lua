-- Timer functionality module
local M = {}

-- Private timer state
local timer = nil
local state = require('pomodoro.state')

-- Timer constants
local WORK_DURATION = 1500 -- 25 minutes in seconds

-- Initialize timer module
function M.setup()
  -- Reset initial state
  M.remaining = WORK_DURATION
  M.active = false
end

-- Start the timer
function M.start()
  if timer then return end -- Prevent multiple timers
  
  M.active = true
  M.remaining = WORK_DURATION
  
  timer = vim.loop.new_timer()
  timer:start(0, 1000, vim.schedule_wrap(function()
    if M.remaining > 0 then
      M.remaining = M.remaining - 1
    else
      M.stop()
    end
  end))
end

-- Stop the timer
function M.stop()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
  
  M.active = false
  M.remaining = WORK_DURATION
end

return M
