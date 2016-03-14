#!/bin/bash
echo "# --------------------------------------------"
echo "# Install & configure WordPress in LXD        "
echo "# container.                                  "
echo "#                                             "
echo "# Author : Keegan Mullaney                    "
echo "# Website: http://keegoid.com                 "
echo "# Email  : keeganmullaney@gmail.com           "
echo "#                                             "
echo "# http://keegoid.mit-license.org              "
echo "# --------------------------------------------"

# --------------------------  SETUP PARAMETERS

# names and versions of repositories/software
SN=( NGINX   OPENSSL   ZLIB   PCRE   FRICKLE )
SV=( 1.9.9   1.0.2f    1.2.8  8.38   2.3     )

# URLs to check for latest versions
#   NGINX   nginx.org/download/
# OPENSSL   www.openssl.org/source/
#    ZLIB   zlib.net/
#    PCRE   http://ftp.csx.cam.ac.uk/pub/software/programming/pcre/
# FRICKLE   https://github.com/FRiCKLE/ngx_cache_purge/

[ -z "$REPOS" ] && read -ep "Directory to use for repositories: ~/" -i "Dropbox/Repos" REPOS

# GPG public keys

# --------------------------  HELPER FUNCTIONS

# set software versions
set_software_versions() {
    local swl="$1"
    local version
    echo
    for ((i=0; i<${#SN[@]}; i++)); do
        if echo $swl | grep -qw "${SN[i]}"; then
            read -ep "Enter software version for ${SN[i]}: " -i "${SV[i]}" version
            SV[i]="$version"
        fi
    done
}

# download and extract software
# $1 -> list of URLs to software (space-separated)
function get_software()
{
    local name
    cd /tmp
    for url in ${1}; do
        name=$(trim_longest_left_pattern $url "/")
        pause "Press enter to download and extract: $name"
        wget -nc "$url"
        tar -xzf "$name"
    done
    cd - >/dev/null
}

# --------------------------  MAIN

pause "" true

set_software_versions

# version variable assignments (determined by array order)
NGINX_V="${SV[0]}"
OPENSSL_V="${SV[1]}"
ZLIB_V="${SV[2]}"
PCRE_V="${SV[3]}"
FRICKLE_V="${SV[4]}"

# software download URLs
NGINX_URL="http://nginx.org/download/nginx-${NGINX_V}.tar.gz"
OPENSSL_URL="http://www.openssl.org/source/openssl-${OPENSSL_V}.tar.gz"
ZLIB_URL="http://zlib.net/zlib-${ZLIB_V}.tar.gz"
PCRE_URL="ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${PCRE_V}.tar.gz"
FRICKLE_URL="https://github.com/FRiCKLE/ngx_cache_purge/archive/master.zip"
WORDPRESS_URL="http://wordpress.org/latest.tar.gz"

get_software "$NGINX_URL $OPENSSL_URL $ZLIB_URL $PCRE_URL $FRICKLE_URL $WORDPRESS_URL"
