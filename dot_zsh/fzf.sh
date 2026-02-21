export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS=" \
--layout=reverse --border rounded --prompt='➤ ' --pointer='➜' \
--color=bg+:#313244,bg:#1e1e2e,fg:#cdd6f4,fg+:#cdd6f4 \
--color=header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,prompt:#cba6f7,hl+:#f38ba8"

zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'

zstyle ':fzf-tab:complete:*:*' fzf-preview '[[ -d $realpath ]] && eza -1 --color=always $realpath || head -n 100 $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' fzf-flags --bind=ctrl-j:down,ctrl-k:up
