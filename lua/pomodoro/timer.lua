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
	if timer then
		return
	end -- Prevent multiple timers

	-- Update state
	state.update_state({
		mode = state.STATES.WORK,
		remaining_time = WORK_DURATION,
		is_running = true,
		is_paused = false,
	})

	timer = vim.loop.new_timer()
	timer:start(
		0,
		1000,
		vim.schedule_wrap(function()
			local current = state.get_state()
			if current.remaining_time > 0 then
				state.update_state({ remaining_time = current.remaining_time - 1 })
				-- Update UI
				require("pomodoro.ui").update()
			else
				-- Session completed
				if current.mode == state.STATES.WORK then
					-- Work session completed
					state.update_state({ completed_sessions = (current.completed_sessions or 0) + 1 })

					-- Determine break type
					if current.completed_sessions % current.sessions_before_long_break == 0 then
						-- Time for a long break
						state.update_state({
							mode = state.STATES.BREAK,
							remaining_time = 900, -- 15 minutes
						})
					else
						-- Short break
						state.update_state({
							mode = state.STATES.BREAK,
							remaining_time = 300, -- 5 minutes
						})
					end
				else
					-- Break completed, start new work session
					state.update_state({
						mode = state.STATES.WORK,
						remaining_time = 1500, -- 25 minutes
					})
				end
				require("pomodoro.ui").update()
			end
		end)
	)
end

-- Pause the timer
function M.pause()
	if not timer then
		return
	end

	timer:stop()
	timer:close()
	timer = nil

	state.update_state({ is_paused = true })
end

-- Resume the timer
function M.resume()
	if timer then
		return
	end

	state.update_state({ is_paused = false })
	M.start()
end

-- Stop the timer
function M.stop()
	if timer then
		timer:stop()
		timer:close()
		timer = nil
	end

	state.reset()
	require("pomodoro.ui").hide()
end

return M
