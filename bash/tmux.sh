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

  # Create session-specific log directory if SESSION_LOGS_DIR is set
  if [[ -n "${SESSION_LOGS_DIR:-}" ]] && [[ ! -d "${SESSION_LOGS_DIR}" ]]; then
    mkdir -p "${SESSION_LOGS_DIR}"
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
  local part_log_file=${6:-}  # New parameter, defaults to empty
  local state_file="${SESSIONS_DIR}/${session_id}.state"
  local created_at
  created_at=$(date +%Y-%m-%dT%H:%M:%S)
  local tmux_session_name="${TMUX_SESSION_PREFIX}${session_id}"

  cat > "${state_file}" <<EOF
TMUX_ID=${session_id}
TMUX_NAME=${original_name}
TMUX_COMMAND=${command}
TMUX_SESSION=${tmux_session_name}
TMUX_PID=${pid}
TMUX_STATUS=running
TMUX_EXIT_CODE=
TMUX_CREATED_AT=${created_at}
TMUX_LOG_FILE=${log_file}
TMUX_PART_LOG=${part_log_file}
EOF
}

get_session_field() {
  local session_id=$1
  local field=$2
  local state_file="${SESSIONS_DIR}/${session_id}.state"

  if [[ ! -f "${state_file}" ]]; then
    return 1
  fi

  # Map old field names to new TMUX_ prefixed field names
  case "${field}" in
    ID) field="TMUX_ID" ;;
    ORIGINAL_NAME) field="TMUX_NAME" ;;
    NAME) field="TMUX_NAME" ;;
    COMMAND) field="TMUX_COMMAND" ;;
    PID) field="TMUX_PID" ;;
    STATUS) field="TMUX_STATUS" ;;
    EXIT_CODE) field="TMUX_EXIT_CODE" ;;
    CREATED_AT) field="TMUX_CREATED_AT" ;;
    LOG_FILE) field="TMUX_LOG_FILE" ;;
    PART_LOG) field="TMUX_PART_LOG" ;;
    TMUX_SESSION) field="TMUX_SESSION" ;;
    *)
      # Add TMUX_ prefix if not already present
      if [[ "${field}" != TMUX_* ]]; then
        field="TMUX_${field}"
      fi
      ;;
  esac

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
    /^TMUX_STATUS=/ { $0 = "TMUX_STATUS=" status }
    /^TMUX_EXIT_CODE=/ { $0 = "TMUX_EXIT_CODE=" code }
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

    status=$(grep "^TMUX_STATUS=" "${state_file}" | cut -d'=' -f2)

    if [[ "${status}" == "running" ]]; then
      session_id=$(grep "^TMUX_ID=" "${state_file}" | cut -d'=' -f2)
      tmux_session=$(grep "^TMUX_SESSION=" "${state_file}" | cut -d'=' -f2)

      if ! tmux has-session -t "${tmux_session}" 2>/dev/null; then
        exit_code=$(tmux display-message -t "${tmux_session}" -p "#{pane_exit_status}" 2>/dev/null || echo "unknown")

        # Use awk for safer file editing (learned from Task 3 security fix)
        awk -F= -v new_status="completed" -v new_code="${exit_code}" '
          /^TMUX_STATUS=/ { $0 = "TMUX_STATUS=" new_status }
          /^TMUX_EXIT_CODE=/ { $0 = "TMUX_EXIT_CODE=" new_code }
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

    session_name=$(grep "^TMUX_NAME=" "${state_file}" | cut -d'=' -f2)
    if [[ "${session_name}" == "${name}" ]]; then
      session_id=$(grep "^TMUX_ID=" "${state_file}" | cut -d'=' -f2)
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
    original_name=$(grep "^TMUX_NAME=" "${state_file}" | cut -d'=' -f2-)
    status=$(grep "^TMUX_STATUS=" "${state_file}" | cut -d'=' -f2)
    id=$(grep "^TMUX_ID=" "${state_file}" | cut -d'=' -f2)

    if [[ "${original_name}" == "${name}" ]] && [[ "${status}" == "running" ]]; then
      echo "${id}"
    fi
  done
}

init_session_context() {
  local identifier=$1

  # Initialize base directories first (SESSIONS_DIR and LOGS_DIR)
  init_dirs

  # Try as session ID first
  if [[ -f "${SESSIONS_DIR}/${identifier}.state" ]]; then
    SESSION_ID="${identifier}"
    _load_session_vars "${SESSION_ID}"
    # Initialize session-specific log directory now that SESSION_LOGS_DIR is set
    init_dirs
    return 0
  fi

  # Try as name
  local sessions
  mapfile -t sessions < <(find_running_by_name "${identifier}")
  local count=${#sessions[@]}

  if [[ ${count} -eq 0 ]]; then
    echo "Error: No session found with name or ID: ${identifier}" >&2
    return 1
  fi

  if [[ ${count} -eq 1 ]]; then
    SESSION_ID="${sessions[0]}"
    _load_session_vars "${SESSION_ID}"
    # Initialize session-specific log directory now that SESSION_LOGS_DIR is set
    init_dirs
    return 0
  fi

  # Multiple sessions - show selection menu
  echo "Multiple running sessions found with name '${identifier}':"
  echo ""
  local i=1
  local session
  local created
  local pid

  for session in "${sessions[@]}"; do
    created=$(grep "^TMUX_CREATED_AT=" "${SESSIONS_DIR}/${session}.state" | cut -d'=' -f2)
    pid=$(grep "^TMUX_PID=" "${SESSIONS_DIR}/${session}.state" | cut -d'=' -f2)
    printf "  [%d] %s  started: %s  pid: %s\n" "${i}" "${session}" "${created}" "${pid}"
    ((i++))
  done
  echo ""

  local choice
  read -p "Select session (1-${count}): " choice

  if [[ "${choice}" =~ ^[0-9]+$ ]] && [[ "${choice}" -ge 1 ]] && [[ "${choice}" -le "${count}" ]]; then
    SESSION_ID="${sessions[$((choice-1))]}"
    _load_session_vars "${SESSION_ID}"
    # Initialize session-specific log directory now that SESSION_LOGS_DIR is set
    init_dirs
    return 0
  else
    echo "Error: Invalid selection." >&2
    return 1
  fi
}

_load_session_vars() {
  local session_id=$1

  SESSION_ID="${session_id}"
  SESSION_NAME=$(get_session_field "${session_id}" "NAME")
  TMUX_SESSION=$(get_session_field "${session_id}" "SESSION")
  STATE_FILE="${SESSIONS_DIR}/${session_id}.state"
  LOG_FILE=$(get_session_field "${session_id}" "LOG_FILE")
  PART_LOG=$(get_session_field "${session_id}" "PART_LOG")
  SESSION_STATUS=$(get_session_field "${session_id}" "STATUS")
  SESSION_PID=$(get_session_field "${session_id}" "PID")
  # Set SESSION_LOGS_DIR for use in init_dirs
  SESSION_LOGS_DIR="${LOGS_DIR}/${SESSION_NAME}/${SESSION_ID}"
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
  local part_log
  local pid
  local created_at

  if ! validate_name "${name}"; then
    echo "Error: Invalid name '${name}'. Use only letters, numbers, underscore, hyphen."
    return 1
  fi

  init_dirs
  session_id=$(generate_session_id "${name}")
  tmux_session="${TMUX_SESSION_PREFIX}${session_id}"
  created_at=$(date +%Y-%m-%dT%H:%M:%S)

  # Create session-specific log directory with new structure: LOGS_DIR/SESSION_NAME/SESSION_ID/
  local session_logs_dir="${LOGS_DIR}/${name}/${session_id}"
  if [[ ! -d "${session_logs_dir}" ]]; then
    mkdir -p "${session_logs_dir}"
  fi

  # If no command provided, use the default shell as the command
  if [[ -z "${command}" ]]; then
    command="${SHELL:-/bin/bash}"
  fi

  # Create tmux session with the command (preserves TTY for interactive commands)
  # Use script with tee to capture TTY input/output while preserving interactivity
  # Dual-log system: main_log captures everything, part_log for partitioning
  # New path format: LOGS_DIR/SESSION_NAME/SESSION_ID/NAME.log and NAME-part.log
  log_file="${session_logs_dir}/${name}.log"
  part_log="${session_logs_dir}/${name}-part.log"

  # Create wrapper using envsubst for variable expansion
  # Use script with tee to create PTY for interactive commands with dual-log output
  # --flush ensures real-time logging by flushing after each write
  # tee writes to both main_log and part_log simultaneously
  # New wrapper location: session_logs_dir/wrapper
  # Export TMUX_ environment variables for use within the tmux session
  local wrapper="${session_logs_dir}/wrapper"
  cat > "${wrapper}" <<'EOF'
#!/bin/bash
# Export TMUX_ environment variables for use within the tmux session
# These variables are only available within the tmux session, not the parent process
export TMUX_NAME="${TMUX_NAME}"
export TMUX_ID="${TMUX_ID}"
export TMUX_SESSION="${TMUX_SESSION}"
export TMUX_COMMAND="${TMUX_COMMAND}"
export TMUX_LOG_FILE="${TMUX_LOG_FILE}"
export TMUX_PART_LOG="${TMUX_PART_LOG}"
export TMUX_CREATED_AT="${TMUX_CREATED_AT}"

# script creates PTY for TTY-dependent programs (vim, mysql, etc.)
# --flush ensures real-time logging by flushing after each write
# -O /dev/null prevents script from creating a typescript file in cwd
# tee writes to both MAIN_LOG and PART_LOG for dual-log system
exec script --flush -q -c "${COMMAND}" -O /dev/null 2>&1 | tee -a "${MAIN_LOG}" "${PART_LOG}"
EOF
  # Export variables for envsubst
  export COMMAND="${command}"
  export MAIN_LOG="${log_file}"
  export PART_LOG="${part_log}"
  export TMUX_NAME="${name}"
  export TMUX_ID="${session_id}"
  export TMUX_SESSION="${tmux_session}"
  export TMUX_COMMAND="${command}"
  export TMUX_LOG_FILE="${log_file}"
  export TMUX_PART_LOG="${part_log}"
  export TMUX_CREATED_AT="${created_at}"
  envsubst < "${wrapper}" > "${wrapper}.tmp"
  mv "${wrapper}.tmp" "${wrapper}"
  unset COMMAND MAIN_LOG PART_LOG TMUX_NAME TMUX_ID TMUX_SESSION TMUX_COMMAND TMUX_LOG_FILE TMUX_PART_LOG TMUX_CREATED_AT
  chmod +x "${wrapper}"

  tmux new-session -d -s "${tmux_session}" "${wrapper}"

  # Configure tmux session appearance
  configure_tmux_style "${tmux_session}"

  # Give session a moment to initialize
  sleep 0.1

  pid=$(tmux list-panes -t "${tmux_session}" -F "#{pane_pid}")

  save_session_state "${session_id}" "${name}" "${command}" "${pid}" "${log_file}" "${part_log}"

  echo "Session created: ${session_id}"

  # Auto-attach to the new session
  init_session_context "${session_id}"
  do_attach
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
    original_name=$(grep "^TMUX_NAME=" "${state_file}" | cut -d'=' -f2-)
    id=$(grep "^TMUX_ID=" "${state_file}" | cut -d'=' -f2)
    status=$(grep "^TMUX_STATUS=" "${state_file}" | cut -d'=' -f2)
    created_at=$(grep "^TMUX_CREATED_AT=" "${state_file}" | cut -d'=' -f2)
    pid=$(grep "^TMUX_PID=" "${state_file}" | cut -d'=' -f2)

    if [[ "${status}" == "running" ]] || [[ "${show_all}" == "true" ]]; then
      printf "%-15s %-30s %-10s %-20s %-8s\n" \
        "${original_name}" "${id}" "${status}" "${created_at}" "${pid}"
    fi
  done
}

do_attach() {
  if ! tmux has-session -t "${TMUX_SESSION}" 2>/dev/null; then
    echo "Error: Session '${SESSION_ID}' is not running."
    echo ""
    echo "Last 10 lines of log:"
    if [[ -f "${LOG_FILE}" ]]; then
      tail -n 10 "${LOG_FILE}"
    else
      echo "No log available."
    fi
    return 1
  fi

  tmux attach-session -t "${TMUX_SESSION}"
}

cmd_attach() {
  local identifier=$1

  refresh_running_sessions
  init_session_context "${identifier}"

  do_attach
}

cmd_logs() {
  local session_id=$1
  shift
  local follow_mode=false
  local tail_lines=""
  local raw_output=false
  local has_options=false

  init_session_context "${session_id}"

  if [[ ! -f "${LOG_FILE}" ]]; then
    echo "Error: Log file not found"
    return 1
  fi

  # Parse options
  while [[ $# -gt 0 ]]; do
    has_options=true
    case "$1" in
      --follow|-f)
        follow_mode=true
        shift
        ;;
      --tail|-t)
        if [[ "${2:-}" =~ ^[0-9]+$ ]]; then
          tail_lines="$2"
          shift 2
        else
          tail_lines="50"
          shift
        fi
        ;;
      --raw)
        raw_output=true
        shift
        ;;
      --clean)
        raw_output=false
        shift
        ;;
      *)
        echo "Error: Unknown option: $1"
        echo "Usage: tmux.sh logs <session-id> [options]"
        echo "Options:"
        echo "  -f, --follow [n]    Follow log (like tail -f), optionally starting from last n lines"
        echo "  -t, --tail [n]      Show last n lines (default: 50)"
        echo "  --raw              Show raw log with ANSI sequences"
        echo "  --clean            Filter ANSI sequences (default)"
        echo ""
        echo "If no options provided, defaults to: -f -t 50 (follow last 50 lines)"
        return 1
        ;;
    esac
  done

  # Default behavior: follow mode with last 50 lines if no options specified
  if [[ "${has_options}" == "false" ]]; then
    follow_mode=true
    tail_lines="50"
  fi

  # If -f is specified without -t, default to 50 lines
  if [[ "${follow_mode}" == "true" ]] && [[ -z "${tail_lines}" ]]; then
    tail_lines="50"
  fi

  # Build the tail command
  local tail_cmd="tail"
  if [[ -n "${tail_lines}" ]]; then
    tail_cmd="${tail_cmd} -n ${tail_lines}"
  fi
  if [[ "${follow_mode}" == "true" ]]; then
    tail_cmd="${tail_cmd} -f"
  fi

  # Execute with appropriate filtering
  if [[ "${raw_output}" == "true" ]]; then
    # Raw output: no filtering
    if [[ "${follow_mode}" == "true" ]]; then
      echo "Following logs for session: ${SESSION_ID} (Ctrl+C to exit)"
      echo "Note: Showing raw output with ANSI sequences. Use --clean to filter."
      echo ""
    fi
    ${tail_cmd} "${LOG_FILE}"
  else
    # Filtered output: remove ANSI sequences
    if [[ "${follow_mode}" == "true" ]]; then
      echo "Following logs for session: ${SESSION_ID} (Ctrl+C to exit)"
      echo "Note: Logs are filtered to remove ANSI escape sequences. Use --raw to preserve them."
      echo ""
    fi
    ${tail_cmd} "${LOG_FILE}" | sed 's/\x1b\[[0-9;]*m//g'
  fi
}

cmd_stop() {
  local identifier=$1
  local force=${2:-}

  refresh_running_sessions
  init_session_context "${identifier}"

  if [[ "${SESSION_STATUS}" != "running" ]]; then
    echo "Session '${SESSION_ID}' is not running (status: ${SESSION_STATUS})"
    return 0
  fi

  if [[ "${force}" == "--force" ]] || [[ "${force}" == "-f" ]]; then
    echo "Stopping session: ${SESSION_ID} (forced)"
    tmux kill-session -t "${TMUX_SESSION}"
    kill -9 "${SESSION_PID}" 2>/dev/null || true
  else
    echo "Stopping session: ${SESSION_ID} (PID: ${SESSION_PID})"
    tmux send-keys -t "${TMUX_SESSION}" C-c
    sleep 1

    if tmux has-session -t "${TMUX_SESSION}" 2>/dev/null; then
      echo "Session still running, use --force to kill"
      return 0
    fi
  fi

  update_session_status "${SESSION_ID}" "stopped"
}

cmd_send() {
  local identifier=$1
  shift

  # Parse options
  local ignore_log=false
  local no_enter=false
  local separate_enter=false
  local keys=""

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --ignore-log)
        ignore_log=true
        shift
        ;;
      --no-enter)
        no_enter=true
        shift
        ;;
      --separate-enter)
        separate_enter=true
        shift
        ;;
      -*)
        echo "Error: Unknown option: $1"
        echo "Usage: tmux.sh send <name-or-id> [options] <keys>"
        echo "Options:"
        echo "  --ignore-log      Don't log the sent keys"
        echo "  --no-enter        Don't send Enter after keys"
        echo "  --separate-enter  Send keys and Enter in two separate commands"
        return 1
        ;;
      *)
        keys="$1"
        shift
        ;;
    esac
  done

  # Validate required arguments
  if [[ -z "${identifier}" ]] || [[ -z "${keys}" ]]; then
    echo "Error: send requires <name-or-id> and <keys>"
    return 1
  fi

  # Find session using init_session_context
  refresh_running_sessions
  if ! init_session_context "${identifier}"; then
    return 1
  fi

  if [[ "${SESSION_STATUS}" != "running" ]]; then
    echo "Error: Session '${SESSION_ID}' is not running (status: ${SESSION_STATUS})"
    return 1
  fi

  # Send keys based on mode
  if [[ "${separate_enter}" == "true" ]]; then
    # Separate mode (for Claude CLI, etc.)
    tmux send-keys -t "${TMUX_SESSION}" "${keys}"
    if [[ "${no_enter}" == "false" ]]; then
      tmux send-keys -t "${TMUX_SESSION}" Enter
    fi
  else
    # Normal mode (single command)
    local send_keys="${keys}"
    if [[ "${no_enter}" == "false" ]]; then
      send_keys="${send_keys} Enter"
    fi
    # Note: send_keys is intentionally unquoted to allow tmux to interpret Enter
    tmux send-keys -t "${TMUX_SESSION}" ${send_keys}
  fi

  # Log if needed
  if [[ "${ignore_log}" == "false" ]]; then
    if [[ -n "${LOG_FILE}" ]] && [[ -f "${LOG_FILE}" ]]; then
      local timestamp
      timestamp=$(date '+%Y-%m-%d %H:%M:%S')
      echo "[${timestamp}] [SENT] ${keys}" >> "${LOG_FILE}"
    fi
  fi

  echo "Keys sent to session: ${SESSION_ID}"
}

cmd_clean() {
  local days=${1:-7}
  local dry_run=${2:-}
  local now
  local count=0

  now=$(date +%s)

  echo "Cleaning sessions older than ${days} days..."

  # Refresh session status first to ensure accurate state
  refresh_running_sessions

  local state_file
  local session_time
  local age_days
  local status
  local id
  local created_at
  local log_file
  local part_log

  for state_file in "${SESSIONS_DIR}"/*.state; do
    [[ -f "${state_file}" ]] || continue

    # Parse state file safely (use || true to prevent exit on missing fields)
    status=$(grep "^TMUX_STATUS=" "${state_file}" | cut -d'=' -f2) || status=""
    id=$(grep "^TMUX_ID=" "${state_file}" | cut -d'=' -f2) || id=""
    created_at=$(grep "^TMUX_CREATED_AT=" "${state_file}" | cut -d'=' -f2) || created_at=""
    log_file=$(grep "^TMUX_LOG_FILE=" "${state_file}" | cut -d'=' -f2-) || log_file=""
    part_log=$(grep "^TMUX_PART_LOG=" "${state_file}" | cut -d'=' -f2-) || part_log=""

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

        # Remove entire session log directory (includes logs, wrapper, parts, etc.)
        if [[ -n "${log_file}" ]]; then
          local session_log_dir
          session_log_dir=$(dirname "${log_file}")
          if [[ -d "${session_log_dir}" ]]; then
            rm -rf "${session_log_dir}"
          fi

          # Remove session name directory if empty
          local session_name_dir
          session_name_dir=$(dirname "${session_log_dir}")
          if [[ -d "${session_name_dir}" ]]; then
            rmdir "${session_name_dir}" 2>/dev/null || true
          fi
        fi
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

cmd_part_log() {
  local identifier=$1
  local part_name=${2:-}
  local copy_mode=false
  local last_log_mode=false

  # Parse --copy, --last-log arguments
  if [[ "${part_name}" == "--copy" ]]; then
    copy_mode=true
    part_name=""
  elif [[ "${part_name}" == "--last-log" ]]; then
    last_log_mode=true
    part_name=""
  fi

  if [[ -n "${3:-}" ]]; then
    if [[ "${3}" == "--copy" ]]; then
      copy_mode=true
    elif [[ "${3}" == "--last-log" ]]; then
      last_log_mode=true
    else
      part_name="${3}"
    fi
  fi

  # Check if --last-log mode (only print latest part log path)
  if [[ "${last_log_mode}" == "true" ]]; then
    # Initialize session context
    refresh_running_sessions
    if ! init_session_context "${identifier}"; then
      return 1
    fi

    # Check if session has part log
    if [[ -z "${PART_LOG}" ]] || [[ ! -f "${PART_LOG}" ]]; then
      echo "Error: No part log found (plain sessions don't have logs)" >&2
      return 1
    fi

    # Find latest part log in parts directory
    local parts_dir="${SESSION_LOGS_DIR}/parts"
    if [[ ! -d "${parts_dir}" ]]; then
      echo "No part log archives found (parts directory doesn't exist)"
      return 0
    fi

    # Get the most recently modified log file
    local latest_log=$(ls -t "${parts_dir}"/${SESSION_NAME}-*.log 2>/dev/null | head -1)
    if [[ -z "${latest_log}" ]]; then
      echo "No part log archives found"
      return 0
    fi

    echo "${latest_log}"
    return 0
  fi

  # Initialize session context
  refresh_running_sessions
  if ! init_session_context "${identifier}"; then
    return 1
  fi

  # Check if session has part log
  if [[ -z "${PART_LOG}" ]] || [[ ! -f "${PART_LOG}" ]]; then
    echo "Error: No part log found (plain sessions don't have logs)" >&2
    return 1
  fi

  # Check part log is not empty
  if [[ ! -s "${PART_LOG}" ]]; then
    echo "Error: Part log is empty, nothing to archive" >&2
    return 1
  fi

  # Generate archive filename
  if [[ -z "${part_name}" ]]; then
    part_name=$(date +%Y-%m-%d-%H-%M-%S)
  fi

  # Create parts directory
  local parts_dir="${SESSION_LOGS_DIR}/parts"
  mkdir -p "${parts_dir}"

  # Handle filename conflicts
  local archive_file="${parts_dir}/${SESSION_NAME}-${part_name}.log"
  local counter=1
  while [[ -f "${archive_file}" ]]; do
    archive_file="${parts_dir}/${SESSION_NAME}-${part_name}.${counter}.log"
    ((counter++))
  done

  # Copy part log to archive
  cp "${PART_LOG}" "${archive_file}"

  # Based on mode: clear or preserve
  if [[ "${copy_mode}" == "false" ]]; then
    : > "${PART_LOG}"
    echo "Part log archived to: ${archive_file}"
    echo "Part log cleared for new entries"
  else
    echo "Part log copied to: ${archive_file}"
    echo "Original part log preserved"
  fi

  # Display statistics
  local lines=$(wc -l < "${archive_file}")
  local size=$(du -h "${archive_file}" | cut -f1)
  echo "Lines: ${lines}"
  echo "Size: ${size}"
}

show_usage() {
  cat <<EOF
tmux.sh - Asynchronous command execution tool

Usage:
  tmux.sh start <name> <command> [args...]   Start an async command
  tmux.sh attach <name-or-id>               Attach to a session
  tmux.sh list [--all]                      List sessions
  tmux.sh logs <session-id> [options]       View logs
  tmux.sh send <name-or-id> [options] <keys> Send keys to a session
  tmux.sh stop <name-or-id> [--force]       Stop a session
  tmux.sh part-log <name-or-id> [name] [--copy] Partition log
  tmux.sh clean [days] [--dry-run]          Clean old sessions

Log Options:
  (no options)       Default: follow last 50 lines (real-time)
  -f, --follow [n]   Follow log (like tail -f), optionally starting from last n lines
  -t, --tail [n]     Show last n lines (default: 50)
  --raw              Show raw log with ANSI sequences (may affect terminal)
  --clean            Explicitly filter ANSI sequences (default)

  Examples:
    tmux.sh logs <id>                 # Follow last 50 lines (default)
    tmux.sh logs <id> -f              # Same as default
    tmux.sh logs <id> -f 100          # Follow last 100 lines
    tmux.sh logs <id> -t 20           # Show last 20 lines (not following)
    tmux.sh logs <id> --raw -f        # Follow with raw output

Part-Log Options:
  [name]            Optional name for the partition (default: timestamp)
  --copy            Copy part log without clearing it
  --last-log        Print the latest part log archive path

  Examples:
    tmux.sh part-log <id>             # Archive and clear with timestamp
    tmux.sh part-log <id> feature1    # Archive with custom name
    tmux.sh part-log <id> --copy      # Copy without clearing
    tmux.sh part-log <id> --last-log   # Show latest archive path

Send Options:
  --ignore-log      Don't log the sent keys
  --no-enter        Don't send Enter after keys
  --separate-enter  Send keys and Enter in two separate commands

General Options:
  --all       Show all sessions (including stopped ones)
  --force     Force stop session
  --dry-run   Simulate run without actual deletion

Examples:
  tmux.sh start build make release
  tmux.sh start dev npm run dev
  tmux.sh attach dev
  tmux.sh send interactive "yes"
  tmux.sh send claude "Python" --separate-enter
  tmux.sh part-log dev feature1        # Archive part log

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

  command=$1
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
    send)
      if [[ $# -lt 1 ]]; then
        echo "Error: send requires <name-or-id> and <keys>"
        exit 1
      fi
      cmd_send "$@"
      ;;
    clean)
      cmd_clean "$@"
      ;;
    part-log)
      if [[ $# -lt 1 ]]; then
        echo "Error: part-log requires <name-or-id>"
        exit 1
      fi
      cmd_part_log "$@"
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
