#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
cd "$ROOT_DIR"

PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
RESULTS=""

record_pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  RESULTS="${RESULTS}
PASS  $1"
}

record_fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  RESULTS="${RESULTS}
FAIL  $1"
}

record_skip() {
  SKIP_COUNT=$((SKIP_COUNT + 1))
  RESULTS="${RESULTS}
SKIP  $1"
}

run_test() {
  name=$1
  shift

  printf '\n==> %s\n' "$name"
  if "$@"; then
    record_pass "$name"
  else
    record_fail "$name"
  fi
}

run_optional() {
  tool=$1
  name=$2
  shift 2

  if command -v "$tool" >/dev/null 2>&1; then
    run_test "$name" "$@"
  else
    printf '\n==> %s\n' "$name"
    printf 'Skipping: %s not found on PATH\n' "$tool"
    record_skip "$name"
  fi
}

printf 'Running data_starship test suite\n'

run_test "Erlang EUnit" rebar3 eunit
run_test "Erlang compile" rebar3 compile

run_optional "elixir" \
  "Elixir smoke example" \
  elixir -pa _build/default/lib/data_starship/ebin examples/elixir_smoke.exs

run_optional "elixir" \
  "Elixir usage golden/property example" \
  elixir -pa _build/default/lib/data_starship/ebin examples/elixir_usage.exs

if command -v gleam >/dev/null 2>&1; then
  printf '\n==> Gleam smoke example\n'
  if (
    cd examples/gleam_smoke
    ERL_FLAGS='-pa ../../_build/default/lib/data_starship/ebin' gleam run
  ); then
    record_pass "Gleam smoke example"
  else
    record_fail "Gleam smoke example"
  fi

  printf '\n==> Gleam usage golden/property example\n'
  if (
    cd examples/gleam_smoke
    ERL_FLAGS='-pa ../../_build/default/lib/data_starship/ebin' gleam run -m data_starship_usage
  ); then
    record_pass "Gleam usage golden/property example"
  else
    record_fail "Gleam usage golden/property example"
  fi
else
  printf '\n==> Gleam examples\n'
  printf 'Skipping: gleam not found on PATH\n'
  record_skip "Gleam smoke example"
  record_skip "Gleam usage golden/property example"
fi

printf '\n%s\n' "========================================"
printf 'data_starship test summary\n'
printf '%s\n' "----------------------------------------"
printf '%s\n' "$RESULTS"
printf '%s\n' "----------------------------------------"
printf 'Passed:  %s\n' "$PASS_COUNT"
printf 'Failed:  %s\n' "$FAIL_COUNT"
printf 'Skipped: %s\n' "$SKIP_COUNT"
printf '%s\n' "========================================"

if [ "$FAIL_COUNT" -ne 0 ]; then
  exit 1
fi