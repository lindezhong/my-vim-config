#!/usr/bin/env bash
# tmux.sh - Execute shell commands asynchronously using tmux sessions

set -euo pipefail

if [[ "${ASYNC_CMD_TEST_MODE:-}" != "1" ]]; then
  readonly BASE_DIR="${BASE_DIR:-${HOME}/.tmux-sh}"
  readonly SESSIONS_DIR="${SESSIONS_DIR:-${BASE_DIR}/sessions}"
  readonly LOGS_DIR="${LOGS_DIR:-${BASE_DIR}/logs}"
  readonly TMUX_SESSION_PREFIX="${TMUX_SESSION_PREFIX:-tmux-sh-}"
else
  # In test mode, provide defaults but allow override from environment
  : "${BASE_DIR:=/tmp/.tmux-sh-test}"
  : "${SESSIONS_DIR:=${BASE_DIR}/sessions}"
  : "${LOGS_DIR:=${BASE_DIR}/logs}"
  : "${TMUX_SESSION_PREFIX:=tmux-sh-}"
fi

# -----------------------------------------------------------------------------
# Utility functions
# -----------------------------------------------------------------------------

init_dirs() {
  if [[ ! -d "${SESSIONS_DIR}" ]]; then
    mkdir -p "${SESSIONS_DIR}"
  fi

  if [[ ! -d "${LOGS_DIR}" ]]; then
    mkdir -p "${LOGS_DIR}"
  fi
}

validate_name() {
  local name=$1
  [[ "${name}" =~ ^[a-zA-Z0-9_-]+$ ]]
}

generate_session_id() {
  local base_name=$1
  local timestamp
  timestamp=$(date +%Y-%m-%d-%H-%M-%S)

  echo "${base_name}-${timestamp}"
}

configure_tmux_style() {
  local tmux_session=$1

  # Set status bar to transparent (default terminal background)
  tmux set-option -t "${tmux_session}" status-style "bg=default fg=white"
  tmux set-option -t "${tmux_session}" status-left-length 100
  tmux set-option -t "${tmux_session}" status-right-length 100
  tmux set-option -t "${tmux_session}" status-left "[#{session_name}] "
  tmux set-option -t "${tmux_session}" status-right "Detach: Ctrl+b d | #{?pane_synchronized,SYNC,}"
}

# -----------------------------------------------------------------------------
# State file functions
# -----------------------------------------------------------------------------

save_session_state() {
  local session_id=$1
  local original_name=$2
  local command=$3
  local pid=$4
  local log_file=$5
  local state_file="${SESSIONS_DIR}/${session_id}.state"
  local created_at
  created_at=$(date +%Y-%m-%dT%H:%M:%S)

  cat > "${state_file}" <<EOF
ID=${session_id}
ORIGINAL_NAME=${original_name}
COMMAND=${command}
TMUX_SESSION=${TMUX_SESSION_PREFIX}${session_id}
PID=${pid}
STATUS=running
EXIT_CODE=
CREATED_AT=${created_at}
LOG_FILE=${log_file}
EOF
}

get_session_field() {
  local session_id=$1
  local field=$2
  local state_file="${SESSIONS_DIR}/${session_id}.state"

  if [[ ! -f "${state_file}" ]]; then
    return 1
  fi

  grep "^${field}=" "${state_file}" | cut -d'=' -f2-
}

update_session_status() {
  local session_id=$1
  local new_status=$2
  local exit_code=${3:-}
  local state_file="${SESSIONS_DIR}/${session_id}.state"

  if [[ ! -f "${state_file}" ]]; then
    return 1
  fi

  awk -F= -v status="${new_status}" -v code="${exit_code}" '
    /^STATUS=/ { $0 = "STATUS=" status }
    /^EXIT_CODE=/ { $0 = "EXIT_CODE=" code }
    { print }
  ' "${state_file}" > "${state_file}.tmp" && mv "${state_file}.tmp" "${state_file}"
}

refresh_running_sessions() {
  local state_file
  local status
  local session_id
  local tmux_session
  local exit_code

  for state_file in "${SESSIONS_DIR}"/*.state; do
    [[ -f "${state_file}" ]] || continue

    status=$(grep "^STATUS=" "${state_file}" | cut -d'=' -f2)

    if [[ "${status}" == "running" ]]; then
      session_id=$(grep "^ID=" "${state_file}" | cut -d'=' -f2)
      tmux_session=$(grep "^TMUX_SESSION=" "${state_file}" | cut -d'=' -f2)

      if ! tmux has-session -t "${tmux_session}" 2>/dev/null; then
        exit_code=$(tmux display-message -t "${tmux_session}" -p "#{pane_exit_status}" 2>/dev/null || echo "unknown")

        # Use awk for safer file editing (learned from Task 3 security fix)
        awk -F= -v new_status="completed" -v new_code="${exit_code}" '
          /^STATUS=/ { $0 = "STATUS=" new_status }
          /^EXIT_CODE=/ { $0 = "EXIT_CODE=" new_code }
          { print }
        ' "${state_file}" > "${state_file}.tmp" && mv "${state_file}.tmp" "${state_file}"
      fi
    fi
  done
}

# -----------------------------------------------------------------------------
# Session lookup functions
# -----------------------------------------------------------------------------

find_by_name() {
  local name=$1
  local state_file
  local session_name
  local session_id

  for state_file in "${SESSIONS_DIR}"/*.state; do
    [[ -f "${state_file}" ]] || continue

    session_name=$(grep "^ORIGINAL_NAME=" "${state_file}" | cut -d'=' -f2)
    if [[ "${session_name}" == "${name}" ]]; then
      session_id=$(grep "^ID=" "${state_file}" | cut -d'=' -f2)
      echo "${session_id}"
    fi
  done
}

find_running_by_name() {
  local name=$1
  local state_file
  local original_name
  local status
  local id

  for state_file in "${SESSIONS_DIR}"/*.state; do
    [[ -f "${state_file}" ]] || continue

    # Parse state file safely
    original_name=$(grep "^ORIGINAL_NAME=" "${state_file}" | cut -d'=' -f2-)
    status=$(grep "^STATUS=" "${state_file}" | cut -d'=' -f2)
    id=$(grep "^ID=" "${state_file}" | cut -d'=' -f2)

    if [[ "${original_name}" == "${name}" ]] && [[ "${status}" == "running" ]]; then
      echo "${id}"
    fi
  done
}

# -----------------------------------------------------------------------------
# Command implementations
# -----------------------------------------------------------------------------

cmd_start() {
  local name=$1
  shift
  local command="$*"
  local session_id
  local tmux_session
  local log_file
  local pid

  if ! validate_name "${name}"; then
    echo "Error: Invalid name '${name}'. Use only letters, numbers, underscore, hyphen."
    return 1
  fi

  init_dirs
  session_id=$(generate_session_id "${name}")
  tmux_session="${TMUX_SESSION_PREFIX}${session_id}"

  # If no command provided, start a plain tmux session
  if [[ -z "${command}" ]]; then
    # Create a plain tmux session without logging
    tmux new-session -d -s "${tmux_session}"
    log_file=""  # No log file for plain sessions
  else
    # Create tmux session with the command (preserves TTY for interactive commands)
    # Use script to capture TTY input/output while preserving interactivity
    log_file="${LOGS_DIR}/${session_id}.log"

    # Create wrapper using envsubst for variable expansion
    local wrapper="${LOGS_DIR}/${session_id}.wrapper"
    cat > "${wrapper}" <<'EOF'
#!/bin/bash
exec script -q "${LOGFILE}" -c "${COMMAND}"
EOF
    LOGFILE="${log_file}" COMMAND="${command}" envsubst < "${wrapper}" > "${wrapper}.tmp"
    # Export variables for envsubst
    export LOGFILE="${log_file}"
    export COMMAND="${command}"
    mv "${wrapper}.tmp" "${wrapper}"
    unset LOGFILE COMMAND
    chmod +x "${wrapper}"

    tmux new-session -d -s "${tmux_session}" "${wrapper}"
  fi

  # Configure tmux session appearance
  configure_tmux_style "${tmux_session}"

  # Give session a moment to initialize
  sleep 0.1

  pid=$(tmux list-panes -t "${tmux_session}" -F "#{pane_pid}")

  save_session_state "${session_id}" "${name}" "${command}" "${pid}" "${log_file}"

  echo "Session created: ${session_id}"

  # Auto-attach to the new session
  do_attach "${session_id}"
}

cmd_list() {
  local show_all=false
  if [[ "${1:-}" == "--all" ]]; then
    show_all=true
  fi

  refresh_running_sessions

  printf "%-15s %-30s %-10s %-20s %-8s\n" \
    "NAME" "SESSION_ID" "STATUS" "START_TIME" "PID"
  printf "%s\n" "----------------------------------------------------------------------------------------"

  local state_file
  local original_name
  local id
  local status
  local created_at
  local pid

  for state_file in "${SESSIONS_DIR}"/*.state; do
    [[ -f "${state_file}" ]] || continue

    # Parse state file safely without sourcing
    original_name=$(grep "^ORIGINAL_NAME=" "${state_file}" | cut -d'=' -f2-)
    id=$(grep "^ID=" "${state_file}" | cut -d'=' -f2)
    status=$(grep "^STATUS=" "${state_file}" | cut -d'=' -f2)
    created_at=$(grep "^CREATED_AT=" "${state_file}" | cut -d'=' -f2)
    pid=$(grep "^PID=" "${state_file}" | cut -d'=' -f2)

    if [[ "${status}" == "running" ]] || [[ "${show_all}" == "true" ]]; then
      printf "%-15s %-30s %-10s %-20s %-8s\n" \
        "${original_name}" "${id}" "${status}" "${created_at}" "${pid}"
    fi
  done
}

do_attach() {
  local session_id=$1
  local tmux_session
  local log_file

  tmux_session="${TMUX_SESSION_PREFIX}${session_id}"
  log_file="${LOGS_DIR}/${session_id}.log"

  if ! tmux has-session -t "${tmux_session}" 2>/dev/null; then
    echo "Error: Session '${session_id}' is not running."
    echo ""
    echo "Last 10 lines of log:"
    if [[ -f "${log_file}" ]]; then
      tail -n 10 "${log_file}"
    else
      echo "No log available."
    fi
    return 1
  fi

  tmux attach-session -t "${tmux_session}"
}

cmd_attach() {
  local identifier=$1
  local sessions
  local count
  local choice

  refresh_running_sessions

  # Try as session ID first
  if [[ -f "${SESSIONS_DIR}/${identifier}.state" ]]; then
    do_attach "${identifier}"
    return $?
  fi

  # Find running sessions by name
  mapfile -t sessions < <(find_running_by_name "${identifier}")
  count=${#sessions[@]}

  if [[ ${count} -eq 0 ]]; then
    echo "Error: No running session found with name or ID: ${identifier}"
    echo ""
    echo "Tip: Use 'tmux.sh list --all' to see all sessions including stopped ones."
    return 1
  fi

  if [[ ${count} -eq 1 ]]; then
    echo "Attaching to session: ${sessions[0]}"
    do_attach "${sessions[0]}"
    return $?
  fi

  # Multiple sessions - show selection menu
  echo "Multiple running sessions found with name '${identifier}':"
  echo ""
  local i=1
  local session
  local created
  local pid

  for session in "${sessions[@]}"; do
    created=$(get_session_field "${session}" "CREATED_AT")
    pid=$(get_session_field "${session}" "PID")
    printf "  [%d] %s  started: %s  pid: %s\n" "${i}" "${session}" "${created}" "${pid}"
    ((i++))
  done
  echo ""

  read -p "Select session (1-${count}): " choice

  if [[ "${choice}" =~ ^[0-9]+$ ]] && [[ "${choice}" -ge 1 ]] && [[ "${choice}" -le "${count}" ]]; then
    local selected="${sessions[$((choice-1))]}"
    do_attach "${selected}"
  else
    echo "Error: Invalid selection."
    return 1
  fi
}

cmd_logs() {
  local session_id=$1
  local option=${2:-}
  local state_file
  local log_file

  state_file="${SESSIONS_DIR}/${session_id}.state"

  if [[ ! -f "${state_file}" ]]; then
    echo "Error: Session not found: ${session_id}"
    return 1
  fi

  log_file=$(grep "^LOG_FILE=" "${state_file}" | cut -d'=' -f2-)

  if [[ ! -f "${log_file}" ]]; then
    echo "Error: Log file not found"
    return 1
  fi

  case "${option}" in
    --follow|-f)
      echo "Following logs for session: ${session_id} (Ctrl+C to exit)"
      echo ""
      tail -f "${log_file}"
      ;;
    --tail|-t)
      tail -n 50 "${log_file}"
      ;;
    "")
      cat "${log_file}"
      ;;
    *)
      echo "Error: Usage: tmux.sh logs <session-id> [--tail|--follow]"
      return 1
      ;;
  esac
}

cmd_stop() {
  local identifier=$1
  local force=${2:-}
  local sessions

  refresh_running_sessions

  mapfile -t sessions < <(find_running_by_name "${identifier}")

  if [[ ${#sessions[@]} -eq 0 ]]; then
    # Try as session ID
    if [[ -f "${SESSIONS_DIR}/${identifier}.state" ]]; then
      sessions=("${identifier}")
    else
      echo "Error: No running session found: ${identifier}"
      return 1
    fi
  fi

  local session
  local tmux_session
  local pid
  local status

  for session in "${sessions[@]}"; do
    status=$(grep "^STATUS=" "${SESSIONS_DIR}/${session}.state" | cut -d'=' -f2)

    if [[ "${status}" != "running" ]]; then
      echo "Session '${session}' is not running (status: ${status})"
      continue
    fi

    tmux_session=$(grep "^TMUX_SESSION=" "${SESSIONS_DIR}/${session}.state" | cut -d'=' -f2)
    pid=$(grep "^PID=" "${SESSIONS_DIR}/${session}.state" | cut -d'=' -f2)

    if [[ "${force}" == "--force" ]] || [[ "${force}" == "-f" ]]; then
      echo "Stopping session: ${session} (forced)"
      tmux kill-session -t "${tmux_session}"
      kill -9 "${pid}" 2>/dev/null || true
    else
      echo "Stopping session: ${session} (PID: ${pid})"
      tmux send-keys -t "${tmux_session}" C-c
      sleep 1

      if tmux has-session -t "${tmux_session}" 2>/dev/null; then
        echo "Session still running, use --force to kill"
        continue
      fi
    fi

    update_session_status "${session}" "stopped"
  done
}

cmd_clean() {
  local days=${1:-7}
  local dry_run=${2:-}
  local now
  local count=0

  now=$(date +%s)

  echo "Cleaning sessions older than ${days} days..."

  local state_file
  local session_time
  local age_days
  local status
  local id
  local created_at
  local log_file

  for state_file in "${SESSIONS_DIR}"/*.state; do
    [[ -f "${state_file}" ]] || continue

    # Parse state file safely (use || true to prevent exit on missing fields)
    status=$(grep "^STATUS=" "${state_file}" | cut -d'=' -f2) || status=""
    id=$(grep "^ID=" "${state_file}" | cut -d'=' -f2) || id=""
    created_at=$(grep "^CREATED_AT=" "${state_file}" | cut -d'=' -f2) || created_at=""
    log_file=$(grep "^LOG_FILE=" "${state_file}" | cut -d'=' -f2-) || log_file=""

    # Skip if essential fields are missing
    if [[ -z "${id}" ]] || [[ -z "${created_at}" ]]; then
      continue
    fi

    # Skip running sessions
    if [[ "${status}" == "running" ]]; then
      continue
    fi

    # Calculate session age
    session_time=$(date -d "${created_at}" +%s 2>/dev/null || echo 0)
    age_days=$(( (now - session_time) / 86400 ))

    if [[ ${age_days} -ge ${days} ]]; then
      if [[ "${dry_run}" == "--dry-run" ]]; then
        echo "Would remove: ${id} (age: ${age_days}d)"
      else
        echo "Removing: ${id} (age: ${age_days}d)"
        rm -f "${state_file}"
        rm -f "${log_file}"
      fi
      count=$((count + 1))
    fi
  done

  if [[ "${dry_run}" == "--dry-run" ]]; then
    echo "Dry run complete. Would remove ${count} session(s)."
    echo "Run without --dry-run to actually clean."
  else
    echo "Clean complete. Removed ${count} session(s)."
  fi
}

show_usage() {
  cat <<EOF
tmux.sh - Asynchronous command execution tool

Usage:
  tmux.sh start <name> <command> [args...]   Start an async command
  tmux.sh attach <name-or-id>               Attach to a session
  tmux.sh list [--all]                      List sessions
  tmux.sh logs <session-id> [--tail|--follow] View logs
  tmux.sh stop <name-or-id> [--force]       Stop a session
  tmux.sh clean [days] [--dry-run]          Clean old sessions

Options:
  --all       Show all sessions (including stopped ones)
  --tail      Show last 50 lines of log
  --follow    Follow log in real-time
  --force     Force stop session
  --dry-run   Simulate run without actual deletion

Examples:
  tmux.sh start build make release
  tmux.sh start dev npm run dev
  tmux.sh attach dev

EOF
}

main() {
  if [[ "${ASYNC_CMD_TEST_MODE:-}" != "1" ]]; then
    init_dirs
  fi

  if [[ $# -eq 0 ]]; then
    show_usage
    exit 0
  fi

  local command=$1
  shift

  case "${command}" in
    start)
      if [[ $# -lt 1 ]]; then
        echo "Error: start requires <name> [command]"
        exit 1
      fi
      cmd_start "$@"
      ;;
    attach)
      if [[ $# -lt 1 ]]; then
        echo "Error: attach requires <name-or-id>"
        exit 1
      fi
      cmd_attach "$@"
      ;;
    list)
      cmd_list "$@"
      ;;
    logs)
      if [[ $# -lt 1 ]]; then
        echo "Error: logs requires <session-id>"
        exit 1
      fi
      cmd_logs "$@"
      ;;
    stop)
      if [[ $# -lt 1 ]]; then
        echo "Error: stop requires <name-or-id>"
        exit 1
      fi
      cmd_stop "$@"
      ;;
    clean)
      cmd_clean "$@"
      ;;
    help|--help|-h)
      show_usage
      ;;
    *)
      echo "Error: Unknown command: ${command}"
      echo ""
      show_usage
      exit 1
      ;;
  esac
}

if [[ "${ASYNC_CMD_TEST_MODE:-}" != "1" ]]; then
  main "$@"
fi
