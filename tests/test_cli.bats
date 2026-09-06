#!/usr/bin/env bats

# Tests for the aufgabe CLI

setup() {
  export TEST_DATA_DIR="${BATS_TEST_TMPDIR}/aufgabe-cli-test"
  export AUFGABE_DIR="${TEST_DATA_DIR}"

  rm -rf "${TEST_DATA_DIR}"
  mkdir -p "${TEST_DATA_DIR}"

  # Load date helpers to calculate files for the selected weeks.
  source "${BATS_TEST_DIRNAME}/../lib/utils.sh"
}

teardown() {
  rm -rf "${TEST_DATA_DIR}"
}

@test "weekly shows the current week by default" {
  monday=$(get_week_start)
  echo "Current week task" > "${TEST_DATA_DIR}/${monday}.txt"

  run "${BATS_TEST_DIRNAME}/../bin/aufgabe" weekly
  [ "$status" -eq 0 ]
  [ "$output" = "Current week task" ]
}

@test "weekly --offset selects the previous week" {
  monday=$(get_week_start)
  previous_monday=$(_date_add_days "${monday}" -7)
  echo "Previous week task" > "${TEST_DATA_DIR}/${previous_monday}.txt"
  echo "Current week task" > "${TEST_DATA_DIR}/${monday}.txt"

  run "${BATS_TEST_DIRNAME}/../bin/aufgabe" weekly --offset -1
  [ "$status" -eq 0 ]
  [ "$output" = "Previous week task" ]
}

@test "weekly --offset selects a future week" {
  monday=$(get_week_start)
  next_monday=$(_date_add_days "${monday}" 7)
  echo "Next week task" > "${TEST_DATA_DIR}/${next_monday}.txt"

  run "${BATS_TEST_DIRNAME}/../bin/aufgabe" weekly --offset 1
  [ "$status" -eq 0 ]
  [ "$output" = "Next week task" ]
}

@test "weekly --offset requires a value" {
  run "${BATS_TEST_DIRNAME}/../bin/aufgabe" weekly --offset
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Error: --offset requires a value" ]]
}

@test "weekly --offset rejects a non-integer value" {
  run "${BATS_TEST_DIRNAME}/../bin/aufgabe" weekly --offset last
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Error: Week offset must be an integer" ]]
}
