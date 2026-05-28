#!/bin/bash
# Generic parent-link hook for Taskwarrior.
# Supports multiple parent-pointer UDAs (default: proot, p) in a single pass.
#
# Hook deployment (single shared script, symlinked):
#   ln -sf <this script> ~/.task/hooks/on-modify-parent-link
#   ln -sf <this script> ~/.task/hooks/on-exit-parent-link
#   → automatically processes every field in FIELDS_DEFAULT (in order).
#
# UDA contract (.taskrc):
# ```.taskrc
# # Parent-pointer UDAs. Each <field> also needs a `_o<field>` stash slot,
# # used by the on-modify hook to remember the previous value so on-exit can
# # drop the old depends edge. Both fields are processed by the same hook:
# #   /home/ldz/.vim/config/taskwarrior-parent-link.sh
# #
# #   proot = project root task (set by context.<ctx>.write, rarely overridden)
# #   p     = ad-hoc parent (set per-command-line; coexists with proot)
# uda.proot.type=string
# uda.proot.label=ProjectRoot
# uda._oproot.type=string      # internal: previous proot staging slot
# uda._oproot.label=_OldProot
# 
# uda.p.type=string
# uda.p.label=Parent
# uda._op.type=string          # internal: previous p staging slot
# uda._op.label=_OldP
# 
# # task project: list all project root tasks (filter=project:root), always ignore context
# report.project.description=Project root tasks
# report.project.columns=id,uuid.short,project,tags,depends.count,description.count
# report.project.labels=ID,UUID,Project,Tags,Children,Desc
# report.project.sort=project+,id+
# report.project.filter=project:root
# report.project.context=0
#
# # Context pattern (placeholders: <ctx>, <project>, <root_uuid>, <desc>):
# #   context.<ctx>.read  = filter applied to reports/lists
# #   context.<ctx>.write = modifiers auto-applied to `task add` / `task modify`
# #   proot:<root_uuid>   = UDA "ProjectRoot" (see uda.proot above). Value is the
# #                         project root task's UUID (full, or unambiguous prefix).
# #                         The hook turns this into a depends: edge on that task.
# #   p:<parent_uuid>     = optional second parent set on the command line; does
# #                         NOT collide with proot, so a child can have BOTH a
# #                         project root parent AND an ad-hoc parent.
# #
# # Template:
# #   context.<ctx>.read=project:<project>
# #   context.<ctx>.write=project:<project> proot:<root_uuid>
# #   context=<ctx>
# #
# # Under the active context, `task add "<desc>"` becomes equivalent to:
# #   task add "<desc>" project:<project> proot:<root_uuid>
# # And `task add "<desc>" p:<parent_uuid>` adds a second parent without
# # losing the context's proot.
# #
# ```
#

# CLI / debugging (explicit role required to disambiguate stdin shape):
#   parent-link.sh on-modify proot          # process only `proot`, stdin = 2 JSON lines
#   parent-link.sh on-exit   p              # process only `p`,     stdin = N JSON lines
#   parent-link.sh on-modify proot p        # multiple fields in order
#
# Why two hooks?
#   on-modify runs BEFORE Taskwarrior flushes pending.data, so cross-task edits
#   get silently overwritten when the main process rewrites the file. on-exit
#   runs AFTER the flush — cross-task edits made there persist.
#
# Why the _o<f> stash UDA?
#   on-modify can only mutate the task being saved (its JSON output is what
#   persists). It cannot directly drop the OLD parent's depends edge. So we
#   stash the old value into the task's own _o<f> slot; on-exit reads that
#   slot, removes the old depends, and clears the slot.
#
# Triggers covered (per field):
#   task add "x" <f>:N
#   task M modify <f>:N      (re-parent)
#   task M modify <f>:       (un-parent)
#   task M edit              (UDA <f> line)

set -u

FIELDS_DEFAULT=(proot p)   # processed in this order
STASH_PREFIX="_o"          # → _op, _oproot, ...

# ────────────────────────────────────────────────────────────────────────────
# Core per-field processors
# ────────────────────────────────────────────────────────────────────────────

# Args: <field> <old_json> <new_json>
# Stdout: possibly-mutated <new_json> (single-line JSON; hook protocol)
process_on_modify_field() {
    local field="$1" old_json="$2" new_json="$3"
    local stash="${STASH_PREFIX}${field}"
    local old_v new_v
    old_v=$(echo "$old_json" | jq -r --arg f "$field" '.[$f] // empty')
    new_v=$(echo "$new_json" | jq -r --arg f "$field" '.[$f] // empty')

    if [ -n "$old_v" ] && [ "$old_v" != "$new_v" ]; then
        echo "$new_json" | jq -c --arg sk "$stash" --arg sv "$old_v" '. + {($sk): $sv}'
    else
        echo "$new_json"
    fi
}

# Args: <field> <task_json_line>
# Effect: links new parent → child; drops old parent → child; clears stash.
process_on_exit_field() {
    local field="$1" line="$2"
    local stash="${STASH_PREFIX}${field}"
    local parent child old_parent
    parent=$(echo     "$line" | jq -r --arg f "$field" '.[$f] // empty')
    child=$(echo      "$line" | jq -r '.uuid')
    old_parent=$(echo "$line" | jq -r --arg s "$stash" '.[$s] // empty')

    if [ -n "$parent" ] && [ -n "$child" ]; then
        task rc.hooks=off rc.verbose=nothing "$parent" modify "depends:$child" >/dev/null 2>&1
    fi
    if [ -n "$old_parent" ] && [ -n "$child" ]; then
        task rc.hooks=off rc.verbose=nothing "$old_parent" modify "depends:-$child" >/dev/null 2>&1
        task rc.hooks=off rc.verbose=nothing "$child"      modify "${stash}:"        >/dev/null 2>&1
    fi
}

# ────────────────────────────────────────────────────────────────────────────
# Dispatchers (read stdin, fan out across fields)
# ────────────────────────────────────────────────────────────────────────────

dispatch_on_modify() {
    local -a fields=("$@")
    [ ${#fields[@]} -eq 0 ] && fields=("${FIELDS_DEFAULT[@]}")
    local old_json new_json
    IFS= read -r old_json
    IFS= read -r new_json
    for f in "${fields[@]}"; do
        new_json=$(process_on_modify_field "$f" "$old_json" "$new_json")
    done
    echo "$new_json"
}

dispatch_on_exit() {
    local -a fields=("$@")
    [ ${#fields[@]} -eq 0 ] && fields=("${FIELDS_DEFAULT[@]}")
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        for f in "${fields[@]}"; do
            process_on_exit_field "$f" "$line"
        done
    done
}

# ────────────────────────────────────────────────────────────────────────────
# Entry point — role from explicit arg OR from invocation name (symlink)
# ────────────────────────────────────────────────────────────────────────────

role=""
from_cli=0
if [ $# -ge 1 ] && [[ "$1" == "on-modify" || "$1" == "on-exit" ]]; then
    role="$1"; shift
    from_cli=1
else
    case "$(basename "$0")" in
        on-modify-*) role="on-modify" ;;
        on-exit-*)   role="on-exit"   ;;
    esac
fi

if [ -z "$role" ]; then
    cat >&2 <<EOF
Unknown role. Invoke as a hook (symlink named on-modify-* / on-exit-*),
or pass role explicitly:
  $0 on-modify <field> [field ...]
  $0 on-exit   <field> [field ...]
EOF
    exit 1
fi

# Hook mode: Taskwarrior 2.6+ (hook API v2) passes meta args like
#   api:2 args:... command:... rc:... data:... version:...
# Discard them so they don't pollute the field list; dispatchers fall back
# to FIELDS_DEFAULT.
[ $from_cli -eq 0 ] && set --

case "$role" in
    on-modify) dispatch_on_modify "$@" ;;
    on-exit)   dispatch_on_exit   "$@" ;;
esac
exit 0
