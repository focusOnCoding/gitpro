# open explore in the terminal 
. start

# To set main as the default branch name do
git config --global init.defaultBranch main

# check my git settings
git config --list

# git help 
git help <verb>
git <verb> --help
man git-<verb>

# simple help manue
git add -h

# after git init i wnat to add the files i want to track or stagte it
git add filename1
git add filEname2
git add filename3 # If you modify a file after you run git add, you have to run git add again to stage the
#latest version of the file

# Cloning an Existing Repository
git clone http://github.com/focusoncoding/learingGit

# give a cloned repo a deferant name
git clone http://github.com/focusoncoding/learingGit codeFileName

# check the status of my files which stage the file is in
# Unmodified
# Modified
# Staged
git status
git status -s # showless information

# create ignore files
cat .gitingnore
.[oa]
*~
# ignore all .a files
*.a
# but do track lib.a, even though you're ignoring .a files above
!lib.a
# only ignore the TODO file in the current directory, not subdir/TODO
/TODO
# ignore all files in any directory named build
build/
# ignore doc/notes.txt, but not doc/server/arch.txt
doc/*.txt
# ignore all .pdf files in the doc/ directory and any of its subdirectories
doc/**/*.pdf

# you want to know exactly what you changed, not just which files were changed — you can use the 
git diff # see all unstaged changes

#  git diff --cached to see what you’ve staged so far
git diff --cached

# Run git difftool --tool-help to see what is available on your system
git difftool --tool-help

# then i can commit or set a check point if all is well
git commit -m "message"

# Adding the -a option to the git commit command makes Git automatically stage every file that is already tracked before doing the commit, letting you skip
# the git add part:
git commit -a -m "masseg"

# remove a file
git rm

# remove a staged file
git rm --cached fileName

# You can pass files, directories, and file-glob patterns to the git rm command. That means you can do things such as:
git rm log/\*.log
#  This command removes all files that have the .log extension in the log/ directory

# rename a file
git mv file_from file_to

# see what has happened with the file 
git log
# PAGE 39