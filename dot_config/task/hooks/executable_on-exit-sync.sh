if [ -n "$1" ]; then
    task rc.hooks=off rc.verbose=nothing sync >/dev/null 2>&1 &
fi
exit 0
