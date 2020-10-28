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

# show my remotes
git clone https://github.com/focusOnCoding/markdown-portfolio.git

# show the URL of my clone
git remote -v 

# adding remote repositories
git remote add <shortname> <url>

<# Now you can use the string pb on the command line in lieu of the whole URL. For example, if you
want to fetch all the information that Paul has but that you don’t yet have in your repository, you
can run git fetch pb#> 
git fetch ph # ph is an aliase that i created above

# PULLING FROM A REMOTE REPO
git fetch <remote> # now i have  references to all the branches from that remote

<#If your current branch is set up to track a remote branch (see the next section and Git Branching for
more information), you can use the git pull command to automatically fetch and then merge that
remote branch into your current branch. This may be an easier or more comfortable workflow for
you; and by default, the git clone command automatically sets up your local master branch to track
the remote master branch (or whatever the default branch is called) on the server you cloned from.
Running git pull generally fetches data from the server you originally cloned from and
automatically tries to merge it into the code you’re currently working on.

From git version 2.27 onward, git pull will give a warning if the pull.rebase
variable is not set. Git will keep warning you until you set the variable.
If you want the default behavior of git (fast-forward if possible, else create a merge
commit): git config --global pull.rebase "false"
If you want to rebase when pulling: git config --global pull.rebase "true"
#>

# Pushing to a remote repo
git push <remote> <branch>
git push origin master # If you want to push your master branch to your origin server

# inspecting a remote
git remote show origin

# Renaming and removing remotes
git remote rename pb paul

# remove a remote
git remote remove paul

# tagging
git tag # list tags
git tag -l "v1.8.5" #You can also search for tags that match a particular pattern

# creating annotated tags
# Creating an annotated tag in Git is simple. The easiest way is to specify -a when you run the tag command:
git tag -a v1.4 -m "my version 1.4"
# see the tag i just created
git show v1.4

# To create a lightweight tag, don’t supply any of the -a, -s, or -m options, just provide a tag name:
git tag v1.4-lw # This time, if you run git show on the tag, you don’t see the extra tag information. The command just shows the commit:

# tagging later after i have commited
git log --pretty=oneline # so i can see the id of the commit i want to use
git tag -a v1.2 9fcebo2 #id = 9fcebo2

# sharing tags
git push origin <tagname> # If you have a lot of tags that you want to push up at once, you can also use the --tags

# deleting tags
git tag -d v1.4-lw

# Note that this does not remove the tag from any remote servers. There are two common variations for deleting a tag from a remote server.
git push origin :refs/tags/v1.4-lw

# The second (and more intuitive) way to delete a remote tag is with:
git push origin --delete <tagname>

# Checking out Tags
# If you want to view the versions of files a tag is pointing to
git checkout v2.0.0 # detached HEAD” state, if you make changes and then create a commit, the tag will stay the same, but your new commit won’t belong to any branch and will be unreachable

# say you’re fixing a bug on an older version, for instance — you will generally want to create a branch:
git checkout -b version2 v2.0.0

# ALIASES
# setting up aliases using git config
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status

<# this technique can also be very useful in creating commands that you think should exist. For
example, to correct the usability problem you encountered with unstaging a file, you can add your
own unstage alias to Git:#>
git config --global alias.unstage 'reset HEAD --'

# This makes the following two commands equivalent:
git unstage fileA
git reset HEAD -- fileA

# This seems a bit clearer. It’s also common to add a last command, like this:
git config --global alias.last 'log -1 HEAD'
git last

<# As you can tell, Git simply replaces the new command with whatever you alias it for. However,
maybe you want to run an external command, rather than a Git subcommand. In that case, you
start the command with a ! character. This is useful if you write your own tools that work with a
Git repository. We can demonstrate by aliasing git visual to run gitk:#>
git config --global alias.visual '!gitk'

# creating a new branch
git branch branch1 #  In Git, this is a pointer to the local branch you’re currently on. In this case,
# you’re still on master. The git branch command only created a new branch — it didn’t switch to that

# You can easily see this by running a simple git log command that shows you where the branch
# pointers are pointing. This option is called --decorate.
git log --oneline --decorate # see all my old commits in short notation

# switching branches
# To switch to an existing branch, you run the git checkout command. Let’s switch to the new testing branch:
git checkout testing

# show all branchs
git log --all

#facts
<#Now your project history has diverged (see Divergent history). You created and switched to a
branch, did some work on it, and then switched back to your main branch and did other work. Both
of those changes are isolated in separate branches: you can switch back and forth between the
branches and merge them together when you’re ready. And you did all that with simple branch,
checkout, and commit commands#>

#  it will print out the history of your commits, showing where your branch pointers are and how your history has diverged.
git log --oneline --decorate --graph --all

# It’s typical to create a new branch and want to switch to that new branch at the same time — this can be done in one operation with 
git checkout -b <newbranchname>
# or
# Switch to an existing branch: 
git switch testing-branch
# Create a new branch and switch to it: git switch -c new-branch. The -c flag
#stands for create, you can also use the full flag: --create
git switch -c new-branch
# Return to your previously checked out branch: 
git switch -

# branching and mergeing
<#You’ve decided that you’re going to work on issue #53 in whatever issue-tracking system your
company uses. To create a new branch and switch to it at the same time, you can run the git
checkout command with the -b switch:#>
git checkout -b iss53 #Switched to a new branch "iss53"
# This is shorthand for:
git branch iss53
git checkout iss53 # page 73

# FACT
<# At this point, your project working directory is exactly the way it was before you started working
on issue #53, and you can concentrate on your hotfix. This is an important point to remember:
when you switch branches, Git resets your working directory to look like it did the last time you
committed on that branch. It adds, removes, and modifies files automatically to make sure your
working copy is what the branch looked like on your last commit to it.
#>

# You can run your tests, make sure the hotfix is what you want, and finally merge the hotfix branch back into your master branch to deploy to production. You do this with the git merge command:
git checkout master
git merge hotfix # this hotfix branch was created  on the master branch page 75

<# After your super-important fix is deployed, you’re ready to switch back to the work you were doing
before you were interrupted. However, first you’ll delete the hotfix branch, because you no longer
need it — the master branch points at the same place. You can delete it with the -d option to git
branch:#>
git branch -d hotfix
Deleted branch hotfix (3a0874c)

# Now you can switch back to your work-in-progress branch on issue #53 and continue working on it.
git checkout iss53 # Now that your work is merged in, you have no further need for the branch
Switched to branch "iss53"

<# Basic MergingSuppose you’ve decided that your issue #53 work is complete and ready to be merged into your
master branch. In order to do that, you’ll merge your iss53 branch into master, much like you
merged your hotfix branch earlier. All you have to do is check out the branch you wish to merge
into and then run the git merge command:#>
git checkout master
Switched to branch 'master'
git merge iss53
Merge made by the 'recursive' strategy

# page 77 Merge Conflicts
# If you want to use a graphical tool to resolve these issues, you can run 
git mergetool

<#The git branch command does more than just create and delete branches. If you run it with no
arguments, you get a simple listing of your current branches:#>
git branch

# To see the last commit on each branch, you can run 
git branch -v

<# The useful --merged and --no-merged options can filter this list to branches that you have or have not
yet merged into the branch you’re currently on. To see which branches are already merged into the
branch you’re on, you can run git branch --merged:#>
git branch --merged

# To see all the branches that contain work you haven’t yet merged in, you can run git branch --no -merged:
git branch --no-merged

# This shows your other branch. Because it contains work that isn’t merged in yet, trying to delete it with git branch -d will fail:
git branch -d testing

<# You can always provide an additional argument to ask about the merge state with
respect to some other branch without checking that other branch out first, as in,
what is not merged into the master branch?#>
git checkout testing
git branch --no-merged master

# Changing a branch name
# Rename the branch locally with the git branch --move command:
git branch --move bad-branch-name corrected-branch-name
# This replaces your bad-branch-name with corrected-branch-name, but this change is only local for
# now. To let others see the corrected branch on the remote, push it:
git push --set-upstream origin corrected-branch-name
#Now we’ll take a brief look at where we are now:
git branch --all

# Notice that you’re on the branch corrected-branch-name. The corrected branch is available on the
# remote. However the bad branch is also still present on the remote. You can delete the bad branch from the remote:
git push origin --delete bad-branch-name # Now the bad branch name is fully replaced with the corrected branch name

# Rename your local master branch into main with the following command
git branch --move master main

# There’s no master branch locally anymore, because it’s renamed to the main branch. To let others see the new main branch, you need to push it to the remote. This makes the renamed
# branch available on the remote.
git push --set-upstream origin main

# page 83 changing the master to a new name #! very dangerous

# Branching Workflows
<#Long-Running Branches
Because Git uses a simple three-way merge, merging from one branch into another multiple times
over a long period is generally easy to do. This means you can have several branches that are
always open and that you use for different stages of your development cycle; you can merge
regularly from some of them into others.#>

<# Topic Branches
Topic branches, however, are useful in projects of any size. A topic branch is a short-lived branch
that you create and use for a single particular feature or related work. This is something you’ve
likely never done with a VCS before because it’s generally too expensive to create and merge
branches. But in Git it’s common to create, work on, merge, and delete branches several times a day#>

<#Consider an example of doing some work (on master), branching off for an issue (iss91), working on
it for a bit, branching off the second branch to try another way of handling the same thing (
iss91v2), going back to your master branch and working there for a while, and then branching off
there to do some work that you’re not sure is a good idea (dumbidea branch). Your commit history
will look something like this:
#>

<# Remote Branches
Remote references are references (pointers) in your remote repositories, including branches, tags,
and so on. You can get a full list of remote references explicitly with  for remote branches as well as more information. Nevertheless, a more
common way is to take advantage of remote-tracking branches.
#>
git ls-remote remote
git remote show remote

# Bookmarks Remote-tracking state
# Naming and getting remote branchs and updates
<#Remote-tracking branch names take the form <remote>/<branch>. For instance, if you wanted to see
what the master branch on your origin remote looked like as of the last time you communicated
with it, you would check the origin/master branch. If you were working on an issue with a partner
and they pushed up an iss53 branch, you might have your own local iss53 branch, but the branch
on the server would be represented by the remote-tracking branch origin/iss53.#>

<# If you do some work on your local master branch, and, in the meantime, someone else pushes to
git.ourcompany.com and updates its master branch, then your histories move forward differently.
Also, as long as you stay out of contact with your origin server, your origin/master pointer doesn’t
move.#>

<# To synchronize your work with a given remote, you run a git fetch <remote> command (in our
case, git fetch origin). This command looks up which server “origin” is (in this case, it’s
git.ourcompany.com), fetches any data from it that you don’t yet have, and updates your local
database, moving your origin/master pointer to its new, more up-to-date position.#>