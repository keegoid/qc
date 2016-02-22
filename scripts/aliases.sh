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

# if user doesn't exist, add new user
if [ "$(user_exists $USER_NAME)" = false ]; then
   echo
   sudo /usr/sbin/adduser $USER_NAME
fi

# append aliases to .bashrc if not done already
pause "Press enter to add useful aliases for $USER_NAME..."
if grep -q "alias wget" /home/$USER_NAME/.bashrc; then
   echo "already added aliases for $USER_NAME..."
else
# alias useful shell commands
cat << EOF >> /home/$USER_NAME/.bashrc

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

# print aliases
alias aliases="cat /home/$USER_NAME/.bashrc"
EOF
   echo "/home/$USER_NAME/.bashrc was updated"
fi

