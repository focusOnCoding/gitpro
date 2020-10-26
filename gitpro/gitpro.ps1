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


# remove a file and dont see it as an untracked file
rm FileName 
# then commit so the file is moved

# remove file from staging area
git rm --cached FileName 

# You can pass files, directories, and file-glob patterns to the git rm command. That means you can do things such as:
git rm log/\*.log
git rm \*~

# see what has happened with the file 
git log # to add patch an limit the returned number of commits -2
git log -p -2
# see abbreviated status for each commit using the --stat
git log --stat

<#Another really useful option is --pretty. This option changes the log output to formats other than
the default. A few prebuilt option values are available for you to use. The oneline value for this
option prints each commit on a single line, which is useful if you’re looking at a lot of commits. In
addition, the short, full, and fuller values show the output in roughly the same format but with
less or more information, respectively#>
git log --pretty=oneline

<#The most interesting option value is format, which allows you to specify your own log output
format. This is especially useful when you’re generating output for machine parsing — because you
specify the format explicitly, you know it won’t change with updates to Git:#>
git log --pretty=format:"%h - %an, %ar : %s"

# Graphical log
<#The oneline and format option values are particularly useful with another log option called --graph.
This option adds a nice little ASCII graph showing your branch and merge history:#>
git log --pretty=format:"%h %s" --graph

# However, the time-limiting options such as --since and --until are very useful. For example, this command gets the list of commits made in the last two weeks
git log --since=2.week

#REGEX
<#You can specify more than one instance of both the --author and --grep search
criteria, which will limit the commit output to commits that match any of the
--author patterns and any of the --grep patterns; however, adding the --all-match
option further limits the output to just those commits that match all --grep
patterns.
Another really helpful filter is the -S option (colloquially referred to as Git’s “pickaxe” option),
which takes a string and shows only those commits that changed the number of occurrences of that
string. For instance, if you wanted to find the last commit that added or removed a reference to a
specific function, you could call:
#>
git log -S function_name

<#The last really useful option to pass to git log as a filter is a path. If you specify a directory or file
name, you can limit the log output to commits that introduced a change to those files. This is always
the last option and is generally preceded by double dashes (--) to separate the paths from the
options:#>
git log -- path/to/file

# do not return merge files return all commits authered by Junio C hamano since ........ before ......
git log --pretty="%h - %s" --author='Junio C Hamano' --since="2008-10-01" \--before="2008-11-01" --no-merges -- t/

# undoing things
<#One of the common undos takes place when you commit too early and possibly forget to add some
files, or you mess up your commit message. If you want to redo that commit, make the additional
changes you forgot, stage them, and commit again using the --amend option:#>
git commit --amend
<#This command takes your staging area and uses it for the commit. If you’ve made no changes since
your last commit (for instance, you run this command immediately after your previous commit),
then your snapshot will look exactly the same, and all you’ll change is your commit message.#>

# the three stages to fix a commit 
git commit -m 'Initial commit'
git add forgotten_file
git commit --amend # You end up with a single commit — the second commit replaces the results of the first.

#ustaging a staged file
git reset HEAD fileName # --hard flag is an option
# a better way to do the above
git restore --staged FileName # now the file is unmodified

# unmodifying a modified file
# discard the changes iv made
git checkout --fileName #! dangerous command

<#If you would like to keep the changes you’ve made to that file but still need to get it out of the way
for now, we’ll go over stashing and branching in Git Branching; these are generally better ways to
go#>
git restore FileName #! Dangerous command







