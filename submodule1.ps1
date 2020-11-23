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