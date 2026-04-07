#!/usr/bin/env bats

# Tests for utils.sh

setup() {
  # Load utils functions
  source "${BATS_TEST_DIRNAME}/../lib/utils.sh"

  # Create temporary test directory
  export TEST_DATA_DIR="${BATS_TEST_TMPDIR}/aufgabe-test"
  export DATA_DIR="${TEST_DATA_DIR}"
  export AUFGABE_DIR="${TEST_DATA_DIR}"

  # Clean up any existing test data
  rm -rf "${TEST_DATA_DIR}"
}

teardown() {
  # Clean up test directory
  rm -rf "${TEST_DATA_DIR}"
}

@test "ensure_data_dir creates directory if it doesn't exist" {
  run ensure_data_dir
  [ "$status" -eq 0 ]
  [ -d "${TEST_DATA_DIR}" ]
}

@test "ensure_data_dir succeeds if directory already exists" {
  mkdir -p "${TEST_DATA_DIR}"
  run ensure_data_dir
  [ "$status" -eq 0 ]
  [ -d "${TEST_DATA_DIR}" ]
}

@test "validate_date accepts valid date format" {
  run validate_date "2026-02-27"
  [ "$status" -eq 0 ]
}

@test "validate_date accepts valid date with different month" {
  run validate_date "2026-12-31"
  [ "$status" -eq 0 ]
}

@test "validate_date rejects empty string" {
  run validate_date ""
  [ "$status" -eq 1 ]
}

@test "validate_date rejects invalid format" {
  run validate_date "2026/02/27"
  [ "$status" -eq 1 ]
}

@test "validate_date rejects invalid format with wrong separators" {
  run validate_date "2026.02.27"
  [ "$status" -eq 1 ]
}

@test "validate_date rejects incomplete date" {
  run validate_date "2026-02"
  [ "$status" -eq 1 ]
}

@test "validate_date rejects invalid date values" {
  run validate_date "2026-13-01"
  [ "$status" -eq 1 ]
}

@test "get_date_file returns correct path" {
  result=$(get_date_file "2026-02-27")
  [ "$result" = "${TEST_DATA_DIR}/2026-02-27.txt" ]
}

@test "get_today returns date in correct format" {
  result=$(get_today)
  run validate_date "$result"
  [ "$status" -eq 0 ]
}

@test "get_yesterday returns date in correct format" {
  result=$(get_yesterday)
  run validate_date "$result"
  [ "$status" -eq 0 ]
}

@test "get_week_start returns Monday date" {
  result=$(get_week_start)
  run validate_date "$result"
  [ "$status" -eq 0 ]

  # Verify it's a Monday (day of week = 1)
  if [[ "${_GNU_DATE}" == true ]]; then
    day_of_week=$(date -d "$result" "+%u")
  else
    day_of_week=$(date -j -f "%Y-%m-%d" "$result" "+%u")
  fi
  [ "$day_of_week" -eq 1 ]
}

@test "get_week_end returns Sunday date" {
  result=$(get_week_end)
  run validate_date "$result"
  [ "$status" -eq 0 ]

  # Verify it's a Sunday (day of week = 7)
  if [[ "${_GNU_DATE}" == true ]]; then
    day_of_week=$(date -d "$result" "+%u")
  else
    day_of_week=$(date -j -f "%Y-%m-%d" "$result" "+%u")
  fi
  [ "$day_of_week" -eq 7 ]
}
