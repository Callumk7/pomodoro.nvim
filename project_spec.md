# Pomodoro.nvim - Technical Specification

## 1. Project Overview

**pomodoro.nvim** is a Neovim plugin that implements the Pomodoro time management technique. The plugin provides a configurable timer system that alternates between focused work sessions and breaks, with visual feedback and notifications integrated directly into the Neovim environment.

## 2. Requirements

### 2.1 Functional Requirements

1. **Timer Management**
   - FR1.1: Support configurable work session durations (default: 25 minutes)
   - FR1.2: Support configurable short break durations (default: 5 minutes)
   - FR1.3: Support configurable long break durations (default: 15 minutes)
   - FR1.4: Support configurable number of work sessions before a long break (default: 4)
   - FR1.5: Ability to start, pause, resume, and reset the timer
   - FR1.6: Automatic transition between work sessions and breaks

2. **User Interface**
   - FR2.1: Display current timer status in statusline
   - FR2.2: Show remaining time in minutes and seconds
   - FR2.3: Indicate current mode (Work/Short Break/Long Break)
   - FR2.4: Display completed session count
   - FR2.5: Provide notifications when sessions end
   - FR2.6: Support visual customization of display format

3. **Commands**
   - FR3.1: Provide Neovim commands for all timer operations
   - FR3.2: Support optional keybinding suggestions
   - FR3.3: Allow query of current timer status

### 2.2 Non-Functional Requirements

1. **Performance**
   - NFR1.1: Minimal CPU usage during timer operation
   - NFR1.2: No noticeable impact on editor performance
   - NFR1.3: Timer accuracy within 1 second

2. **Reliability**
   - NFR2.1: Timer should persist across buffer changes
   - NFR2.2: Timer state should be recoverable after unexpected Neovim crash
   - NFR2.3: Proper error handling for all operations

3. **Usability**
   - NFR3.1: Clear documentation and help text
   - NFR3.2: Intuitive command names and behaviors
   - NFR3.3: Sensible defaults requiring minimal configuration

## 3. Architecture

### 3.1 Module Structure

```
pomodoro.nvim/
├── lua/
│   └── pomodoro/
│       ├── init.lua       # Main entry point and API exports
│       ├── timer.lua      # Core timer functionality
│       ├── ui.lua         # UI rendering and notifications
│       ├── config.lua     # Configuration management
│       ├── commands.lua   # Neovim command definitions
│       ├── state.lua      # State management and persistence
│       └── utils.lua      # Utility functions
├── plugin/
│   └── pomodoro.lua       # Plugin registration and initialization
├── doc/
│   └── pomodoro.txt       # Documentation in Neovim help format
├── README.md              # User documentation
└── LICENSE                # License information
```

### 3.2 Module Responsibilities

1. **init.lua**
   - Export public API
   - Initialize plugin
   - Load configuration
   - Set up auto-commands

2. **timer.lua**
   - Timer creation and management
   - Session tracking and transitions
   - Time calculation

3. **ui.lua**
   - Statusline component rendering
   - Notification management
   - Visual indicators

4. **config.lua**
   - Default configuration
   - User configuration handling
   - Configuration validation

5. **commands.lua**
   - Register Neovim commands
   - Command implementation
   - Command argument parsing

6. **state.lua**
   - State persistence
   - State restoration
   - Session tracking

7. **utils.lua**
   - Time formatting
   - Common utility functions
   - Error handlers

## 4. Data Structures

### 4.1 Configuration Object

```lua
-- Default configuration
{
  -- Duration in minutes
  durations = {
    work = 25,
    short_break = 5,
    long_break = 15,
  },
  -- Number of work sessions before a long break
  sessions_before_long_break = 4,
  -- UI settings
  ui = {
    -- Format string for statusline
    statusline_format = "Pomodoro: %s %02d:%02d [%d]", -- mode, min, sec, count
    -- Colors for different modes
    colors = {
      work = "PomodoroWork", -- link to highlight group
      short_break = "PomodoroShortBreak",
      long_break = "PomodoroLongBreak",
    },
    -- Whether to show countdown in window title
    update_window_title = false,
  },
  -- Notification settings
  notifications = {
    -- Whether to show notifications
    enabled = true,
    -- Custom sound or command to run on transition
    sound = nil, -- e.g., "afplay /path/to/sound.mp3"
    -- Notification timeout in ms
    timeout = 5000,
  },
  -- State persistence between Neovim sessions
  persistence = {
    -- Whether to save state between sessions
    enabled = true,
    -- File to save state to
    file = vim.fn.stdpath("data") .. "/pomodoro_state.json",
  },
  -- Auto commands
  hooks = {
    -- Functions to call when timer starts
    on_start = nil,
    -- Functions to call when work session ends
    on_work_complete = nil,
    -- Functions to call when break ends
    on_break_complete = nil,
  },
}
```

### 4.2 Timer State Object

```lua
{
  -- Current timer mode: "work", "short_break", "long_break"
  mode = "work",
  -- Time remaining in seconds
  remaining_time = 1500, -- 25 minutes in seconds
  -- Whether timer is running
  is_running = false,
  -- Whether timer is paused
  is_paused = false,
  -- Number of completed work sessions
  completed_sessions = 0,
  -- When the current session started (Unix timestamp)
  session_start_time = 1679012345,
  -- When the timer was last paused (Unix timestamp)
  paused_at = nil,
}
```

## 5. API Specification

### 5.1 Public API

```lua
-- Start a new timer, transitioning to work mode if not specified
pomodoro.start(mode)

-- Pause the current timer
pomodoro.pause()

-- Resume a paused timer
pomodoro.resume()

-- Stop and reset the timer
pomodoro.reset()

-- Skip to the next session (work -> break or break -> work)
pomodoro.skip()

-- Get the current timer status
pomodoro.status()

-- Get a formatted status string for statusline integration
pomodoro.statusline()

-- Configure the plugin
pomodoro.setup(config)
```

### 5.2 Commands

```
:PomodoroStart [work|short_break|long_break]  - Start a new timer with optional mode
:PomodoroPause                               - Pause the current timer
:PomodoroResume                              - Resume a paused timer
:PomodoroReset                               - Stop and reset the timer
:PomodoroSkip                                - Skip to the next session
:PomodoroStatus                              - Display the current timer status
```

## 6. Detailed Implementation Specifications

### 6.1 Timer Implementation

The core timer will use `vim.loop.new_timer()` (Neovim's interface to libuv timers) for accurate, non-blocking time tracking:

```lua
-- timer.lua
local M = {}
local timer = nil
local state = require("pomodoro.state")
local config = require("pomodoro.config")
local ui = require("pomodoro.ui")
local utils = require("pomodoro.utils")

function M.start(mode)
  -- Stop existing timer if any
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
  
  -- Initialize state
  if mode then
    state.mode = mode
  else
    -- Default to work mode if none specified
    state.mode = "work"
  end
  
  -- Set duration based on mode
  if state.mode == "work" then
    state.remaining_time = config.durations.work * 60
  elseif state.mode == "short_break" then
    state.remaining_time = config.durations.short_break * 60
  else -- long_break
    state.remaining_time = config.durations.long_break * 60
  end
  
  state.is_running = true
  state.is_paused = false
  state.session_start_time = os.time()
  state.paused_at = nil
  
  -- Create and start timer
  timer = vim.loop.new_timer()
  timer:start(0, 1000, vim.schedule_wrap(function()
    if state.remaining_time > 0 then
      state.remaining_time = state.remaining_time - 1
      ui.update()
    else
      M.session_completed()
    end
  end))
  
  -- Execute hooks
  if config.hooks.on_start then
    utils.safe_call(config.hooks.on_start, state.mode)
  end
  
  -- Save state
  state.save()
  ui.update()
end

function M.session_completed()
  if state.mode == "work" then
    -- Work session completed
    state.completed_sessions = state.completed_sessions + 1
    if state.completed_sessions % config.sessions_before_long_break == 0 then
      ui.notify("Work session completed! Time for a long break.")
      if config.hooks.on_work_complete then
        utils.safe_call(config.hooks.on_work_complete, "long_break")
      end
      M.start("long_break")
    else
      ui.notify("Work session completed! Time for a short break.")
      if config.hooks.on_work_complete then
        utils.safe_call(config.hooks.on_work_complete, "short_break")
      end
      M.start("short_break")
    end
  else
    -- Break completed
    ui.notify("Break completed! Back to work.")
    if config.hooks.on_break_complete then
      utils.safe_call(config.hooks.on_break_complete)
    end
    M.start("work")
  end
end

-- Other functions: pause, resume, reset, status...

return M
```

### 6.2 State Persistence

```lua
-- state.lua
local M = {
  mode = "work",
  remaining_time = 0,
  is_running = false,
  is_paused = false,
  completed_sessions = 0,
  session_start_time = nil,
  paused_at = nil,
}

local config = require("pomodoro.config")
local utils = require("pomodoro.utils")

function M.save()
  if not config.persistence.enabled then
    return
  end
  
  local state_to_save = {
    mode = M.mode,
    remaining_time = M.remaining_time,
    is_running = M.is_running,
    is_paused = M.is_paused,
    completed_sessions = M.completed_sessions,
    session_start_time = M.session_start_time,
    paused_at = M.paused_at,
  }
  
  local json = vim.fn.json_encode(state_to_save)
  
  -- Ensure directory exists
  local dir = vim.fn.fnamemodify(config.persistence.file, ":h")
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
  
  -- Write state to file
  local file = io.open(config.persistence.file, "w")
  if file then
    file:write(json)
    file:close()
  else
    utils.log_error("Failed to save state to " .. config.persistence.file)
  end
end

function M.load()
  if not config.persistence.enabled then
    return false
  end
  
  if vim.fn.filereadable(config.persistence.file) == 0 then
    return false
  end
  
  local file = io.open(config.persistence.file, "r")
  if not file then
    return false
  end
  
  local content = file:read("*all")
  file:close()
  
  if not content or content == "" then
    return false
  end
  
  local ok, state = pcall(vim.fn.json_decode, content)
  if not ok or not state then
    utils.log_error("Failed to parse saved state")
    return false
  end
  
  -- Restore state
  M.mode = state.mode
  M.remaining_time = state.remaining_time
  M.is_running = state.is_running
  M.is_paused = state.is_paused
  M.completed_sessions = state.completed_sessions
  M.session_start_time = state.session_start_time
  M.paused_at = state.paused_at
  
  -- Handle time elapsed while Neovim was closed
  if M.is_running and not M.is_paused and M.session_start_time then
    local elapsed = os.time() - M.session_start_time
    M.remaining_time = math.max(0, M.remaining_time - elapsed)
  end
  
  return true
end

-- Other state management functions...

return M
```

### 6.3 UI Implementation

```lua
-- ui.lua
local M = {}
local state = require("pomodoro.state")
local config = require("pomodoro.config")

function M.update()
  -- Force statusline refresh
  vim.cmd("redrawstatus")
  
  -- Update window title if enabled
  if config.ui.update_window_title then
    local title = M.get_status_text()
    vim.o.titlestring = title
  end
end

function M.get_status_text()
  local mode_text = state.mode:gsub("_", " "):gsub("^%l", string.upper)
  local minutes = math.floor(state.remaining_time / 60)
  local seconds = state.remaining_time % 60
  
  return string.format(
    config.ui.statusline_format,
    mode_text,
    minutes,
    seconds,
    state.completed_sessions
  )
end

function M.statusline()
  if not state.is_running and state.remaining_time == 0 then
    return ""
  end
  
  local status = M.get_status_text()
  
  -- Apply mode-specific highlighting
  local hl_group = config.ui.colors[state.mode]
  if hl_group then
    return "%#" .. hl_group .. "#" .. status .. "%*"
  else
    return status
  end
end

function M.notify(message)
  if not config.notifications.enabled then
    return
  end
  
  -- Send notification
  vim.notify(message, vim.log.levels.INFO, {
    title = "Pomodoro Timer",
    timeout = config.notifications.timeout,
  })
  
  -- Play sound if configured
  if config.notifications.sound then
    vim.fn.jobstart(config.notifications.sound, {detach = true})
  end
end

-- Setup highlight groups
function M.setup_highlights()
  vim.api.nvim_set_hl(0, "PomodoroWork", {fg = "#ff6347"})  -- Tomato red
  vim.api.nvim_set_hl(0, "PomodoroShortBreak", {fg = "#98fb98"})  -- Pale green
  vim.api.nvim_set_hl(0, "PomodoroLongBreak", {fg = "#87cefa"})  -- Light sky blue
end

return M
```

### 6.4 Commands Implementation

```lua
-- commands.lua
local M = {}
local timer = require("pomodoro.timer")
local ui = require("pomodoro.ui")
local state = require("pomodoro.state")

function M.setup()
  vim.api.nvim_create_user_command("PomodoroStart", function(opts)
    local mode = opts.args
    if mode == "" then
      mode = "work"
    elseif mode ~= "work" and mode ~= "short_break" and mode ~= "long_break" then
      vim.notify("Invalid mode: " .. mode, vim.log.levels.ERROR)
      return
    end
    timer.start(mode)
  end, {
    nargs = "?",
    complete = function()
      return {"work", "short_break", "long_break"}
    end,
    desc = "Start a Pomodoro timer",
  })
  
  vim.api.nvim_create_user_command("PomodoroPause", function()
    timer.pause()
  end, {desc = "Pause the Pomodoro timer"})
  
  vim.api.nvim_create_user_command("PomodoroResume", function()
    timer.resume()
  end, {desc = "Resume the Pomodoro timer"})
  
  vim.api.nvim_create_user_command("PomodoroReset", function()
    timer.reset()
  end, {desc = "Reset the Pomodoro timer"})
  
  vim.api.nvim_create_user_command("PomodoroSkip", function()
    timer.skip()
  end, {desc = "Skip to the next Pomodoro session"})
  
  vim.api.nvim_create_user_command("PomodoroStatus", function()
    local status = M.get_status_text()
    vim.notify(status, vim.log.levels.INFO)
  end, {desc = "Show current Pomodoro status"})
end

return M
```

## 7. Error Handling Strategy

### 7.1 Error Types and Handling Approach

1. **Configuration Errors**
   - Validate all configuration values during setup
   - Provide informative error messages for invalid configurations
   - Fall back to defaults for invalid values

2. **Timer Errors**
   - Handle timer creation failures
   - Recover from timer interruptions
   - Gracefully handle Neovim restart during an active session

3. **File I/O Errors**
   - Handle state file read/write failures
   - Use error logging with fallbacks

4. **Hook Execution Errors**
   - Wrap all hook calls in protected calls
   - Log errors without disrupting the timer operation

### 7.2 Error Logging Function

```lua
-- utils.lua
function M.log_error(message, details)
  vim.notify(
    "Pomodoro Error: " .. message .. (details and ("\n" .. vim.inspect(details)) or ""),
    vim.log.levels.ERROR
  )
end

function M.safe_call(fn, ...)
  local status, err = pcall(fn, ...)
  if not status then
    M.log_error("Hook execution failed", err)
  end
  return status
end
```

## 8. Testing Strategy

### 8.1 Unit Testing

1. **Timer Logic Tests**
   - Test timing calculation
   - Test session transition logic
   - Test pause/resume functionality

2. **Configuration Tests**
   - Test configuration validation
   - Test merging default and user configurations

3. **State Management Tests**
   - Test state serialization/deserialization
   - Test state recovery

### 8.2 Integration Testing

1. **UI Integration**
   - Test statusline integration
   - Test notification delivery

2. **Command Integration**
   - Test command registration
   - Test command execution

### 8.3 Manual Testing Checklist

1. **Basic Functionality**
   - [ ] Start a work session
   - [ ] Complete a work session and transition to break
   - [ ] Complete a break and transition to work
   - [ ] Pause and resume timer
   - [ ] Reset timer

2. **Edge Cases**
   - [ ] Start a new timer while one is running
   - [ ] Close and reopen Neovim during a session
   - [ ] Rapid start/pause/resume commands
   - [ ] Session transitions when paused

3. **Configuration Testing**
   - [ ] Test with custom durations
   - [ ] Test with custom UI settings
   - [ ] Test with hooks

## 9. Implementation Plan

### 9.1 Phase 1: Core Functionality

1. Set up project structure
2. Implement basic timer functionality
3. Implement state management
4. Create basic UI components
5. Register Neovim commands

### 9.2 Phase 2: Refinement

1. Add configuration options
2. Implement state persistence
3. Add notification system
4. Create statusline integration

### 9.3 Phase 3: Polish

1. Implement hooks
2. Add documentation
3. Create highlight groups
4. Optimize performance

### 9.4 Phase 4: Testing and Release

1. Unit testing
2. Integration testing
3. Manual testing
4. Documentation review
5. Initial release

## 10. Documentation Guidelines

### 10.1 In-Code Documentation

- Each module should have a header comment explaining its purpose
- Public functions should have detailed documentation
- Complex logic should have explanatory comments

### 10.2 User Documentation

- README.md with:
  - Installation instructions
  - Basic usage
  - Configuration options
  - Examples
  - Screenshots

- Neovim help file (doc/pomodoro.txt) with:
  - Complete command reference
  - Configuration reference
  - Troubleshooting section

## 11. Compatibility Requirements

- Neovim >= 0.5.0
- Lua >= 5.1
- No external dependencies

This technical specification provides a comprehensive blueprint for implementing the Pomodoro.nvim plugin, covering all aspects from architecture to testing strategy. A developer can use this document to begin implementation immediately.
