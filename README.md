quick-config
============

Quickly configures a fresh install of [Ubuntu 14.04 64-bit][tt] on a workstation or server.

*(The server part is a work in progress...)*

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [What it can do](#what-it-can-do)
- [Usage](#usage)
  - [Clone or download this project](#clone-or-download-this-project)
  - [Run it](#run-it)
- [SSH Keys](#ssh-keys)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## What it can do

- update [Ubuntu][ubuntu] and install some programs using apt-get, gem, npm and pip
- generate an [RSA key][sshkey] for remote [SSH sessions][ssh]
- add useful [shell aliases][sa]
- make the [terminal][gt] easier to read and use with:
    - colored prompts
    - dark profile
    - [autojump][aj]
    - [incremental history searching][ihs]
- add [blackboard][bb] and [solarized][gsolar] color schemes to [gedit][gedit]
- add [solarized][msolar] color scheme to [Mutt][mutt]
- configure [tmux][tmux]
- install and configure [vim-gtk][vim]
- install and configure [Sublime Text][subl], it really is sublime for coding
- configure [git][git] global settings
- install the latest [VirtualBox][vb] and [Vagrant][vg]
- install [LXD][lxd], create an [Alpine Linux][alpine] image and use it to create an [LXC][lxc] container for [WordPress][wp]
- in [LXC][lxc] container, install [WordPress][wp] dependencies, build [NGINX][ngx] from source and configure [WordPress][wp] with [fast_cgi_cache][fcgi] purge.

## Usage

### Clone or download this project

- HTTPS: `git clone https://github.com/keegoid/quick-config.git`
- SSH: `git clone git@github.com:keegoid/quick-config.git`

### Run it

Run the main program with `./run.sh`

If it doesn't work, you might need to do this:

```bash
chmod +x run.sh
dos2unix -k run.sh
```

Also run `./sudoers.sh` if you want to increase the sudo timeout which is set to 15 minutes by default.

## SSH Keys

You can save a backup copy of your [SSH key pair][sshkey] that gets generated and output to the screen. I prefer saving it as a secure note in [LastPass][lp]. Copy the keys from the [terminal][gt] with `ctrl+shift+c` before clearing the screen.

```bash
cat ~/.ssh/id_rsa.pub
cat ~/.ssh/id_rsa
clear
```

## License

SEE: http://keegoid.mit-license.org


[ubuntu]:   http://www.ubuntu.com/global
[lxd]:      https://linuxcontainers.org/lxd/introduction/
[lxc]:      https://linuxcontainers.org/lxc/introduction/
[alpine]:   http://alpinelinux.org/
[gedit]:    https://wiki.gnome.org/Apps/Gedit
[subl]:     https://www.sublimetext.com/
[vim]:      http://www.vim.org/
[tt]:       https://wiki.ubuntu.com/TrustyTahr/ReleaseNotes
[gt]:       http://manpages.ubuntu.com/manpages/hardy/man1/gnome-terminal.1.html
[ihs]:      https://help.ubuntu.com/community/UsingTheTerminal#An_extremely_handy_tool_::_Incremental_history_searching
[tsolar]:   https://github.com/Anthony25/gnome-terminal-colors-solarized
[gsolar]:   https://github.com/mattcan/solarized-gedit
[msolar]:   https://github.com/altercation/mutt-colors-solarized
[bb]:       https://github.com/afair/dot-gedit
[tmux]:     https://tmux.github.io/
[mutt]:     http://www.mutt.org/
[vb]:       https://www.virtualbox.org/
[vg]:       https://www.vagrantup.com/
[ngx]:      http://nginx.org/
[fcgi]:     https://github.com/FRiCKLE/ngx_cache_purge
[aj]:       https://github.com/wting/autojump
[wp]:       https://wordpress.org/
[ssh]:      http://en.wikipedia.org/wiki/Secure_Shell
[sshkey]:   http://en.wikipedia.org/wiki/Ssh-keygen
[sa]:       http://en.wikipedia.org/wiki/Alias_%28command%29
[gh]:       https://github.com/
[git]:      https://git-scm.com/
[lp]:       https://lastpass.com/f?3202156
