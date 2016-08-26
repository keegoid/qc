#!/bin/bash
# configure sudoers file
# chmod +x sudoers.sh

conf_file="/etc/sudoers.d/sudomods"

# add sudomods to /etc/sudoers.d/
[ -f "$conf_file" ] || sudo touch "$conf_file"
egrep -qi "timestamp_timeout=120" "$conf_file"
if [ $? -eq 0 ]; then
  echo "$conf_file already updated"
else
  echo "setting sudo timeout to 120 minutes"
  echo "Defaults        timestamp_timeout=120" | sudo tee "$conf_file"
fi

# original version modified visudo directly
#if [ -z "$1" ]; then
#    echo "Starting up visudo with this script as first parameter"
#    export EDITOR=$0 && /usr/sbin/visudo
#else
#    egrep -qi "timestamp_timeout=120" "$1"
#    if [ $? -eq 0 ]; then
#        echo "sudoers already updated"
#    else
#        echo "setting sudo timeout to 120 minutes"
#        sed -i.bak -e "s/mail_badpass/mail_badpass, timestamp_timeout=120/" "$1"
#    fi
#fi
