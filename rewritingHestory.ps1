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
