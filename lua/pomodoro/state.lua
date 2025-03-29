-- State management module
local M = {}

-- State constants
M.STATES = {
	IDLE = "idle",
	WORK = "work",
	BREAK = "break",
	PAUSED = "paused",
}

-- Timer state
local state = {
	mode = M.STATES.IDLE,
	remaining_time = 1500, -- 25 minutes in seconds
	is_running = false,
	is_paused = false,
}

-- Get current state (returns a copy to prevent direct mutation)
function M.get_state()
	return vim.deepcopy(state)
end

-- Update state with new values
function M.update_state(new_state)
	for k, v in pairs(new_state) do
		state[k] = v
	end
end

-- Reset state to defaults
function M.reset()
	state.mode = M.STATES.IDLE
	state.remaining_time = 1500
	state.is_running = false
	state.is_paused = false
end

-- Initialize state module
function M.setup()
	M.reset()
end

return M
