# 🍅 Pomodoro.nvim

A simple Pomodoro timer plugin for Neovim, created with the help of AI pair programming tools. (Aider, Claude 3.5)

## Features

- 25-minute work sessions with 5-minute short breaks
- Long break (15 minutes) after 4 work sessions
- Floating timer window with transparent background
- Start, pause, resume, and stop functionality
- Session tracking and automatic transitions
- Debug command to check timer state

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "callumk7/pomodoro.nvim",
    config = function()
        require("pomodoro").setup()
    end
}
```

## Usage

The plugin provides the following commands:

- `:PomodoroStart` - Start a new timer
- `:PomodoroPause` - Pause the current timer
- `:PomodoroResume` - Resume a paused timer
- `:PomodoroStop` - Stop the current timer
- `:PomodoroDebug` - Print current timer state

## Development

This plugin was developed using AI pair programming tools:
- [Aider](https://github.com/paul-gauthier/aider) - AI coding assistant
- Claude 3.5 - Large language model from Anthropic

The combination of these tools helped create a functional plugin while maintaining clean code and proper Neovim integration practices.

## License

MIT
