local LAZY_DIR="$HOME/.zsh/lazy_sources"

lazy_load() {
    local cmd=$1
    local init_script=$2
    
    eval "$cmd() {
        echo \"💤 Waking up $cmd...\"
        unfunction $cmd
        source $init_script
        $cmd \"\$@\"
    }"
}

lazy_load "nvm" "/usr/share/nvm/init-nvm.sh"
lazy_load "node" "/usr/share/nvm/init-nvm.sh"
lazy_load "npm" "/usr/share/nvm/init-nvm.sh"
lazy_load "habit" "$LAZY_DIR/habit.sh"
