alias reload!='. ~/.zshrc'

alias cls='clear' # Good 'ol Clear Screen command

eval "$(hub alias -s)"

port() {
    lsof -i:$1
}

killport() {
    lsof -ti:$1 | xargs kill
}

dotenv() {
    set -o allexport
    source $1
    set +o allexport
}

dotfiles() {
    $EDITOR ~/.dotfiles
}

# Usage: copyFromRemote <SSH Config Host> <remote file/dir> <local file/dir>
# Example: copyFromRemote myServer ~/remote/path ~/local/path
copyFromRemote() {
    rsync -avze ssh $1:$2 $3
}

# Usage: copyToRemote <SSH Config Host> <local file/dir> <remote file/dir>
# Example: copyToRemote myServer ~/local/path ~/remote/path
copyToRemote() {
    rsync -avze ssh $2 $1:$3
}