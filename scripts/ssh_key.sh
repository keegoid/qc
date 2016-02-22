#!/bin/bash
echo "# --------------------------------------------"
echo "# Generate an SSH key pair.                   "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Company: KM Authorized LLC                  "
echo "# Website: http://kmauthorized.com            "
echo "#                                             "
echo "# MIT: http://kma.mit-license.org             "
echo "# --------------------------------------------"

# generate an RSA SSH keypair if none exists
gen_ssh_keys "/home/$USER_NAME/.ssh" "$SSH_KEY_COMMENT" $SSH $USER_NAME

echo
script_name "          done with "
echo "*********************************************"
