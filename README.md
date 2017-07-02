# Quick Config

Quickly configures a fresh install of [Ubuntu 17.04 64-bit][zz] on a workstation.

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

- update [Ubuntu][ubuntu] and install some programs using apt-get, gem, npm, and pip
- generate an [RSA key][sshkey] for remote [SSH sessions][ssh]
- add useful [shell aliases][sa]
- make the [terminal][gt] easier to read and use with:
    - colored prompts
    - dark profile
    - [autojump][aj]
    - [incremental history searching][ihs]
- add [solarized][msolar] color scheme to [Mutt][mutt]
- install and configure [vim-gtk][vim]
- install and configure [Visual Studio Code][code]
- configure [git][git] global settings

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
[zz]:       https://wiki.ubuntu.com/ZestyZapus/ReleaseNotes
[code]:     https://code.visualstudio.com/
[vim]:      http://www.vim.org/
[gt]:       http://manpages.ubuntu.com/manpages/hardy/man1/gnome-terminal.1.html
[ihs]:      https://help.ubuntu.com/community/UsingTheTerminal#An_extremely_handy_tool_::_Incremental_history_searching
[msolar]:   https://github.com/altercation/mutt-colors-solarized
[bb]:       https://github.com/afair/dot-gedit
[mutt]:     http://www.mutt.org/
[aj]:       https://github.com/wting/autojump
[ssh]:      http://en.wikipedia.org/wiki/Secure_Shell
[sshkey]:   http://en.wikipedia.org/wiki/Ssh-keygen
[sa]:       http://en.wikipedia.org/wiki/Alias_%28command%29
[gh]:       https://github.com/
[git]:      https://git-scm.com/
[lp]:       https://lastpass.com/f?3202156
