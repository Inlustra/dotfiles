GIT_EXTS="$(sort ~/.dotfiles/vscode/extensions)"

echo $GIT_EXTS | while read line ; do
    $ZSH/bin/log_info "Installing $line"
    code --install-extension $line --force
done