#!/bin/bash
echo "# --------------------------------------------"
echo "# Generate an SSH key pair.                   "
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

if [ "$IS_SERVER" = true ]; then
   # make a copy of the original sshd config file
   sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original
   # protect it from writing
   sudo chmod a-w /etc/ssh/sshd_config.original

   # client allive interval
   CLIENT_ALIVE=60
   SSH_PORT=22
   read -ep "Enter the client alive interval in seconds to prevent SSH from dropping out: " -i "60" CLIENT_ALIVE
   read -ep "Enter the ssh port number to use on the server: " -i "22" SSH_PORT

   # edit /etc/ssh/sshd_config
   echo
   pause "Press enter to configure sshd service..."
   sudo sed -i.bak -e "{
      s|#Port 22|Port $SSH_PORT|
      s|#ClientAliveInterval 0|ClientAliveInterval $CLIENT_ALIVE|
      }" /etc/ssh/sshd_config
   echo
   echo -e "SSH port set to $SSH_PORT\nclient alive interval set to $CLIENT_ALIVE"

   # add public SSH key for new ssh user
   SSH_DIRECTORY="/home/$USER_NAME/.ssh"

   # generate SSH keypair
#   gen_ssh_keys $SSH_DIRECTORY "$SSH_COMMENT" true $USER_NAME

   # add authorized key for ssh user
   authorized_ssh_keys $SSH_DIRECTORY $USER_NAME

   # use ufw to limit login attempts too
   echo
   pause "Press enter to configure ufw to limit ssh connection attempts..."
   sudo ufw limit ssh

   # disable root user access and limit login attempts
   echo
   pause "Press enter to configure sshd security settings..."
   sudo sed -i -e "s|#PermitRootLogin yes|PermitRootLogin no|" \
               -e "s|PasswordAuthentication yes|PasswordAuthentication no|" \
               -e "s|#MaxStartups 10:30:60|MaxStartups 2:30:10|" \
               -e "s|#Banner /etc/issue.net|Banner /etc/issue.net|" /etc/ssh/sshd_config
   if grep -q "AllowUsers $USER_NAME" /etc/ssh/sshd_config; then
      echo "AllowUsers is already configured"
   else
      sudo printf "\nAllowUsers $USER_NAME" >> /etc/ssh/sshd_config && echo -e "\nroot login disallowed"
   fi

   echo
   pause "Press enter to restart the ssh service..."
   sudo service ssh restart
else
   # generate an RSA SSH keypair if none exists
   gen_ssh_keys "/home/$USER_NAME/.ssh" "$SSH_KEY_COMMENT" true $USER_NAME
fi

