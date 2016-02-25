#!/bin/bash
echo "# --------------------------------------------"
echo "# Add some useful shell aliases.              "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# append aliases to .bashrc if not done already
if grep -q "alias wget" $HOME/.bashrc; then
   echo "already added aliases..."
else
   pause "Press [Enter] to add useful aliases" true
# alias useful shell commands, EOF must not be indented
cat << EOF >> $HOME/.bashrc

# make directories and parents
alias mkdir='mkdir -pv'

# list open ports
alias ports='netstat -tulanp'

# shortcut for systemctl
alias sctl='systemctl'

# display headers
alias header='curl -I'
 
# display headers that support compression 
alias headerc='curl -I --compress'

# delete protection
alias rm='rm -I --preserve-root'
 
# confirm operation
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

# reboot and shutdown
alias reboot='sudo /sbin/reboot'
alias shutdown='sudo /sbin/shutdown'

# list memory info
alias meminfo='free -m -l -t'

# list network info
alias netinfo='lspci -k -nn | grep -A 3 -i net'
alias netinfo2='sudo lshw -C network'
alias netinfo3='modinfo iwlwifi'
alias netinfo4='dmesg | grep iwl'

# nginx test
alias nginxtest='sudo /usr/local/nginx/sbin/nginx -t'

# OS version
alias osversion='cat /etc/*release*'

# resume downloads
alias wget='wget -c'

# git log
alias gitlog='git log --oneline --decorate'

# print aliases
alias aliases="cat $HOME/.bashrc"
EOF
   source "$HOME/.bashrc"
   echo "$HOME/.bashrc was updated and sourced"
fi

