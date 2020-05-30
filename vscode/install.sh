
ZSH=$HOME/.dotfiles
if [ "$(uname)" == "Darwin" ]; then
    $ZSH/bin/link-file  "$HOME/.vscode.conf" "$HOME/Library/Application Support/Code/User"
else
    $ZSH/bin/log_user "Skipping vscode linking as not on mac."
fi