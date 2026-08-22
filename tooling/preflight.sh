#!/usr/bin/env bash

set -euo pipefail

readonly workspace_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly color_cyan='\033[0;36m'
readonly color_bold='\033[1m'
readonly color_reset='\033[0m'

run_command() {
  printf '%b›' "$color_cyan"
  printf ' %q' "$@"
  printf '%b\n' "$color_reset"
  "$@"
}

print_section() {
  printf '\n%b%s%b\n' "$color_bold" "$1" "$color_reset"
}

run_mobile() {
  print_section 'Mobile preflight'
  (
    run_command cd "$workspace_root/apps/mobile"
    run_command fvm flutter pub get
    run_command fvm dart run build_runner build --delete-conflicting-outputs
  )
  (
    run_command cd "$workspace_root"
    run_command pnpm format:check
    run_command pnpm lint:flutter
    run_command pnpm test:flutter
    run_command pnpm test:flutter:integration
  )
}

run_server() {
  print_section 'Server preflight'
  (
    run_command cd "$workspace_root"
    run_command pnpm generate:check
    run_command pnpm format:check:server
    run_command pnpm lint:server
    run_command pnpm typecheck
    run_command pnpm test:server
    run_command pnpm build:server
  )
}

case "${1:-all}" in
  mobile)
    run_mobile
    ;;
  server)
    run_server
    ;;
  all)
    run_server
    run_mobile
    ;;
  *)
    printf 'Usage: %s [server|mobile]\n' "$0" >&2
    exit 64
    ;;
esac
