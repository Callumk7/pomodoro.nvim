-- UI components module
local M = {}

-- UI state
M.visible = false
local win_id = nil
local buf_id = nil

-- Window configuration
local function get_win_config()
	return {
		relative = "editor",
		width = 20,
		height = 3,
		row = 1,
		col = math.floor(vim.o.columns - 22),
		style = "minimal",
		border = "rounded",
	}
end

-- Initialize UI module
function M.setup()
	-- Create buffer for the timer window if it doesn't exist or isn't valid
	if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
		buf_id = vim.api.nvim_create_buf(false, true)
	end

	-- Only set options if we have a valid buffer
	if buf_id and vim.api.nvim_buf_is_valid(buf_id) then
		vim.api.nvim_buf_set_option_value(buf_id, "bufhidden", "hide")
		vim.api.nvim_buf_set_option_value(buf_id, "modifiable", false)
	else
		vim.notify("Failed to create pomodoro buffer", vim.log.levels.ERROR)
	end
end

-- Show the timer window
function M.show()
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		return
	end

	-- Ensure we have a valid buffer
	if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
		M.setup()
	end

	if buf_id then
		win_id = vim.api.nvim_open_win(buf_id, false, get_win_config())
		vim.api.nvim_win_set_option_value(win_id, "winblend", 15)
		M.visible = true
	end
end

-- Hide the timer window
function M.hide()
	if win_id and vim.api.nvim_win_is_valid(win_id) then
		vim.api.nvim_win_close(win_id, true)
		win_id = nil
	end
	M.visible = false
end

-- Update the timer display
function M.update()
	-- Ensure we have a valid buffer
	if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
		M.setup()
	end

	-- Double check we have a valid buffer after setup
	if not buf_id or not vim.api.nvim_buf_is_valid(buf_id) then
		vim.notify("Cannot update pomodoro display: invalid buffer", vim.log.levels.ERROR)
		return
	end

	local state = require("pomodoro.state")
	local current = state.get_state()

	-- Format the timer display
	local minutes = math.floor(current.remaining_time / 60)
	local seconds = current.remaining_time % 60
	local mode = current.mode:gsub("^%l", string.upper)

	local lines = {
		string.format("🍅 %s", mode),
		string.format("%02d:%02d", minutes, seconds),
		string.format("Sessions: %d", current.completed_sessions or 0),
	}

	-- Update buffer content
	vim.api.nvim_buf_set_option_value(buf_id, "modifiable", true)
	vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
	vim.api.nvim_buf_set_option_value(buf_id, "modifiable", false)

	-- Show window if not visible
	if not M.visible then
		M.show()
	end
end

return M
