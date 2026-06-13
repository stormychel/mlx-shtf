#!/usr/bin/env bats
#
# Platform-agnostic smoke tests — only exercise paths that run before the
# Apple-Silicon / MLX preflight, so they pass on Linux CI runners too.

BIN="${BATS_TEST_DIRNAME}/../bin/shtf"

@test "--version prints the version" {
  run "$BIN" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"mlx-shtf 0.1.1"* ]]
}

@test "--help shows usage and the commands" {
  run "$BIN" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"shtf chat"* ]]
  [[ "$output" == *"shtf ask"* ]]
}

@test "no args shows usage" {
  run "$BIN"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}
