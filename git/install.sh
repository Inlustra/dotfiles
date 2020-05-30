git config core.hooksPath git/hooks/



aptInPath() {
  if [[ -n $ZSH_VERSION ]]; then
    builtin whence -p "apt-get" &> /dev/null
  else  # bash:
    builtin type -P "apt-get" &> /dev/null
  fi
}

hubInPath() {
  if [[ -n $ZSH_VERSION ]]; then
    builtin whence -p "hub" &> /dev/null
  else  # bash:
    builtin type -P "hub" &> /dev/null
  fi
}

if hubInPath; then
    echo "hub already installed"
else
    if aptInPath; then
        add-apt-repository ppa:cpick/hub
        apt-get update
        apt-get install -y hub 
    fi;
fi
