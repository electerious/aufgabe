#!/usr/bin/env bash

# Utility functions for aufgabe

# Default data directory
DATA_DIR="${AUFGABE_DIR:-${HOME}/.aufgabe}"

# Ensures the data directory exists
# Returns:
#   0 on success
ensure_data_dir() {
  if [[ ! -d "${DATA_DIR}" ]]; then
    mkdir -p "${DATA_DIR}"
  fi
  return 0
}

# Validates a date string in YYYY-MM-DD format
# Arguments:
#   $1 - Date string to validate
# Returns:
#   0 if valid, 1 if invalid
validate_date() {
  local date_str="${1:-}"

  if [[ -z "${date_str}" ]]; then
    return 1
  fi

  # Check format matches YYYY-MM-DD
  if [[ ! "${date_str}" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    return 1
  fi

  # Verify it's a valid date by trying to parse it
  if ! date -j -f "%Y-%m-%d" "${date_str}" "+%Y-%m-%d" &>/dev/null; then
    return 1
  fi

  return 0
}

# Returns the file path for a given date
# Arguments:
#   $1 - Date string in YYYY-MM-DD format
# Returns:
#   Prints the file path
get_date_file() {
  local date_str="${1:-}"
  echo "${DATA_DIR}/${date_str}.txt"
}

# Returns today's date in YYYY-MM-DD format
# Returns:
#   Prints today's date
get_today() {
  date +%Y-%m-%d
}

# Returns yesterday's date in YYYY-MM-DD format
# Returns:
#   Prints yesterday's date
get_yesterday() {
  date -v-1d +%Y-%m-%d
}

# Returns Monday of the current week in YYYY-MM-DD format
# Returns:
#   Prints the Monday date
get_week_start() {
  date -v-Mon +%Y-%m-%d
}

# Returns Sunday of the current week in YYYY-MM-DD format
# Returns:
#   Prints the Sunday date
get_week_end() {
  date -v+Sun +%Y-%m-%d
}
