<# 
Here’s an example. Suppose you’re developing a website and creating Atom feeds. Instead of
writing your own Atom-generating code, you decide to use a library. You’re likely to have to either
include this code from a shared library like a CPAN install or Ruby gem, or copy the source code
into your own project tree. The issue with including the library is that it’s difficult to customize the
library in any way and often more difficult to deploy it, because you need to make sure every client
has that library available. The issue with copying the code into your own project is that any custom
changes you make are difficult to merge when upstream changes become available.
#>
<# Starting with Submodules
We’ll walk through developing a simple project that has been split up into a main project and a few
sub-projects.
Let’s start by adding an existing Git repository as a submodule of the repository that we’re working
on. To add a new submodule you use the git submodule add command with the absolute or relative
URL of the project you would like to start tracking. In this example, we’ll add a library called
DbConnector.#>
git submodule add https://github.com/chaconinc/DbConnector

<# By default, submodules will add the subproject into a directory named the same as the repository,
in this case “DbConnector”. You can add a different path at the end of the command if you want it
to go elsewhere.
If you run git status at this point, you’ll notice a few things.
#>
git status
<# First you should notice the new .gitmodules file. This is a configuration file that stores the mapping
between the project’s URL and the local subdirectory you’ve pulled it into:
#>
<#The other listing in the git status output is the project folder entry. If you run git diff on that, you
see something interesting:
#>
git diff --cached DbConnector

<# Although DbConnector is a subdirectory in your working directory, Git sees it as a submodule and
doesn’t track its contents when you’re not in that directory. Instead, Git sees it as a particular
commit from that repository.
If you want a little nicer diff output, you can pass the --submodule option to git diff.
#>
git diff --cached --submodule

<#When you commit, you see something like this:
$ git commit -am 'Add DbConnector module'
[master fb9093c] Add DbConnector module
Notice the 160000 mode for the DbConnector entry. That is a special mode in Git that basically means
you’re recording a commit as a directory entry rather than a subdirectory or a file.
#>

<# Cloning a Project with Submodules
Here we’ll clone a project with a submodule in it. When you clone such a project, by default you get
the directories that contain submodules, but none of the files within them yet:
#>
git clone https://github.com/chaconinc/MainProject
<# 
$ cd DbConnector/
$ ls
#>
<# The DbConnector directory is there, but empty. You must run two commands: git submodule init to
initialize your local configuration file, and git submodule update to fetch all the data from that
project and check out the appropriate commit listed in your superproject:
#>
git submodule init
git submodule update
# Now your DbConnector subdirectory is at the exact state it was in when you committed earlier.

<# 
There is another way to do this which is a little simpler, however. If you pass --recurse-submodules
to the git clone command, it will automatically initialize and update each submodule in the
repository, including nested submodules if any of the submodules in the repository have
submodules themselves.
#>
git clone --recurse-submodules https://github.com/chaconinc/MainProject
<# If you already cloned the project and forgot --recurse-submodules, you can combine the git
submodule init and git submodule update steps by running git submodule update --init. To also
initialize, fetch and checkout any nested submodules, you can use the foolproof git submodule
update --init --recursive.
#>

<# Pulling in Upstream Changes from the Submodule Remote
The simplest model of using submodules in a project would be if you were simply consuming a
subproject and wanted to get updates from it from time to time but were not actually modifying
anything in your checkout. Let’s walk through a simple example there.
If you want to check for new work in a submodule, you can go into the directory and run git fetch
and git merge the upstream branch to update the local code.
#>
git fetch
git merge origin/master

<# Now if you go back into the main project and run git diff --submodule you can see that the
submodule was updated and get a list of commits that were added to it. If you don’t want to type
--submodule every time you run git diff, you can set it as the default format by setting the
diff.submodule config value to “log”.
#>
git config --global diff.submodule log
git diff

<# There is an easier way to do this as well, if you prefer to not manually fetch and merge in the
subdirectory. If you run git submodule update --remote, Git will go into your submodules and fetch
and update for you.
#>
git submodule update --remote DbConnector

<# This command will by default assume that you want to update the checkout to the master branch of
the submodule repository. You can, however, set this to something different if you want. For
example, if you want to have the DbConnector submodule track that repository’s “stable” branch,
you can set it in either your .gitmodules file (so everyone else also tracks it), or just in your local
.git/config file. Let’s set it in the .gitmodules file:
#>
git config -f .gitmodules submodule.DbConnector.branch stable
git submodule update --remote
<# If you leave off the -f .gitmodules it will only make the change for you, but it probably makes more
sense to track that information with the repository so everyone else does as well.
#>

<#If you set the configuration setting status.submodulesummary, Git will also show you a short summary
of changes to your submodules:
#>
git config status.submodulesummary 1
<#At this point if you run git diff we can see both that we have modified our .gitmodules file and
also that there are a number of commits that we’ve pulled down and are ready to commit to our
submodule project
#>
git diff

<# This is pretty cool as we can actually see the log of commits that we’re about to commit to in our
submodule. Once committed, you can see this information after the fact as well when you run git
log -p.
#>
git log -p --submodule

<# Git will by default try to update all of your submodules when you run git submodule update
--remote. If you have a lot of them, you may want to pass the name of just the submodule you want
to try to update.


Pulling Upstream Changes from the Project Remote
Let’s now step into the shoes of your collaborator, who has their own local clone of the MainProject
repository. Simply executing git pull to get your newly committed changes is not enough:
#>
git pull

<# By default, the git pull command recursively fetches submodules changes, as we can see in the
output of the first command above. However, it does not update the submodules. This is shown by
the output of the git status command, which shows the submodule is “modified”, and has “new
commits”. What’s more, the brackets showing the new commits point left (<), indicating that these
commits are recorded in MainProject but are not present in the local DbConnector checkout. To
finalize the update, you need to run git submodule update:
#>
git submodule update --init --recursive

# FACTS SUPER PROJEcT
<# Note that to be on the safe side, you should run git submodule update with the --init flag in case the
MainProject commits you just pulled added new submodules, and with the --recursive flag if any
submodules have nested submodules.
If you want to automate this process, you can add the --recurse-submodules flag to the git pull
command (since Git 2.14). This will make Git run git submodule update right after the pull, putting
the submodules in the correct state. Moreover, if you want to make Git always pull with --recurse
-submodules, you can set the configuration option submodule.recurse to true (this works for git pull
since Git 2.15). This option will make Git use the --recurse-submodules flag for all commands that
support it (except clone).
There is a special situation that can happen when pulling superproject updates: it could be that the
upstream repository has changed the URL of the submodule in the .gitmodules file in one of the
commits you pull. This can happen for example if the submodule project changes its hosting
platform. In that case, it is possible for git pull --recurse-submodules, or git submodule update, to
fail if the superproject references a submodule commit that is not found in the submodule remote
locally configured in your repository. In order to remedy this situation, the git submodule sync
command is required:
#>
# copy the new URL to your local config
git submodule sync --recursive
# update the submodule from the new URL
git submodule update --init --recursive

<# If we go into the DbConnector directory, we have the new changes already merged into our local
stable branch. Now let’s see what happens when we make our own local change to the library and
someone else pushes another change upstream at the same time.
#>
cd DbConnector/
vim src/db.c
git commit -am 'Unicode support'

<# Now if we update our submodule we can see what happens when we have made a local change and
upstream also has a change we need to incorporate.
#>

cd ..
git submodule update --remote --rebase

<# If you forget the --rebase or --merge, Git will just update the submodule to whatever is on the server
and reset your project to a detached HEAD state.
#>
git submodule update --remote

<# If you made changes that conflict with something changed upstream, Git will let you know when you run the update.#>
git submodule update --remote --merge

<# If we commit in the main project and push it up without pushing the submodule changes up as
well, other people who try to check out our changes are going to be in trouble since they will have
no way to get the submodule changes that are depended on. Those changes will only exist on our
local copy.
In order to make sure this doesn’t happen, you can ask Git to check that all your submodules have
been pushed properly before pushing the main project. The git push command takes the --recurse
-submodules argument which can be set to either “check” or “on-demand”. The “check” option will
make push simply fail if any of the committed submodule changes haven’t been pushed.
#>
git push --recurse-submodules=check

<# As you can see, it also gives us some helpful advice on what we might want to do next. The simple
option is to go into each submodule and manually push to the remotes to make sure they’re
externally available and then try this push again. If you want the check behavior to happen for all
pushes, you can make this behavior the default by doing git config push.recurseSubmodules check.
The other option is to use the “on-demand” value, which will try to do this for you.
#>
git push --recurse-submodules=on-demand

<# What is important is the SHA-1 of the commit from the other side. This is what you’ll have to merge
in and resolve. You can either just try the merge with the SHA-1 directly, or you can create a branch
for it and then try to merge that in. We would suggest the latter, even if only to make a nicer merge
commit message.
So, we will go into our submodule directory, create a branch named “try-merge” based on that
second SHA-1 from git diff, and manually merge.
#>
cd DbConnector
git rev-parse HEAD
#eb41d764bccf88be77aced643c13a7fa86714135
git branch try-merge c771610
git merge try-merge

<# We got an actual merge conflict here, so if we resolve that and commit it, then we can simply
update the main project with the result.
#>
vim src/main.c 
git add src/main.c
git commit -am 'merged our changes'
cd ..
git diff
git add DbConnnector
git commit -m "Merge THe submodule"

<# Submodule Foreach
There is a foreach submodule command to run some arbitrary command in each submodule. This
can be really helpful if you have a number of submodules in the same project.#>
<# For example, let’s say we want to start a new feature or do a bugfix and we have work going on in
several submodules. We can easily stash all the work in all our submodules.
#>
git submodule foreach 'git stash'

<# Then we can create a new branch and switch to it in all our submodules.#>
git submodule foreach 'git checkout -b featureA'

<# You get the idea. One really useful thing you can do is produce a nice unified diff of what is changed
in your main project and all your subprojects as well.
#>
git diff; git submodule foreach 'git diff'

<# Here we can see that we’re defining a function in a submodule and calling it in the main project.
This is obviously a simplified example, but hopefully it gives you an idea of how this may be useful.
Useful Aliases
You may want to set up some aliases for some of these commands as they can be quite long and you
can’t set configuration options for most of them to make them defaults. We covered setting up Git
aliases in Git Aliases, but here is an example of what you may want to set up if you plan on working
with submodules in Git a lot.
#>
git config alias.sdiff '!'"git diff && git submodule foreach 'git diff'"
git config alias.spush 'push --recurse-submodules=on-demand'
git config alias.supdate 'submodule update --remote --merge'
# This way you can simply run git supdate when you want to update your submodules, or git spush

<# Newer Git versions (Git >= 2.13) simplify all this by adding the --recurse-submodules flag to the git
checkout command, which takes care of placing the submodules in the right state for the branch we
are switching to.
$ git --version
#>
git checkout -b add-crypto
git submodule add https://github.com/chaconinc/CryptoLibrary
git commit -am 'Add crypto library'
git checkout --recurse-submodules master
git status

<# Switching from subdirectories to submodules
The other main caveat that many people run into involves switching from subdirectories to
submodules. If you’ve been tracking files in your project and you want to move them out into a
submodule, you must be careful or Git will get angry at you. Assume that you have files in a
subdirectory of your project, and you want to switch it to a submodule. If you delete the
subdirectory and then run submodule add, Git yells at you:
#>
rm -Rf CryptoLibrary/
git submodule add https://github.com/chaconinc/CryptoLibrary

<# You have to unstage the CryptoLibrary directory first. Then you can add the submodule:#>
git rm -r CryptoLibrary
git submodule add https://github.com/chaconinc/CryptoLibrary

<# Now suppose you did that in a branch. If you try to switch back to a branch where those files are
still in the actual tree rather than a submodule – you get this error:
#>
git checkout master

<# You can force it to switch with checkout -f, but be careful that you don’t have unsaved changes in
there as they could be overwritten with that command.
#>
git checkout -f master

<# Bundling
Though we’ve covered the common ways to transfer Git data over a network (HTTP, SSH, etc), there
is actually one more way to do so that is not commonly used but can actually be quite useful.
Git is capable of “bundling” its data into a single file. This can be useful in various scenarios. Maybe
your network is down and you want to send changes to your co-workers. Perhaps you’re working
somewhere offsite and don’t have access to the local network for security reasons. Maybe your
wireless/ethernet card just broke. Maybe you don’t have access to a shared server for the moment,
you want to email someone updates and you don’t want to transfer 40 commits via format-patch.
This is where the git bundle command can be helpful. The bundle command will package up
everything that would normally be pushed over the wire with a git push command into a binary
file that you can email to someone or put on a flash drive, then unbundle into another repository#>

<# If you want to send that repository to someone and you don’t have access to a repository to push to,
or simply don’t want to set one up, you can bundle it with git bundle create.
#>
git log
git bundle create repo.bundle HEAD master

<# Now you have a file named repo.bundle that has all the data needed to re-create the repository’s
master branch. With the bundle command you need to list out every reference or specific range of
commits that you want to be included. If you intend for this to be cloned somewhere else, you
should add HEAD as a reference as well as we’ve done here.
You can email this repo.bundle file to someone else, or put it on a USB drive and walk it over.
On the other side, say you are sent this repo.bundle file and want to work on the project. You can
clone from the binary file into a directory, much like you would from a URL.
#>
git clone repo.bundle repo
<# If you don’t include HEAD in the references, you have to also specify -b master or whatever branch
is included because otherwise it won’t know what branch to check out.
#>

<# First we need to determine the range of commits we want to include in the bundle. Unlike the
network protocols which figure out the minimum set of data to transfer over the network for us,
we’ll have to figure this out manually. Now, you could just do the same thing and bundle the entire
repository, which will work, but it’s better to just bundle up the difference - just the three commits
we just made locally.
In order to do that, you’ll have to calculate the difference. As we described in Commit Ranges, you
can specify a range of commits in a number of ways. To get the three commits that we have in our
master branch that weren’t in the branch we originally cloned, we can use something like
origin/master..master or master ^origin/master. You can test that with the log command.
#>
git log --oneline master ^origin/master

<# So now that we have the list of commits we want to include in the bundle, let’s bundle them up. We
do that with the git bundle create command, giving it a filename we want our bundle to be and the
range of commits we want to go into it.
#>
git bundle create commits.bundle master ^9a466c5

<# Now we have a commits.bundle file in our directory. If we take that and send it to our partner, she
can then import it into the original repository, even if more work has been done there in the
meantime
When she gets the bundle, she can inspect it to see what it contains before she imports it into her
repository. The first command is the bundle verify command that will make sure the file is actually
a valid Git bundle and that you have all the necessary ancestors to reconstitute it properly.
#>
git bundle verify ../commits.bundle

<# However, our first bundle is valid, so we can fetch in commits from it. If you want to see what
branches are in the bundle that can be imported, there is also a command to just list the heads:
#>
git bundle list-heads ../commits.bundle

<# The verify sub-command will tell you the heads as well. The point is to see what can be pulled in, so
you can use the fetch or pull commands to import commits from this bundle. Here we’ll fetch the
master branch of the bundle to a branch named other-master in our repository:
#>
git fetch ../commits.bundle master:other-master

<# Now we can see that we have the imported commits on the other-master branch as well as any
commits we’ve done in the meantime in our own master branch.
#>
git log --oneline --decorate --graph --all

# FACTS
<# Replace
As we’ve emphasized before, the objects in Git’s object database are unchangeable, but Git does
provide an interesting way to pretend to replace objects in its database with other objects.
The replace command lets you specify an object in Git and say "every time you refer to this object,
pretend it’s a different object". This is most commonly useful for replacing one commit in your
history with another one without having to rebuild the entire history with, say, git filter-branch.
For example, let’s say you have a huge code history and want to split your repository into one short
history for new developers and one much longer and larger history for people interested in data
mining. You can graft one history onto the other by "replacing" the earliest commit in the new line
with the latest commit on the older one. This is nice because it means that you don’t actually have
to rewrite every commit in the new history, as you would normally have to do to join them together
(because the parentage affects the SHA-1s).
Let’s try this out. Let’s take an existing repository, split it into two repositories, one recent and one
historical, and then we’ll see how we can recombine them without modifying the recent
repositories SHA-1 values via replace.
We’ll use a simple repository with five simple commits:
#>
git log --oneline

<# We want to break this up into two lines of history. One line goes from commit one to commit four -
that will be the historical one. The second line will just be commits four and five - that will be the recent history.
Well, creating the historical history is easy, we can just put a branch in the history and then push
that branch to the master branch of a new remote repository.
#>
git branch history c6e1e95
git log --oneline --decorate

<# Now we can push the new history branch to the master branch of our new repository:#>
git remote add project-history https://github.com/schacon/project-history
git push project-history history:master

<# OK, so our history is published. Now the harder part is truncating our recent history down so it’s
332
smaller. We need an overlap so we can replace a commit in one with an equivalent commit in the
other, so we’re going to truncate this to just commits four and five (so commit four overlaps).
#>
git log --oneline --decorate

<# It’s useful in this case to create a base commit that has instructions on how to expand the history, so
other developers know what to do if they hit the first commit in the truncated history and need
more. So, what we’re going to do is create an initial commit object as our base point with
instructions, then rebase the remaining commits (four and five) on top of it.
To do that, we need to choose a point to split at, which for us is the third commit, which is 9c68fdc in
SHA-speak. So, our base commit will be based off of that tree. We can create our base commit using
the commit-tree command, which just takes a tree and will give us a brand new, parentless commit
object SHA-1 back.
#>
echo 'Get history from blah blah blah' | git commit-tree 9c68fdc^{tree}

<# OK, so now that we have a base commit, we can rebase the rest of our history on top of that with
git rebase --onto. The --onto argument will be the SHA-1 we just got back from commit-tree and
the rebase point will be the third commit (the parent of the first commit we want to keep, 9c68fdc):
#>
git rebase --onto 622e88 9c68fdc

<# OK, so now we’ve re-written our recent history on top of a throw away base commit that now has
instructions in it on how to reconstitute the entire history if we wanted to. We can push that new
history to a new project and now when people clone that repository, they will only see the most
recent two commits and then a base commit with instructions.
Let’s now switch roles to someone cloning the project for the first time who wants the entire
history. To get the history data after cloning this truncated repository, one would have to add a
second remote for the historical repository and fetch:#>
git clone https://github.com/schacon/project
cd project
git log --oneline master
git remote add project-history https://github.com/schacon/project-history
git fetch project-history
<# Now the collaborator would have their recent commits in the master branch and the historical
commits in the project-history/master branch.#>
git log --oneline master
git log --oneline project-history/master
<#To combine them, you can simply call git replace with the commit you want to replace and then
the commit you want to replace it with. So we want to replace the "fourth" commit in the master
branch with the "fourth" commit in the project-history/master branch:
#>
git replace 81a708d c6e1e95
#Now, if you look at the history of the master branch, it appears to look like this:
git log --oneline master

<# Interestingly, it still shows 81a708d as the SHA-1, even though it’s actually using the c6e1e95 commit
data that we replaced it with. Even if you run a command like cat-file, it will show you the
replaced data:
#>
git cat-file -p 81a708d
#Remember that the actual parent of 81a708d was our placeholder commit (622e88e), not 9c68fdce as it states here
# Another interesting thing is that this data is kept in our references:
git for-each-ref



