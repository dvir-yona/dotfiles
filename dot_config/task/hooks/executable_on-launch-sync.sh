#!/bin/bash

if [[ "$*" == *sync* ]] || [[ "$TASK_RC_HOOKS" == "off" ]]; then
    exit 0
fi

timeout 3s task rc.hooks=off rc.verbose=nothing sync >/dev/null 2>&1

exit 0
