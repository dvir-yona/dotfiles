habit() {
    local proj=$1
    if [[ -z "$proj" ]]; then
        echo "Usage: habit <project_name>"
        return 1
    fi

    local -x PAGER=cat
    export TIMEWARRIORDB="$HOME/.config/timewarrior"

    echo -e "\n\033[1;34m  HABIT DASHBOARD: $proj\033[0m"
    echo "==================================================================="

    # 1. GET DATA
    local completions=$(task project:"$proj" status:completed export 2>/dev/null)
    local pending_count=$(task project:"$proj" status:pending count 2>/dev/null)
    local timew_data=$(timew export :week "$proj" 2>/dev/null)

    # 2. CORE LOGIC (Python)
    python3 -c "
import sys, json, datetime, calendar
from datetime import timedelta

try:
    # --- LOAD TASK DATA ---
    comp_json = json.loads('''$completions''')
    # Use a set of dates to get unique 'active' days
    comp_dates = {datetime.datetime.strptime(t['end'][:8], '%Y%m%d').date() for t in comp_json if 'end' in t}
    
    # --- LOAD TIME DATA ---
    try: tw_json = json.loads('''$timew_data''')
    except: tw_json = []

    today = datetime.date.today()
    
    # --- STREAK CALCULATION ---
    streak = 0
    sorted_comps = sorted(list(comp_dates), reverse=True)
    if sorted_comps:
        if sorted_comps[0] in [today, today - timedelta(days=1)]:
            streak = 1
            for i in range(len(sorted_comps)-1):
                diff = (sorted_comps[i] - sorted_comps[i+1]).days
                if diff == 1: streak += 1
                elif diff == 0: continue
                else: break

    print(f'Streak: \033[1;32m{streak} days\033[0m | Pending Tasks: {sys.argv[1]}')
    
    # --- WEEKLY EFFORT CHART ---
    print('\n\033[1;36m󱎫  Weekly Effort (Last 7 Days):\033[0m')
    days_range = [(today - timedelta(days=i)) for i in range(6, -1, -1)]
    effort = {d: 0 for d in days_range}
    for interval in tw_json:
        s_dt = datetime.datetime.strptime(interval['start'], '%Y%m%dT%H%M%SZ')
        if s_dt.date() in effort:
            e_dt = datetime.datetime.strptime(interval['end'], '%Y%m%dT%H%M%SZ') if 'end' in interval else datetime.datetime.utcnow()
            effort[s_dt.date()] += (e_dt - s_dt).total_seconds()

    max_sec = max(effort.values()) if max(effort.values()) > 0 else 1
    chars = [' ', ' ', '▂', '▃', '▄', '▅', '▆', '▇', '█']
    bar_str, label_list = '', []
    
    for d in days_range:
        bar_str += chars[int((effort[d] / max_sec) * 8)] + '  '
        char = d.strftime('%a')[0]
        label = f'\033[1;35m{char}\033[0m' if d in comp_dates else char
        if d == today:
            label = f'\033[4m{label}\033[0m'
        label_list.append(label)

    print(f'  {bar_str}\n  ' + '  '.join(label_list))

    # --- MONTHLY CONSISTENCY (The new logic) ---
    print('\n\033[1;35m󰗵  Monthly Consistency (% of days active):\033[0m')
    
    # Group unique active days by (year, month)
    monthly_activity = {}
    for d in comp_dates:
        key = (d.year, d.month)
        if key not in monthly_activity: monthly_activity[key] = set()
        monthly_activity[key].add(d.day)

    # Show last 3 months (including current)
    months_to_show = []
    for i in range(2, -1, -1):
        target = today.replace(day=1) - timedelta(days=i*30) # Rough month jump
        months_to_show.append((target.year, target.month))
    
    # deduplicate and sort to ensure current month is last
    months_to_show = sorted(list(set(months_to_show)))

    for (y, m) in months_to_show:
        active_days = len(monthly_activity.get((y, m), set()))
        # Total days in that month
        total_days = calendar.monthrange(y, m)[1]
        
        # If it is the current month, only compare against days passed so far
        denominator = today.day if (y == today.year and m == today.month) else total_days
        
        pct = (active_days / denominator) * 100 if denominator > 0 else 0
        
        # Progress Bar
        bar_len = 15
        filled = int((pct / 100) * bar_len)
        bar = '\033[32m█\033[0m' * filled + '\033[90m░\033[0m' * (bar_len - filled)
        
        month_name = calendar.month_name[m]
        print(f'  {month_name:<9} {bar} {pct:5.1f}%')
				
    print(f'\n\033[1;35m󰗵  {today.strftime(\"%B\")} Heatmap:\033[0m')
    days_in_month = calendar.monthrange(today.year, today.month)[1]
    heatmap = ''
    for day in range(1, days_in_month + 1):
        d = datetime.date(today.year, today.month, day)
        if d > today: heatmap += '\033[90m·\033[0m' # Future
        elif d in comp_dates: heatmap += '\033[32m▣\033[0m' # Done
        else: heatmap += '\033[31m▢\033[0m' # Missed
    print(f'  {heatmap}')

except Exception as e:
    print(f'Error: {e}')
" "$pending_count"
    echo "==================================================================="
}
