#!/usr/bin/env bats

# Tests for core.sh

setup() {
  # Load core functions (which will also load utils)
  source "${BATS_TEST_DIRNAME}/../lib/core.sh"

  # Create temporary test directory
  export TEST_DATA_DIR="${BATS_TEST_TMPDIR}/aufgabe-test"
  export DATA_DIR="${TEST_DATA_DIR}"
  export AUFGABE_DIR="${TEST_DATA_DIR}"

  # Clean up any existing test data
  rm -rf "${TEST_DATA_DIR}"
  mkdir -p "${TEST_DATA_DIR}"
}

teardown() {
  # Clean up test directory
  rm -rf "${TEST_DATA_DIR}"
}

@test "add_task creates file and adds task" {
  run add_task "Test task" "2026-02-27"
  [ "$status" -eq 0 ]

  task_file="${TEST_DATA_DIR}/2026-02-27.txt"
  [ -f "$task_file" ]

  content=$(cat "$task_file")
  [ "$content" = "Test task" ]
}

@test "add_task appends to existing file" {
  task_file="${TEST_DATA_DIR}/2026-02-27.txt"
  echo "First task" > "$task_file"

  run add_task "Second task" "2026-02-27"
  [ "$status" -eq 0 ]

  line_count=$(wc -l < "$task_file" | tr -d ' ')
  [ "$line_count" -eq 2 ]

  last_line=$(tail -n 1 "$task_file")
  [ "$last_line" = "Second task" ]
}

@test "add_task rejects empty task text" {
  run add_task "" "2026-02-27"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Error: Task text cannot be empty" ]]
}

@test "add_task rejects empty date" {
  run add_task "Test task" ""
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Error: Date is required" ]]
}

@test "add_task rejects invalid date format" {
  run add_task "Test task" "2026/02/27"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Error: Invalid date format" ]]
}

@test "add_task with skip_duplicate skips existing task" {
  task_file="${TEST_DATA_DIR}/2026-02-27.txt"
  echo "Existing task" > "$task_file"

  run add_task "Existing task" "2026-02-27" true
  [ "$status" -eq 0 ]

  line_count=$(wc -l < "$task_file" | tr -d ' ')
  [ "$line_count" -eq 1 ]
}

@test "add_task with skip_duplicate adds task when no duplicate exists" {
  task_file="${TEST_DATA_DIR}/2026-02-27.txt"
  echo "First task" > "$task_file"

  run add_task "Second task" "2026-02-27" true
  [ "$status" -eq 0 ]

  line_count=$(wc -l < "$task_file" | tr -d ' ')
  [ "$line_count" -eq 2 ]
}

@test "add_task without skip_duplicate appends duplicate task" {
  task_file="${TEST_DATA_DIR}/2026-02-27.txt"
  echo "Same task" > "$task_file"

  run add_task "Same task" "2026-02-27"
  [ "$status" -eq 0 ]

  line_count=$(wc -l < "$task_file" | tr -d ' ')
  [ "$line_count" -eq 2 ]
}

@test "list_tasks displays tasks for existing file" {
  task_file="${TEST_DATA_DIR}/2026-02-27.txt"
  echo "Task 1" > "$task_file"
  echo "Task 2" >> "$task_file"

  run list_tasks "2026-02-27"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Task 1" ]]
  [[ "$output" =~ "Task 2" ]]
}

@test "list_tasks handles missing file gracefully" {
  run list_tasks "2026-02-27"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "No tasks logged for 2026-02-27" ]]
}

@test "list_tasks rejects invalid date" {
  run list_tasks "invalid-date"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Error: Invalid date format" ]]
}

@test "get_weekly_summary returns tasks in correct format" {
  # Get current week dates
  monday=$(get_week_start)
  if date --version &>/dev/null 2>&1; then
    tuesday=$(date -d "${monday} + 1 day" "+%Y-%m-%d")
  else
    tuesday=$(date -j -v+1d -f "%Y-%m-%d" "$monday" "+%Y-%m-%d")
  fi

  # Create test files
  echo "Task 1" > "${TEST_DATA_DIR}/${monday}.txt"
  echo "Task 2" >> "${TEST_DATA_DIR}/${monday}.txt"
  echo "Task 3" > "${TEST_DATA_DIR}/${tuesday}.txt"

  run get_weekly_summary
  [ "$status" -eq 0 ]

  # Should have two lines (one per day)
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 2 ]

  # First line should have comma-separated tasks from Monday
  first_line=$(echo "$output" | head -n 1)
  [[ "$first_line" =~ "Task 1, Task 2" ]]

  # Second line should have task from Tuesday
  second_line=$(echo "$output" | tail -n 1)
  [[ "$second_line" =~ "Task 3" ]]
}

@test "get_weekly_summary skips days without tasks" {
  # Only create file for Monday
  monday=$(get_week_start)
  echo "Only Monday task" > "${TEST_DATA_DIR}/${monday}.txt"

  run get_weekly_summary
  [ "$status" -eq 0 ]

  # Should only have one line
  line_count=$(echo "$output" | wc -l | tr -d ' ')
  [ "$line_count" -eq 1 ]

  [[ "$output" =~ "Only Monday task" ]]
}

@test "get_weekly_summary handles empty week" {
  run get_weekly_summary
  [ "$status" -eq 0 ]
  [[ "$output" =~ "No tasks logged this week" ]]
}

@test "get_weekly_summary handles single task correctly" {
  monday=$(get_week_start)
  echo "Single task" > "${TEST_DATA_DIR}/${monday}.txt"

  run get_weekly_summary
  [ "$status" -eq 0 ]
  [ "$output" = "Single task" ]
}
