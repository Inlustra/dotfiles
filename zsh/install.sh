
antibodyInPath() {
  if [[ -n $ZSH_VERSION ]]; then
    builtin whence -p "antibody" &> /dev/null
  else  # bash:
    builtin type -P "antibody" &> /dev/null
  fi
}

 antibody_path=$(which antibody)
 if antibodyInPath; then
    echo "Antibody already installed"
 else
    curl -sfL git.io/antibody | sh -s - -b /usr/local/bin
 fi
