#!/bin/bash

modified_tasks=()
while IFS= read -r line; do
    [[ -n "$line" ]] && modified_tasks+=("$line")
done

if [[ ${#modified_tasks[@]} -gt 0 ]]; then
	/usr/bin/tmux send-keys -t bg:1.1 q
	/usr/bin/tmux send-keys -t bg:1.2 Enter
fi

exit 0
