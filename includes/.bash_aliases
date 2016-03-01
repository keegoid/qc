# --------------------------------------------
# aliases
# --------------------------------------------

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

# find file in home
alias findf='find ~/ -type f -name'

# find directory in home
alias findd='find ~/ -type d -name'

# find file in anywhere
alias findfroot='sudo find / -type f -name'

# find directory in anywhere
alias finddroot='sudo find / -type d -name'

# always copy resulting url to clipboard
alias gist='gist -c'

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
alias aliases="cat /home/kmullaney/.bashrc"
