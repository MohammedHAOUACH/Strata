#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
mapfile -t pids < <(pgrep -f -- "$root/serve/server[.]py" || true)

if ((${#pids[@]} == 0)); then
  printf 'Strata is not running from %s\n' "$root"
  exit 0
fi

wait_for_exit() {
  local seconds=$1
  local remaining=()

  for ((second = 0; second < seconds; second++)); do
    remaining=()
    for pid in "${pids[@]}"; do
      if kill -0 "$pid" 2>/dev/null; then
        remaining+=("$pid")
      fi
    done
    ((${#remaining[@]} == 0)) && return 0
    sleep 1
  done

  return 1
}

kill -TERM "${pids[@]}" 2>/dev/null || true
if wait_for_exit 5; then
  printf 'Strata stopped gracefully.\n'
  exit 0
fi

printf 'Graceful stop is waiting on active work; interrupting it now.\n'
kill -INT "${pids[@]}" 2>/dev/null || true
if wait_for_exit 5; then
  printf 'Strata stopped.\n'
  exit 0
fi

printf 'Forcing the remaining Strata process(es) to stop.\n' >&2
for pid in "${pids[@]}"; do
  mapfile -t engines < <(pgrep -P "$pid" -f -- "$root/engine/strata" || true)
  if ((${#engines[@]} > 0)); then
    kill -KILL "${engines[@]}" 2>/dev/null || true
  fi
  kill -KILL "$pid" 2>/dev/null || true
done
