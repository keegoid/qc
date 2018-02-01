# Quick Config

Quickly configures a fresh install of [Ubuntu 17.10 64-bit][aa] on a workstation.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [What qc can do](#what-qc-can-do)
- [Installation](#installation)
- [Usage](#usage)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## What qc can do

- update [Ubuntu][ubuntu] and install some useful packages
- setup standard developement environment utilizing package managers: [rbenv][rbenv], [nvm][nvm], [virtualenv][venv]
- install gem, npm, and pip packages using appropriate package managers
- generate an [RSA key][sshkey] for remote [SSH sessions][ssh]
- make the [terminal][gt] easier to read and use with:
    - colored prompt string (PS1)
    - [autojump][aj]
    - [incremental history searching][ihs]
- add [solarized][msolar] color scheme to [Mutt][mutt]
- install and configure [vim-gtk][vim]
- install and configure [Sublime Text 3][subl]
- install [Keybase][keyb]
- configure [git][git] global settings
- fix ownership issues in Home directory (warning: dangerous command, run at your own risk)

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
[aa]:       https://wiki.ubuntu.com/ArtfulAardvark/ReleaseNotes
[subl]:     https://www.sublimetext.com/
[vim]:      http://www.vim.org/
[gt]:       http://manpages.ubuntu.com/manpages/hardy/man1/gnome-terminal.1.html
[ihs]:      https://help.ubuntu.com/community/UsingTheTerminal#An_extremely_handy_tool_::_Incremental_history_searching
[msolar]:   https://github.com/altercation/mutt-colors-solarized
[bb]:       https://github.com/afair/dot-gedit
[mutt]:     http://www.mutt.org/
[keyb]:     https://keybase.io/
[aj]:       https://github.com/wting/autojump
[ssh]:      http://en.wikipedia.org/wiki/Secure_Shell
[sshkey]:   http://en.wikipedia.org/wiki/Ssh-keygen
[gh]:       https://github.com/
[git]:      https://git-scm.com/
[lp]:       https://lastpass.com/f?3202156
[rbenv]:    https://github.com/rbenv/rbenv
[nvm]:      https://github.com/creationix/nvm
[venv]:     https://github.com/pypa/virtualenv
