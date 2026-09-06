#!/usr/bin/env bash

# Core functionality for aufgabe

# Source utils if not already loaded
if [[ -z "${DATA_DIR}" ]]; then
  SCRIPT_DIR_CORE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  source "${SCRIPT_DIR_CORE}/utils.sh"
fi

# Adds a task to a specific date
# Arguments:
#   $1 - Task text
#   $2 - Date in YYYY-MM-DD format
# Returns:
#   0 on success, 1 on error
add_task() {
  local task_text="${1:-}"
  local task_date="${2:-}"
  local skip_duplicate="${3:-false}"

  if [[ -z "${task_text}" ]]; then
    echo "Error: Task text cannot be empty" >&2
    return 1
  fi

  if [[ -z "${task_date}" ]]; then
    echo "Error: Date is required" >&2
    return 1
  fi

  if ! validate_date "${task_date}"; then
    echo "Error: Invalid date format. Expected YYYY-MM-DD" >&2
    return 1
  fi

  ensure_data_dir

  local task_file
  task_file="$(get_date_file "${task_date}")"

  if [[ "${skip_duplicate}" == true ]] && [[ -f "${task_file}" ]] && grep -qxF "${task_text}" "${task_file}"; then
    return 0
  fi

  echo "${task_text}" >> "${task_file}"
  return 0
}

# Lists tasks for a specific date
# Arguments:
#   $1 - Date in YYYY-MM-DD format
# Returns:
#   0 on success, 1 on error
list_tasks() {
  local task_date="${1:-}"

  if [[ -z "${task_date}" ]]; then
    echo "Error: Date is required" >&2
    return 1
  fi

  if ! validate_date "${task_date}"; then
    echo "Error: Invalid date format. Expected YYYY-MM-DD" >&2
    return 1
  fi

  local task_file
  task_file="$(get_date_file "${task_date}")"

  if [[ ! -f "${task_file}" ]]; then
    echo "No tasks logged for ${task_date}"
    return 0
  fi

  cat "${task_file}"
  return 0
}

# Generates weekly summary
# Format: Each day's tasks comma-separated, one line per day
# Days without tasks are skipped
# Arguments:
#   $1 - Optional signed number of weeks relative to the current week (default: 0)
# Returns:
#   Prints the formatted summary
get_weekly_summary() {
  local week_offset="${1:-0}"

  if [[ ! "${week_offset}" =~ ^[+-]?[0-9]+$ ]]; then
    echo "Error: Week offset must be an integer" >&2
    return 1
  fi

  local week_start
  local week_end

  week_start="$(get_week_start)"

  # Use a decimal base so offsets such as 08 do not get interpreted as octal.
  local offset_sign=1
  local offset_value="${week_offset}"
  case "${offset_value}" in
    -*)
      offset_sign=-1
      offset_value="${offset_value#-}"
      ;;
    +*)
      offset_value="${offset_value#+}"
      ;;
  esac

  local offset_days=$((offset_sign * 10#${offset_value} * 7))
  week_start="$(_date_add_days "${week_start}" "${offset_days}")"
  week_end="$(_date_add_days "${week_start}" 6)"

  ensure_data_dir

  local current_date="${week_start}"
  local output=""

  # Loop through each day of the week
  while [[ "${current_date}" != "$(_date_next_day "${week_end}")" ]]; do
    local task_file
    task_file="$(get_date_file "${current_date}")"

    if [[ -f "${task_file}" ]] && [[ -s "${task_file}" ]]; then
      # File exists and is not empty
      local tasks
      # Read all tasks and join with comma-space
      tasks=$(paste -sd ',' "${task_file}" | sed 's/,/, /g')

      if [[ -n "${output}" ]]; then
        output="${output}\n${tasks}"
      else
        output="${tasks}"
      fi
    fi

    # Move to next day
    current_date=$(_date_next_day "${current_date}")
  done

  if [[ -z "${output}" ]]; then
    echo "No tasks logged this week"
    return 0
  fi

  echo -e "${output}"
  return 0
}
