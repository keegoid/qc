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

# generate an RSA SSH keypair if none exists
gen_ssh_keys "/home/$USER_NAME/.ssh" "$SSH_KEY_COMMENT" $SSH $USER_NAME

echo
script_name "          done with "
echo "*********************************************"
