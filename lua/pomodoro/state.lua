-- State management module
local M = {}

-- State constants
M.STATES = {
  IDLE = 'idle',
  WORK = 'work',
  BREAK = 'break',
  PAUSED = 'paused'
}

-- Current state
M.current = M.STATES.IDLE

-- Initialize state module
function M.setup()
  -- State setup code will go here
end

return M
