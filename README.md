# Quick Config

Quickly configures a fresh install of [Ubuntu 16.04 64-bit][xx] on a workstation or server.

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

## What qc can do

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
- install [LXD][lxd], use it to download an [Ubuntu][xx] cloud image and create an [LXC][lxc] container
- install [ZFS][zfs] for use with [LXD][lxd]
- install [Juju][juju]

## Installation

Clone or download this repo.

```bash
git clone https://github.com/keegoid/qc.git
```

## Usage

Run the main program with `./qc.sh`
Optionally run `./sudoers.sh` if you want to increase the sudo timeout which is set to 15 minutes by default.

## License

SEE: http://keegoid.mit-license.org


[ubuntu]:   http://www.ubuntu.com/global
[xx]:       https://wiki.ubuntu.com/XenialXerus/ReleaseNotes
[lxd]:      https://linuxcontainers.org/lxd/introduction/
[lxc]:      https://linuxcontainers.org/lxc/introduction/
[zfs]:      https://wiki.ubuntu.com/ZFS
[juju]:     http://www.ubuntu.com/cloud/juju
[gedit]:    https://wiki.gnome.org/Apps/Gedit
[subl]:     https://www.sublimetext.com/
[vim]:      http://www.vim.org/
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
[aj]:       https://github.com/wting/autojump
[ssh]:      http://en.wikipedia.org/wiki/Secure_Shell
[sshkey]:   http://en.wikipedia.org/wiki/Ssh-keygen
[sa]:       http://en.wikipedia.org/wiki/Alias_%28command%29
[gh]:       https://github.com/
[git]:      https://git-scm.com/
[lp]:       https://lastpass.com/f?3202156
