#!/bin/bash
# Single-source hook for Taskwarrior parent-child relationship via UDA `p`.
#
# Installed as TWO symlinks pointing here:
#   ~/.task/hooks/on-modify-parent  ->  taskwarrior-parent-link.sh
#   ~/.task/hooks/on-exit-parent    ->  taskwarrior-parent-link.sh
#
# REQUIRED CONFIG in ~/.taskrc:
# ```
#   uda.p.type=string
#   uda.p.label=Parent
#   uda._op.type=string          # internal: previous parent staging slot
#   uda._op.label=_OldP
#
#   # task project: list all project root tasks (filter=project:root), always ignore context
#   report.project.description=Project root tasks
#   report.project.columns=id,uuid.short,project,tags,depends.count,description.count
#   report.project.labels=ID,UUID,Project,Tags,Children,Desc
#   report.project.sort=project+,id+
#   report.project.filter=project:root
#   report.project.context=0
#   
#   # Context pattern (placeholders: <ctx>, <project>, <parent_uuid>, <desc>):
#   #   context.<ctx>.read  = filter applied to reports/lists
#   #   context.<ctx>.write = modifiers auto-applied to `task add` / `task modify`
#   #   p:<parent_uuid>     = UDA "Parent" (see uda.p above). Value is the parent
#   #                         task's UUID (full, or unambiguous prefix). The
#   #                         on-modify/on-exit hooks turn this into a depends:
#   #                         edge on the parent task.
#   #
#   # Template:
#   #   context.<ctx>.read=project:<project>
#   #   context.<ctx>.write=project:<project> p:<parent_uuid>
#   #   context=<ctx>
#   #
#   # Under the active context, `task add "<desc>"` becomes equivalent to:
#   #   task add "<desc>" project:<project> p:<parent_uuid>
# ```
# Why two hooks?
#   on-modify runs BEFORE Taskwarrior flushes pending.data, so cross-task
#   modifications get silently overwritten when the main process rewrites
#   the file. on-exit runs AFTER the flush — cross-task edits there persist.
#
# Why the _op UDA?
#   on-modify cannot directly remove the old parent's depends edge, but it
#   CAN modify the task being saved (its output JSON is what gets persisted).
#   So we stash the old parent into the task's own `_op` field. on-exit then
#   reads that field, removes the old depends, and clears `_op`.
#
# Triggers covered:
#   task add "x" p:N
#   task M modify p:N            (re-parent)
#   task M modify p:             (un-parent)
#   task M edit                  (UDA p line)

case "$(basename "$0")" in
on-modify-*)
    old_json=""
    new_json=""
    i=0
    while IFS= read -r line; do
        if [ $i -eq 0 ]; then old_json="$line"; else new_json="$line"; fi
        i=$((i + 1))
    done

    old_p=$(echo "$old_json" | jq -r '.p // empty')
    new_p=$(echo "$new_json" | jq -r '.p // empty')

    # If parent changed (incl. cleared) and there was an old parent,
    # stash it on the task itself for on-exit to clean up.
    # NOTE: -c is critical — hook protocol requires single-line JSON output.
    if [ -n "$old_p" ] && [ "$old_p" != "$new_p" ]; then
        new_json=$(echo "$new_json" | jq -c --arg op "$old_p" '. + {_op: $op}')
    fi

    echo "$new_json"
    exit 0
    ;;

on-exit-*)
    while IFS= read -r line; do
        parent=$(echo "$line"  | jq -r '.p   // empty')
        child=$(echo "$line"   | jq -r '.uuid')
        old_p=$(echo "$line"   | jq -r '._op // empty')

        # Step 1: link new parent → child
        if [ -n "$parent" ] && [ -n "$child" ]; then
            task rc.hooks=off rc.verbose=nothing "$parent" modify "depends:$child" >/dev/null 2>&1
        fi

        # Step 2: drop old parent → child, then clear the staging slot
        if [ -n "$old_p" ] && [ -n "$child" ]; then
            task rc.hooks=off rc.verbose=nothing "$old_p" modify "depends:-$child" >/dev/null 2>&1
            task rc.hooks=off rc.verbose=nothing "$child" modify "_op:"            >/dev/null 2>&1
        fi
    done
    exit 0
    ;;

*)
    echo "Unknown hook role: $0" >&2
    exit 1
    ;;
esac

