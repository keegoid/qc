ubuntu-workstation-setup
========================

Quickly configures a fresh install of [Ubuntu 14.04 x64][ubuntu] for a workstation.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*
<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## What it can do

- update Ubuntu and install useful programs
- configure [git][git] for pushing and pulling with [GitHub][gh]
- generate an [RSA key][sshkey] for remote [SSH sessions][ssh] if none exists (note: this is not a [GPG key][gpgkey])
- add some [shell aliases][sa]
- configure some terminal settings

## Usage

### Clone or download this project

- HTTPS: `git clone https://github.com/keegoid/config-ubuntu-workstation.git`
- SSH: `git clone git@github.com:keegoid/config-ubuntu-workstation.git`

### Set variables for run.sh script

Open **vars.sh** with your favorite text editor and **edit the input variables** at the top to reflect your information.

### Run run.sh

```bash
sudo chmod +x run.sh
sudo dos2unix -k run.sh
sudo ./run.sh
```

## SSH Keys

You can save a backup copy of your [SSH key pair][sshkey] that gets generated and output to the screen. I prefer saving it as a secure note in [LastPass][lp]. Copy the keys from the [Linux console][lc] with `ctrl+shift+c` before clearing the screen.

```bash
cat ~/.ssh/id_rsa.pub
cat ~/.ssh/id_rsa
clear
```

## License

SEE: http://keegoid.mit-license.org


[ubuntu]:   http://www.ubuntu.com/global
[lc]:       http://en.wikipedia.org/wiki/Linux_console
[lp]:       https://lastpass.com/f?3202156
[ss]:       http://en.wikipedia.org/wiki/Shell_script
[ssh]:      http://en.wikipedia.org/wiki/Secure_Shell
[sshkey]:   http://en.wikipedia.org/wiki/Ssh-keygen
[gpgkey]:   http://en.wikipedia.org/wiki/GNU_Privacy_Guard
[sa]:       http://en.wikipedia.org/wiki/Alias_%28command%29
[gh]:       https://github.com/
[git]:      https://git-scm.com/
[twitter]:  https://twitter.com/intent/tweet?screen_name=keegoid&text=loving%20your%20CentOS%207.0%20deploy%20scripts%20for%20%40middlemanapp%20or%20%40WordPress%20with%20%40nginxorg%20https%3A%2F%2Fgithub.com%2Fkeegoid%2Flinux-deploy-scripts
