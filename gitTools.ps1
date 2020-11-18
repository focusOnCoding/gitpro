<# Short SHA-1
Git is smart enough to figure out what commit you’re referring to if you provide the first few
characters of the SHA-1 hash, as long as that partial hash is at least four characters long and
unambiguous; that is, no other object in the object database can have a hash that begins with the
same prefix.
For example, to examine a specific commit where you know you added certain functionality, you
might first run the git log command to locate the commit:#>
git log

<# In this case, say you’re interested in the commit whose hash begins with 1c002dd.... You can inspect
that commit with any of the following variations of git show (assuming the shorter versions are
unambiguous):#>
git show <firstForLettersOfID>

<# Git can figure out a short, unique abbreviation for your SHA-1 values. If you pass --abbrev-commit to
the git log command, the output will use shorter values but keep them unique; it defaults to using
seven characters but makes them longer if necessary to keep the SHA-1 unambiguous:
#>
git log --abbrev-commit --pretty=oneline

<# Branch References
One straightforward way to refer to a particular commit is if it’s the commit at the tip of a branch;
in that case, you can simply use the branch name in any Git command that expects a reference to a
commit. For instance, if you want to examine the last commit object on a branch, the following
commands are equivalent, assuming that the topic1 branch points to commit ca82a6d...:
#>
git show topic1
git show ca82a6dff817ec66f44342007202690a93763949

<# RefLog Shortnames
One of the things Git does in the background while you’re working away is keep a “reflog” — a log
of where your HEAD and branch references have been for the last few months.
You can see your reflog by using git reflog:
#>
git reflog

<# Every time your branch tip is updated for any reason, Git stores that information for you in this
temporary history. You can use your reflog data to refer to older commits as well. For example, if
you want to see the fifth prior value of the HEAD of your repository, you can use the @{5} reference
that you see in the reflog output:
#>
git show HEAD@{5}

<# You can also use this syntax to see where a branch was some specific amount of time ago. For
instance, to see where your master branch was yesterday, you can type:
#>
git show master@{yesterday}
# To see reflog information formatted like the git log output, you can run git log -g:
git log -g master

<# When using PowerShell, braces like { and } are special characters and must be
escaped. You can escape them with a backtick ` or put the commit reference in
quotes:
#>
git show HEAD@{0}     # will NOT work
git show HEAD@`{0`}   # OK
git show "HEAD@{0}"   # OK

<# Ancestry References
The other main way to specify a commit is via its ancestry. If you place a ^ (caret) at the end of a
reference, Git resolves it to mean the parent of that commit. Suppose you look at the history of your
project:
#>
git log --pretty=format:'%h %s' --graph
# Then, you can see the previous commit by specifying HEAD^, which means “the parent of HEAD”:
git show HEAD^

<# On Windows in cmd.exe, ^ is a special character and needs to be treated differently.
You can either double it or put the commit reference in quotes:
#>
git show HEAD^ # will NOT work on Windows
git show HEAD^^ # OK
git show "HEAD^" # OK
# OR
git show d921970^
git show d921970^2
<# The other main ancestry specification is the ~ (tilde). This also refers to the first parent, so HEAD~ and
HEAD^ are equivalent. The difference becomes apparent when you specify a number. HEAD~2 means
“the first parent of the first parent,” or “the grandparent” — it traverses the first parents the
number of times you specify. For example, in the history listed earlier, HEAD~3 would be:
#>
git show HEAD~3

# This can also be written HEAD~~~, which again is the first parent of the first parent of the first parent:
git show HEAD~~~
<#You can also combine these syntaxes — you can get the second parent of the previous reference
(assuming it was a merge commit) by using HEAD~3^2, and so on.#>

# Commit Ranges
<# Say you want to see what is in your experiment branch that hasn’t yet been merged into your master
branch. You can ask Git to show you a log of just those commits with master..experiment — that
means “all commits reachable from experiment that aren’t reachable from master.” For the sake of
brevity and clarity in these examples, the letters of the commit objects from the diagram are used
in place of the actual log output in the order that they would display:
#>
git log master..experiment
D
C

<# If, on the other hand, you want to see the opposite — all commits in master that aren’t in
experiment — you can reverse the branch names. experiment..master shows you everything in master
not reachable from experiment:#>
git log experiment..master
F
E
<# This is useful if you want to keep the experiment branch up to date and preview what you’re about
to merge. Another frequent use of this syntax is to see what you’re about to push to a remote:
#>
git log origin/master..HEAD

<# Multiple Points
The double-dot syntax is useful as a shorthand, but perhaps you want to specify more than two
branches to indicate your revision, such as seeing what commits are in any of several branches that
aren’t in the branch you’re currently on. Git allows you to do this by using either the ^ character or
--not before any reference from which you don’t want to see reachable commits. Thus, the
following three commands are equivalent:#>
git log refA..refB
git log ^refA refB
git log refB --not refA
<# This is nice because with this syntax you can specify more than two references in your query,
which you cannot do with the double-dot syntax. For instance, if you want to see all commits that
are reachable from refA or refB but not from refC, you can use either of:#>
git log refA refB ^refC
git log refA refB --not refC
<# This makes for a very powerful revision query system that should help you figure out what is in
your branches.
Triple Dot
The last major range-selection syntax is the triple-dot syntax, which specifies all the commits that
are reachable by either of two references but not by both of them. Look back at the example
commit history in Example history for range selection. If you want to see what is in master or
experiment but not any common references, you can run:#> 
git log master...experiment
F
E
D
C
<# Again, this gives you normal log output but shows you only the commit information for those four
commits, appearing in the traditional commit date ordering.
A common switch to use with the log command in this case is --left-right, which shows you which
side of the range each commit is in. This helps make the output more useful:
#>
git log --left-right master...experiment
< F
< E
> D
> C

<# Interactive Staging
In this section, you’ll look at a few interactive Git commands that can help you craft your commits
to include only certain combinations and parts of files. These tools are helpful if you modify a
number of files extensively, then decide that you want those changes to be partitioned into several
focused commits rather than one big messy commit. This way, you can make sure your commits are
logically separate changesets and can be reviewed easily by the developers working with you.
If you run git add with the -i or --interactive option, Git enters an interactive shell mode,
displaying something like this:
#>
git add -i

<# Staging and Unstaging Files
If you type u or 2 (for update) at the What now> prompt, you’re prompted for which files you want to
stage:
#>
What now> u
# To stage the TODO and index.html files, you can type the numbers:
Update>> 1,2

<# The * next to each file means the file is selected to be staged. If you press Enter after typing nothing
at the Update>> prompt, Git takes anything selected and stages it for you:
#>
Update>>
updated 2 paths
<# Now you can see that the TODO and index.html files are staged and the simplegit.rb file is still
unstaged. If you want to unstage the TODO file at this point, you use the r or 3 (for revert) option:#>
What now> r
Revert>> 1
Revert>> [enter]
reverted one path
# Looking at your Git status again, you can see that you’ve unstaged the TODO file:
What now> s
<# To see the diff of what you’ve staged, you can use the d or 6 (for diff) command. It shows you a list
of your staged files, and you can select the ones for which you would like to see the staged diff. This
is much like specifying git diff --cached on the command line:
#>

#! Staging Patches
<# It’s also possible for Git to stage certain parts of files and not the rest. For example, if you make two
changes to your simplegit.rb file and want to stage one of them and not the other, doing so is very
easy in Git. From the same interactive prompt explained in the previous section, type p or 5 (for
patch). Git will ask you which files you would like to partially stage; then, for each section of the
selected files, it will display hunks of the file diff and ask if you would like to stage them, one by
one:
#>
diff --git a/lib/simplegit.rb b/lib/simplegit.rb

<# You have a lot of options at this point. Typing ? shows a list of what you can do:
Stage this hunk [y,n,a,d,/,j,J,g,e,?]? ?
y - stage this hunk
n - do not stage this hunk
a - stage this and all the remaining hunks in the file
d - do not stage this hunk nor any of the remaining hunks in the file
g - select a hunk to go to
/ - search for a hunk matching the given regex
j - leave this hunk undecided, see next undecided hunk
J - leave this hunk undecided, see next hunk
k - leave this hunk undecided, see previous undecided hunk
K - leave this hunk undecided, see previous hunk
s - split the current hunk into smaller hunks
e - manually edit the current hunk
? - print help
Generally, you’ll type y or n if you want to stage each hunk, but staging all of them in certain files or
skipping a hunk decision until later can be helpful too. If you stage one part of the file and leave
another part unstaged, your status output will look like this:
#>
What now> 1
<# Generally, you’ll type y or n if you want to stage each hunk, but staging all of them in certain files or
skipping a hunk decision until later can be helpful too. If you stage one part of the file and leave
another part unstaged, your status output will look like this:
#>
What now> 1
<# The status of the simplegit.rb file is interesting. It shows you that a couple of lines are staged and a
couple are unstaged. You’ve partially staged this file. At this point, you can exit the interactive
adding script and run git commit to commit the partially staged files.
You also don’t need to be in interactive add mode to do the partial-file staging — you can start the
same script by using git add -p or git add --patch on the command line.#>
git add -p
git add --patch
<# Furthermore, you can use patch mode for partially resetting files with the git reset --patch
command, for checking out parts of files with the git checkout --patch command and for stashing
parts of files with the git stash save --patch command. We’ll go into more details on each of these
as we get to more advanced usages of these commands.
#>
git reset --patch
git checkout --patch
git stash save --patch

<# Stashing and Cleaning
Often, when you’ve been working on part of your project, things are in a messy state and you want
to switch branches for a bit to work on something else. The problem is, you don’t want to do a
commit of half-done work just so you can get back to this point later. The answer to this issue is the
git stash command
#>
git stash

<# As of late October 2017, there has been extensive discussion on the Git mailing list,
wherein the command git stash save is being deprecated in favour of the existing
alternative git stash push. The main reason for this is that git stash push
introduces the option of stashing selected pathspecs, something git stash save
does not support.
git stash save is not going away any time soon, so don’t worry about it suddenly
disappearing. But you might want to start migrating over to the push alternative
for the new functionality.
#>

<# Now you want to switch branches, but you don’t want to commit what you’ve been working on yet,
so you’ll stash the changes. To push a new stash onto your stack, run git stash or git stash push:
#>
git stash

<# At this point, you can switch branches and do work elsewhere; your changes are stored on your
stack. To see which stashes you’ve stored, you can use git stash list:
#>
git stash list

<# In this case, two stashes were saved previously, so you have access to three different stashed works.
You can reapply the one you just stashed by using the command shown in the help output of the
original stash command: git stash apply. If you want to apply one of the older stashes, you can
specify it by naming it, like this: git stash apply stash@{2}. If you don’t specify a stash, Git assumes
the most recent stash and tries to apply it:
#>
git stash apply

<# The changes to your files were reapplied, but the file you staged before wasn’t restaged. To do that,
you must run the git stash apply command with a --index option to tell the command to try to
reapply the staged changes. If you had run that instead, you’d have gotten back to your original
position:
#>
git stash apply --index

<# The apply option only tries to apply the stashed work — you continue to have it on your stack. To
remove it, you can run git stash drop with the name of the stash to remove:
#>
git stash list
#stash@{0}: WIP on master: 049d078 Create index file
#stash@{1}: WIP on master: c264051 Revert "Add file_size"
#stash@{2}: WIP on master: 21d80a5 Add number to log
git stash drop stash@{0}
#Dropped stash@{0} (364e91f3f268f0900bc3ee613f9f733e82aaed43)
# You can also run git stash pop to apply the stash and then immediately drop it from your stack.

<# Creative Stashing
There are a few stash variants that may also be helpful. The first option that is quite popular is the
--keep-index option to the git stash command. This tells Git to not only include all staged content in
the stash being created, but simultaneously leave it in the index.
#>
$ git status -s
#M index.html
# M lib/simplegit.rb
git stash --keep-index
<# Saved working directory and index state WIP on master: 1b65b17 added the index file
HEAD is now at 1b65b17 added the index file
#>
git status -s
#M index.html

<# Another common thing you may want to do with stash is to stash the untracked files as well as the
tracked ones. By default, git stash will stash only modified and staged tracked files. If you specify
--include-untracked or -u, Git will include untracked files in the stash being created. However,
including untracked files in the stash will still not include explicitly ignored files; to additionally
include ignored files, use --all (or just -a).
#>
git stash -u

<# Finally, if you specify the --patch flag, Git will not stash everything that is modified but will instead
prompt you interactively which of the changes you would like to stash and which you would like to
keep in your working directory.
#>
git stash --patch

<# Creating a Branch from a Stash
If you stash some work, leave it there for a while, and continue on the branch from which you
stashed the work, you may have a problem reapplying the work. If the apply tries to modify a file
that you’ve since modified, you’ll get a merge conflict and will have to try to resolve it. If you want
an easier way to test the stashed changes again, you can run git stash branch <new branchname>,
which creates a new branch for you with your selected branch name, checks out the commit you
were on when you stashed your work, reapplies your work there, and then drops the stash if it
applies successfully:
#>
git stash branch testchanges

<# Cleaning your Working Directory
Finally, you may not want to stash some work or files in your working directory, but simply get rid
of them; that’s what the git clean command is for.
Some common reasons for cleaning your working directory might be to remove cruft that has been
generated by merges or external tools or to remove build artifacts in order to run a clean build.
You’ll want to be pretty careful with this command, since it’s designed to remove files from your
working directory that are not tracked. If you change your mind, there is often no retrieving the
content of those files. A safer option is to run git stash --all to remove everything but save it in a
stash.
Assuming you do want to remove cruft files or clean your working directory, you can do so with git
clean. To remove all the untracked files in your working directory, you can run git clean -f -d,
which removes any files and also any subdirectories that become empty as a result. The -f means
force or “really do this,” and is required if the Git configuration variable clean.requireForce is not
explicitly set to false.
If you ever want to see what it would do, you can run the command with the --dry-run (or -n)
option, which means “do a dry run and tell me what you would have removed”.
#>
git clean -d -n

<# By default, the git clean command will only remove untracked files that are not ignored. Any file
that matches a pattern in your .gitignore or other ignore files will not be removed. If you want to
remove those files too, such as to remove all .o files generated from a build so you can do a fully
clean build, you can add a -x to the clean command.
#>
git clean -n -d -x

<# If you don’t know what the git clean command is going to do, always run it with a -n first to double
check before changing the -n to a -f and doing it for real. The other way you can be careful about
the process is to run it with the -i or “interactive” flag.
This will run the clean command in an interactive mode.
#>
git clean -x -i
# If you don’t know what the git clean command is going to do, always run it with a -n first to double

<# This way you can step through each file individually or specify patterns for deletion interactively.
There is a quirky situation where you might need to be extra forceful in asking Git
to clean your working directory. If you happen to be in a working directory under
which you’ve copied or cloned other Git repositories (perhaps as submodules),
even git clean -fd will refuse to delete those directories. In cases like that, you
need to add a second -f option for emphasis.
#>

<# Signing Your Work
Git is cryptographically secure, but it’s not foolproof. If you’re taking work from others on the
internet and want to verify that commits are actually from a trusted source, Git has a few ways to
sign and verify work using GPG.
GPG Introduction
First of all, if you want to sign anything you need to get GPG configured and your personal key
installed.
#>
gpg --list-keys

# If you don’t have a key installed, you can generate one with gpg --gen-key.
gpg --gen-key
<# Once you have a private key to sign with, you can configure Git to use it for signing things by setting
the user.signingkey config setting.
#>

<# Once you have a private key to sign with, you can configure Git to use it for signing things by setting
the user.signingkey config setting.#>
git config --global user.signingkey 0A46826A
<# Now Git will use your key by default to sign tags and commits if you want.
Signing Tags
If you have a GPG private key setup, you can now use it to sign new tags. All you have to do is use -s
instead of -a:
#>
git tag -s v1.5 -m 'my signed 1.5 tag'

# If you run git show on that tag, you can see your GPG signature attached to it:
git show v1.5

<# Verifying Tags
To verify a signed tag, you use git tag -v <tag-name>. This command uses GPG to verify the
signature. You need the signer’s public key in your keyring for this to work properly:
#>
git tag -v v1.4.2.1

<# Signing Commits
In more recent versions of Git (v1.7.9 and above), you can now also sign individual commits. If
you’re interested in signing commits directly instead of just the tags, all you need to do is add a -S to
your git commit command.
#>
git commit -a -S -m 'Signed commit'

# To see and verify these signatures, there is also a --show-signature option to git log.
git log --show-signature -1

<# Additionally, you can configure git log to check any signatures it finds and list them in its output
with the %G? format.
#>
git log --pretty="format:%h %G? %aN  %s"

<# In Git 1.8.3 and later, git merge and git pull can be told to inspect and reject when merging a
commit that does not carry a trusted GPG signature with the --verify-signatures command.
If you use this option when merging a branch and it contains commits that are not signed and valid,
the merge will not work.
#>
git merge --verify-signatures non-verify

<# If the merge contains only valid signed commits, the merge command will show you all the
signatures it has checked and then move forward with the merge.
#>
git merge --verify-signatures signed-branch

<# You can also use the -S option with the git merge command to sign the resulting merge commit
itself. The following example both verifies that every commit in the branch to be merged is signed
and furthermore signs the resulting merge commit.
#>
git merge --verify-signatures -S signed-branch