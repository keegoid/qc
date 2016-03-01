#!/bin/bash
# --------------------------------------------
# A library of useful git functions
#
# Author : Keegan Mullaney
# Website: http://keegoid.com
# Email  : keeganmullaney@gmail.com
#
# http://keegoid.mit-license.org
# --------------------------------------------

# purpose: to set global git defaults
# arguments:
#   $1 -> code author's name
#   $2 -> code author's email
#   $3 -> editor to use for git
configure_git()
{
   local name="$1"
   local email="$2"
   local editor="$3"

   # specify a user
   git config --global user.name "$name"
   git config --global user.email "$email"
   # select a text editor
   git config --global core.editor "$editor"
   # set default push and pull behavior to the old method
   git config --global push.default matching
   git config --global pull.default matching
   # create a global .gitignore file
   git config --global core.excludesfile "$HOME/.gitignore_global"
   echo "git was configured"
   read -p "Press [Enter] to view the config..."
   git config --list
}

# purpose: clone repository after fork
# arguments:
#   $1 -> GitHub username
#   $2 -> name of upstream repository
#   $3 -> location of Repos directory
#   $4 -> use SSH protocal for git operations? (optional)
clone_repo()
{
   local github_user="$1"
   local address="${github_user}/$2.git"
   local repos_dir="$3"
   local use_ssh=$4

   [ -z "${use_ssh}" ] && use_ssh=false

   if [ -d "${repos_dir}/${2}" ]; then
      echo
      echo "${2} directory already exists, skipping clone operation..."
   else
      echo
      echo "*** NOTE ***"
      echo "Make sure \"github.com/${address}\" exists."
      read -p "Press [Enter] to clone ${address} at GitHub..."
      if [ "$use_ssh" = true ]; then
         git clone "git@github.com:${address}"
      else
         git clone "https://github.com/${address}"
      fi
   fi

   # change to newly cloned directory
   cd "${2}"
   echo "changing directory to $_"
}

# purpose: set remote origin, if not set yet
# arguments:
#   $1 -> GitHub username
#   $2 -> name of origin repository
#   $3 -> set remote upstream or origin (true for upstream)
#   $4 -> use SSH protocal for git operations? (optional)
# return: false if no upstream repo
set_remote_repo()
{
   local github_user="$1"
   local address="${github_user}/$2.git"
   local set_upstream=$3
   local use_ssh=$4

   [ -z "${use_ssh}" ] && use_ssh=false
   
   if [ "${set_upstream}" = true ] && [ "${github_user}" = 'keegoid' ]; then
#      echo "upstream doesn't exist for $github_user, skipping..."
      echo false
   fi

   if git config --list | grep -q "${address}"; then
      echo
      echo "remote repo already configured: ${address}"
   else
      echo
      if [ "$set_upstream" = true ]; then
         read -p "Press [Enter] to assign upstream repository..."
         if [ "$use_ssh" = true ]; then
            git remote add upstream "git@github.com:${address}" && echo "remote upstream added: git@github.com:${address}"
         else
            git remote add upstream "https://github.com/${address}" && echo "remote upstream added: https://github.com/${address}"
         fi
      else
         echo "*** NOTE ***"
         echo "Make sure \"github.com/${address}\" exists."
         echo "Either fork and rename it, or create a new repository in your GitHub."
         read -p "Press [Enter] to assign remote origin repository..."
         if [ "$use_ssh" = true ]; then
            git remote add origin "git@github.com:${address}" && echo "remote origin added: git@github.com:${address}"
         else
            git remote add origin "https://github.com/${address}" && echo "remote origin added: https://github.com/${address}"
         fi
      fi
   fi
}

# purpose: create a branch for custom changes so master can receive upstream updates
#          upstream changes can then be merged with the branch interactively
# arguments:
#   $1 -> branch name
create_branch()
{
   local branch_name="$1"
   
   echo
   read -p "Press [Enter] to create a git branch for your site at ${branch_name}..."
   git checkout -b "${branch_name}"

   # some work and some commits happen
   # some time passes
   #git fetch upstream
   #git rebase upstream/master or git rebase interactive upstream/master

   echo
   read -p "Press [Enter] to push changes and set branch origin in config..."
   git push -u origin "${branch_name}"

   echo
   read -p "Press [Enter] to checkout the master branch again..."
   git checkout master

   # above could also be done with:
   # git branch "${branch_name}"
   # git push origin "${branch_name}"
   # git branch -u "origin/${branch_name}" "${branch_name}"

   echo
   echo "*************************************************************************"
   echo "* - use ${branch_name} branch to make your own site                      "
   echo "* - use master branch to keep up with changes from the upstream repo     "
   echo "*************************************************************************"
}

# purpose: add remote upstream repository, fetch and merge changes
# arguments: none
merge_upstream()
{
   # pull in changes not present in local repository, without modifying local files
   echo
   read -p "Press [Enter] to fetch changes from upstream repository..."
   git fetch upstream && echo "upstream fetch done"

   # merge any changes fetched into local working files
   echo
   echo "*** NOTE ***"
   echo "If merging changes, press \":wq enter\" to accept the merge message in vi."
   read -p "Press [Enter] to merge changes..."
   git merge upstream/master

   # or combine fetch and merge with:
   #git pull upstream master
}

# purpose: commit and push changes with git
# arguments: none
#commit_and_push()
#{
#   local commit=false

#   commit=$(git_status)

#   echo "commit = $commit"

   # push commits to your remote repository
#   if $commit || git status | grep -qw "Your branch is ahead of"; then
#      echo
#      read -p "Press [Enter] to push changes to your remote repository (GitHub)..."
#      git push origin master
#   else
#      echo "nothing to push, skipping push..."
#   fi
#}

