-- Timer functionality module
local M = {}

-- Private timer instance
local timer = nil
local state = require("pomodoro.state")

-- Timer constants
local WORK_DURATION = 1500 -- 25 minutes in seconds

-- Initialize timer module
function M.setup()
  state.setup()
end

-- Start the timer
function M.start()
  if timer then return end -- Prevent multiple timers

  -- Update state
  state.update_state({
    mode = state.STATES.WORK,
    remaining_time = WORK_DURATION,
    is_running = true,
    is_paused = false
  })

  timer = vim.loop.new_timer()
  timer:start(
    0,
    1000,
    vim.schedule_wrap(function()
      local current = state.get_state()
      if current.remaining_time > 0 then
        state.update_state({ remaining_time = current.remaining_time - 1 })
        -- Print remaining time
        local minutes = math.floor(current.remaining_time / 60)
        local seconds = current.remaining_time % 60
        print(string.format("Pomodoro: %02d:%02d remaining", minutes, seconds))
      else
        M.stop()
      end
    end)
  )
end

-- Stop the timer
function M.stop()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end

  state.reset()
end

return M
