<div align="center">

# aufgabe

[![Test](https://github.com/electerious/aufgabe/actions/workflows/test.yml/badge.svg)](https://github.com/electerious/aufgabe/actions/workflows/test.yml)

Daily task logging made simple.

<br/>

![aufgabe in action](https://s.electerious.com/images/aufgabe/readme.png)

</div>

## Contents

- [Description](#description)
- [Requirements](#requirements)
- [Install](#install)
- [Usage](#usage)
- [Configuration](#configuration)
- [Development](#development)
- [Miscellaneous](#miscellaneous)

## Description

`aufgabe` is a simple bash CLI tool for logging daily tasks and generating weekly summaries. It stores tasks as plain text files and provides commands to add tasks to specific days, view logged tasks, and generate weekly summaries.

## Requirements

- macOS (uses BSD `date` commands)
- Bash 3.2 or higher (included with macOS)
- For testing: [bats-core](https://github.com/bats-core/bats-core)

## Install

Clone the repository:

```bash
git clone https://github.com/electerious/aufgabe.git
cd aufgabe
```

Make the script executable:

```bash
chmod +x bin/aufgabe
```

Add to your PATH (optional):

```bash
# Using symlink
sudo ln -s "$(pwd)/bin/aufgabe" /usr/local/bin/aufgabe

# Or add to PATH in your shell profile (~/.zshrc or ~/.bash_profile)
export PATH="$PATH:$(pwd)/bin"
```

## Usage

### Add Tasks

```bash
# Add a task to today
aufgabe add "Fixed a bug in the login form"

# Add a task to yesterday
aufgabe add "Code review for PR #123" --yesterday

# Add a task to a specific date
aufgabe add "Planning meeting" --date 2026-02-27

# Skip adding if the exact same task already exists for that day
aufgabe add "Fixed a bug in the login form" --skip-duplicate
```

### View Tasks

```bash
# View today's tasks
aufgabe list

# View tasks for a specific date
aufgabe list --date 2026-02-27
```

### Weekly Summary

```bash
# Show this week's tasks (Monday-Sunday)
aufgabe weekly

# Show last week's tasks
aufgabe weekly --offset -1

# Show next week's tasks
aufgabe weekly --offset 1
```

The optional `--offset` flag selects a week relative to the current week. Negative values select previous weeks, positive values select future weeks, and `0` selects the current week. The default is `0` when no offset is provided.

The weekly summary format:

- Each day's tasks are comma-separated on a single line
- Each day appears on its own line
- Days without tasks are omitted

Example output:

```
Fixed login bug, Added new feature, Code review
Updated documentation, Team meeting
Deployed to production, Fixed critical bug
```

### Help and Version

```bash
# Show help
aufgabe --help
aufgabe -h

# Show version
aufgabe --version
aufgabe -v
```

## Configuration

### Environment Variables

- `AUFGABE_DIR` - Custom data directory (default: `~/.aufgabe`)

```bash
# Use a custom directory
export AUFGABE_DIR="$HOME/Documents/task-logs"
aufgabe add "My task"
```

### Data Storage

Tasks are stored as plain text files in `~/.aufgabe/` (or your custom directory):

```
~/.aufgabe/
  ├── 2026-02-24.txt
  ├── 2026-02-25.txt
  ├── 2026-02-26.txt
  └── 2026-02-27.txt
```

Each file contains one task per line:

```
Fixed a bug in the login form
Code review for PR #123
Updated documentation
```

You can manually edit these files with any text editor.

## Development

### Running Tests

Install bats-core:

```bash
# Using Homebrew
brew install bats-core

# Or using npm
npm install -g bats
```

Run the test suite:

```bash
# Run all tests
bats tests/

# Run specific test file
bats tests/test_utils.bats
bats tests/test_core.bats

# Run with verbose output
bats -t tests/
```

### Troubleshooting

**Invalid date format errors**

Dates must be in `YYYY-MM-DD` format (e.g., `2026-02-27`). Common issues:

- Wrong format: `02/27/2026` or `2026.02.27` ❌
- Correct format: `2026-02-27` ✅

**Tasks not appearing in weekly summary**

- Verify the week range: The tool uses Monday-Sunday weeks
- Check files exist: `ls ~/.aufgabe/`
- Ensure files aren't empty: `cat ~/.aufgabe/2026-02-27.txt`

**Permission denied**

Make sure the script is executable:

```bash
chmod +x bin/aufgabe
```

## Miscellaneous

### Donate

I am working hard on continuously developing and maintaining my projects. Please consider making a donation to keep the project going strong and me motivated.

- [Become a GitHub sponsor](https://github.com/sponsors/electerious)
- [Donate via PayPal](https://paypal.me/electerious)
- [Buy me a coffee](https://www.buymeacoffee.com/electerious)

### Links

- [Follow me on Bluesky](https://bsky.app/profile/electerious.bsky.social)
- [Follow me on Threads](https://www.threads.com/@electerious)
