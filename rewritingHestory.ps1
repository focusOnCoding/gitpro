<# Changing the Last Commit
Changing your most recent commit is probably the most common rewriting of history that you’ll
do. You’ll often want to do two basic things to your last commit: simply change the commit message,
or change the actual content of the commit by adding, removing and modifying files.
If you simply want to modify your last commit message, that’s easy:
#>
git commit --amend

<# On the other hand, if your amendments are suitably trivial (fixing a silly typo or
adding a file you forgot to stage) such that the earlier commit message is just fine,
you can simply make the changes, stage them, and avoid the unnecessary editor
session entirely with:
#>
git commit --amend --no-edit

<# Changing Multiple Commit Messages
To modify a commit that is farther back in your history, you must move to more complex tools. Git
doesn’t have a modify-history tool, but you can use the rebase tool to rebase a series of commits
onto the HEAD they were originally based on instead of moving them to another one. With the
interactive rebase tool, you can then stop after each commit you want to modify and change the
message, add files, or do whatever you wish. You can run rebase interactively by adding the -i
option to git rebase. You must indicate how far back you want to rewrite commits by telling the
command which commit to rebase onto.
For example, if you want to change the last three commit messages, or any of the commit messages
in that group, you supply as an argument to git rebase -i the parent of the last commit you want to
edit, which is HEAD~2^ or HEAD~3. It may be easier to remember the ~3 because you’re trying to edit
the last three commits, but keep in mind that you’re actually designating four commits ago, the
parent of the last commit you want to edit:
#>
git rebase -i HEAD~3

<# It’s important to note that these commits are listed in the opposite order than you normally see
them using the log command. If you run a log, you see something like this:
#>
git log --pretty=format:"%h %s" HEAD~3..HEAD

# These instructions tell you exactly what to do. Type:
git commit --amend
#Change the commit message, and exit the editor. Then, run:
git rebase --continue
<# This command will apply the other two commits automatically, and then you’re done. If you change
pick to edit on more lines, you can repeat these steps for each commit you change to edit. Each
time, Git will stop, let you amend the commit, and continue when you’re finished.#>

<# # Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup <commit> = like "squash", but discard this commit's log message
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
# .       create a merge commit using the original merge commit's
# .       message (or the oneline, if no original merge commit was
# .       specified). Use -c <commit> to reword the commit message.
#>

<# If, instead of “pick” or “edit”, you specify “squash”, Git applies both that change and the change
directly before it and makes you merge the commit messages together. So, if you want to make a
single commit from these three commits, you make the script look like this:
#>

<# Squashing Commits
It’s also possible to take a series of commits and squash them down into a single commit with the
interactive rebasing tool. The script puts helpful instructions in the rebase message:#>

<# Splitting a Commit
Splitting a commit undoes a commit and then partially stages and commits as many times as
commits you want to end up with. For example, suppose you want to split the middle commit of
your three commits. Instead of “Update README formatting and add blame”, you want to split it
into two commits: “Update README formatting” for the first, and “Add blame” for the second. You
can do that in the rebase -i script by changing the instruction on the commit you want to split to
“edit”:
#>

<# Then, when the script drops you to the command line, you reset that commit, take the changes that
have been reset, and create multiple commits out of them. When you save and exit the editor, Git
rewinds to the parent of the first commit in your list, applies the first commit (f7f3f6d), applies the
second (310154e), and drops you to the console. There, you can do a mixed reset of that commit with
git reset HEAD^, which effectively undoes that commit and leaves the modified files unstaged. Now
you can stage and commit files until you have several commits, and run git rebase --continue
when you’re done:
#>
git reset HEAD^
git add README
git commit -m 'Update README formatting'
git add lib/simplegit.rb
git commit -m 'Add blame'
git rebase --continue
#Git applies the last commit (a5f4a0d) in the script, and your history looks like this:
git log -4 --pretty=format:"%h %s"

<# Deleting a commit
If you want to get rid of a commit, you can delete it using the rebase -i script. In the list of commits,
put the word “drop” before the commit you want to delete (or just delete that line from the rebase
script):
#>

<# If you get partway through a rebase like this and decide it’s not a good idea, you can always stop.
Type git rebase --abort, and your repo will be returned to the state it was in before you started the
rebase.
If you finish a rebase and decide it’s not what you want, you can use git reflog to recover an
earlier version of your branch. See Data Recovery for more information on the reflog command.
#>

<# git filter-branch has many pitfalls, and is no longer the recommended way to
rewrite history. Instead, consider using git-filter-repo, which is a Python script
that does a better job for most applications where you would normally turn to
filter-branch. Its documentation and source code can be found at
https://github.com/newren/git-filter-repo.
#>

<# Removing a File from Every Commit
This occurs fairly commonly. Someone accidentally commits a huge binary file with a thoughtless
git add ., and you want to remove it everywhere. Perhaps you accidentally committed a file that
contained a password, and you want to make your project open source. filter-branch is the tool
you probably want to use to scrub your entire history. To remove a file named passwords.txt from
your entire history, you can use the --tree-filter option to filter-branch:
#>
git filter-branch --tree-filter 'rm -f passwords.txt' HEAD

<# The --tree-filter option runs the specified command after each checkout of the project and then
recommits the results. In this case, you remove a file called passwords.txt from every snapshot,
whether it exists or not. If you want to remove all accidentally committed editor backup files, you
can run something like git filter-branch --tree-filter 'rm -f *~' HEAD.
You’ll be able to watch Git rewriting trees and commits and then move the branch pointer at the
end. It’s generally a good idea to do this in a testing branch and then hard-reset your master branch
after you’ve determined the outcome is what you really want. To run filter-branch on all your
branches, you can pass --all to the command.
#>

<# Making a Subdirectory the New Root
Suppose you’ve done an import from another source control system and have subdirectories that
make no sense (trunk, tags, and so on). If you want to make the trunk subdirectory be the new
project root for every commit, filter-branch can help you do that, too:
#>
git filter-branch --subdirectory-filter trunk HEAD

<# Changing Email Addresses Globally
Another common case is that you forgot to run git config to set your name and email address
before you started working, or perhaps you want to open-source a project at work and change all
your work email addresses to your personal address. In any case, you can change email addresses
in multiple commits in a batch with filter-branch as well. You need to be careful to change only the
email addresses that are yours, so you use --commit-filter:#>
$ git filter-branch --commit-filter '
  if [ "$GIT_AUTHOR_EMAIL" = "schacon@localhost" ];
  then
  GIT_AUTHOR_NAME="Scott Chacon";
  GIT_AUTHOR_EMAIL="schacon@example.com";
  git commit-tree "$@";
  else
  git commit-tree "$@";
  fi' HEAD
<# This goes through and rewrites every commit to have your new address. Because commits contain
the SHA-1 values of their parents, this command changes every commit SHA-1 in your history, not
just those that have the matching email address.
#>

# Git Tree
<# The HEAD
HEAD is the pointer to the current branch reference, which is in turn a pointer to the last commit
made on that branch. That means HEAD will be the parent of the next commit that is created. It’s
generally simplest to think of HEAD as the snapshot of your last commit on that branch.
In fact, it’s pretty easy to see what that snapshot looks like. Here is an example of getting the actual
directory listing and SHA-1 checksums for each file in the HEAD snapshot:
#>
git cat-file -p HEAD
git ls-tree -r HEAD
<# The Git cat-file and ls-tree commands are “plumbing” commands that are used for lower level
things and not really used in day-to-day work, but they help us see what’s going on here.#>


<# The Index
The index is your proposed next commit. We’ve also been referring to this concept as Git’s “Staging
Area” as this is what Git looks at when you run git commit.
Git populates this index with a list of all the file contents that were last checked out into your
working directory and what they looked like when they were originally checked out. You then
replace some of those files with new versions of them, and git commit converts that into the tree for
a new commit.
#>
git ls-files -s
# Again, here we’re using git ls-files, which is more of a behind the scenes command that shows
# you what your index currently looks like.

<# The Working Directory
Finally, you have your working directory (also commonly referred to as the “working tree”). The
other two trees store their content in an efficient but inconvenient manner, inside the .git folder.
The working directory unpacks them into actual files, which makes it much easier for you to edit
them. Think of the working directory as a sandbox, where you can try changes out before
committing them to your staging area (index) and then to history.
#>
tree
