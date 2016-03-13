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

# --------------------------  AUTHORIZED SSH KEY (server)

set_authorized_key() {
   local client_alive=60
   local ssh_port=22

   pause "Press [Enter] to configure sshd service" true
   # make a copy of the original sshd config file
   sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.original
   # protect it from writing
   sudo chmod a-w /etc/ssh/sshd_config.original

   # client allive interval
   read -ep "Enter the client alive interval in seconds to prevent SSH from dropping out: " -i "60" client_alive
   read -ep "Enter the ssh port number to use on the server: " -i "22" ssh_port

   # edit /etc/ssh/sshd_config
   sudo sed -i.bak -e "{
      s/#Port 22/Port $ssh_port/
      s/#ClientAliveInterval 0/ClientAliveInterval $client_alive/
      }" /etc/ssh/sshd_config
   echo
   echo -e "SSH port set to $ssh_port\nclient alive interval set to $client_alive"

   # add authorized key for ssh user
   authorized_ssh_key $HOME/.ssh $(logname)

   # use ufw to limit login attempts too
   echo
   pause "Press [Enter] to configure ufw to limit ssh connection attempts..."
   sudo ufw limit ssh

   # disable root user access and limit login attempts
   echo
   pause "Press [Enter] to configure sshd security settings..."
   sudo sed -i -e "s/#PermitRootLogin yes|PermitRootLogin no/" \
               -e "s/PasswordAuthentication yes/PasswordAuthentication no/" \
               -e "s/#MaxStartups 10:30:60/MaxStartups 2:30:10/" \
               -e "/Banner \/etc\/issue.net/ s/^# //" /etc/ssh/sshd_config
   if grep -q "AllowUsers $(logname)" /etc/ssh/sshd_config; then
      echo "AllowUsers is already configured"
   else
      sudo printf "\nAllowUsers $(logname)" >> /etc/ssh/sshd_config && echo -e "\nroot login disallowed"
   fi

   echo
   pause "Press [Enter] to restart the ssh service..."
   sudo service ssh restart
}

# --------------------------  MAIN

[ "$IS_SERVER" -eq 0 ] && set_authorized_key || gen_ssh_key $HOME/.ssh $(logname)

