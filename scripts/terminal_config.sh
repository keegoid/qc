#!/bin/bash
echo "# --------------------------------------------"
echo "# Configure some terminal settings.           "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# color terminal prompts
if grep -q "#force_color_prompt=yes" /home/$USER_NAME/.bashrc; then
   echo "adding color to terminal prompts"
   sed -i.bak -e "s/#force_color_prompt=yes/force_color_prompt=yes/"
else
   echo "already set color prompts for $USER_NAME..."
fi

# terminal history lookup
pause "Press enter to add terminal history lookup for $USER_NAME..."
if grep -q "backward-char" /home/$USER_NAME/.inputrc; then
   echo "already added terminal history lookup for $USER_NAME..."
else
   # terminal input config file
   cat << 'EOF' >> /home/$USER_NAME/.inputrc
# shell command history lookup by matching string
"\e[A": history-search-backward
"\e[B": history-search-forward
"\e[C": forward-char
"\e[D": backward-char
EOF
echo "/home/$USER_NAME/.inputrc was created with:"
cat "/home/$USER_NAME/.inputrc"

# proxy for terminal traffic
PROXY=false
echo
echo "Do you wish to use a proxy for terminal operations?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") PROXY=true;;
       "No") break;;
          *) echo "case not found, try again..."
             continue;;
   esac
   break
done

if [ "$PROXY" = true ]; then
   # set proxy address and port in .bashrc
   if grep -q "http_proxy" /home/$USER_NAME/.bashrc; then
      echo "already set proxy for $USER_NAME..."
   else
      # check if trying to use lantern proxy without lantern installed
      if [ -n "$(hash lantern)" ] && [ "$PROXY_ADDRESS" = '127.0.0.1:8787' ]; then
         echo "error: Lantern is not installed, skipping proxy..."
         echo "download Lantern from getlantern.org and run this script again"
      else
         echo "setting http_proxy var"
         echo "http_proxy=http://\'$PROXY_ADDRESS\'" >> /home/$USER_NAME/.bashrc
      fi
   fi
else
   echo
   echo "skipping proxy..."
fi

echo
script_name "          done with "
echo "*********************************************"
