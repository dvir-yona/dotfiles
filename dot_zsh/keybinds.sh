autoload -Uz edit-command-line
function robust-edit-command-line() {
    zle -I
		edit-command-line 
    zle reset-prompt 
}
zle -N robust-edit-command-line

function zvm_after_init() {
	zvm_bindkey viins '^I' fzf-tab-complete

  # --- Alt-hjkl (Movement & History) ---
  # These will NOT conflict with Tmux Ctrl-hjkl or Alt-hjkl window navigation
  zvm_bindkey viins '^[h' backward-word           # Alt-h: Move back one word
  zvm_bindkey viins '^[l' forward-word            # Alt-l: Move forward one word
  zvm_bindkey viins '^[k' history-substring-search-up   # Alt-k: History search up
  zvm_bindkey viins '^[j' history-substring-search-down # Alt-j: History search down

  # --- Shift-Alt-HJKL (Variations) ---
  zvm_bindkey viins '^[H' beginning-of-line       # Alt-Shift-h: Jump to start
  zvm_bindkey viins '^[L' end-of-line             # Alt-Shift-l: Jump to end
  zvm_bindkey viins '^[K' up-history              # Alt-Shift-k: Raw history up
  zvm_bindkey viins '^[J' down-history            # Alt-Shift-j: Raw history down

  # --- Command Editing & Suggestions ---
  zvm_bindkey viins '^[e' robust-edit-command-line
  zvm_bindkey vicmd '^[e' robust-edit-command-line

	zvm_bindkey viins '^[i' autosuggest-accept
}

bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
