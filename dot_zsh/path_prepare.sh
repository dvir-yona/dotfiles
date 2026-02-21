typeset -U path PATH

path=(
    "$HOME/bin"
    "$HOME/.local/bin"
    "/usr/local/bin"
    
    $path
    
    "$HOME/.cargo/bin"
    "$HOME/go/bin"
    "$HOME/.bun/bin"
)

export PATH
