<# If for some reason you just want to start over, you can also run git reset --hard HEAD, and your
repository will be back to the last committed state. Remember that any uncommitted work will be
lost, so make sure you don’t want any of your changes
#>

<# Ignoring Whitespace
In this specific case, the conflicts are whitespace related. We know this because the case is simple,
but it’s also pretty easy to tell in real cases when looking at the conflict because every line is
removed on one side and added again on the other. By default, Git sees all of these lines as being
changed, so it can’t merge the files.
The default merge strategy can take arguments though, and a few of them are about properly
ignoring whitespace changes. If you see that you have a lot of whitespace issues in a merge, you can
simply abort it and do it again, this time with -Xignore-all-space or -Xignore-space-change. The first
option ignores whitespace completely when comparing lines, the second treats sequences of one or
more whitespace characters as equivalent.
#>
git merge -Xignore-space-change whitespace

<# Manual File Re-merging
Though Git handles whitespace pre-processing pretty well, there are other types of changes that
perhaps Git can’t handle automatically, but are scriptable fixes. As an example, let’s pretend that Git
could not handle the whitespace change and we needed to do it by hand.
What we really need to do is run the file we’re trying to merge in through a dos2unix program
before trying the actual file merge. So how would we do that?
First, we get into the merge conflict state. Then we want to get copies of my version of the file, their
version (from the branch we’re merging in) and the common version (from where both sides
branched off). Then we want to fix up either their side or our side and re-try the merge again for
just this single file.
Getting the three file versions is actually pretty easy. Git stores all of these versions in the index
under “stages” which each have numbers associated with them. Stage 1 is the common ancestor,
stage 2 is your version and stage 3 is from the MERGE_HEAD, the version you’re merging in (“theirs”).
You can extract a copy of each of these versions of the conflicted file with the git show command
and a special syntax.#>
git show :1:hello.rb > hello.common.rb
git show :2:hello.rb > hello.ours.rb
git show :3:hello.rb > hello.theirs.rb
<# If you want to get a little more hard core, you can also use the ls-files -u plumbing command to
get the actual SHA-1s of the Git blobs for each of these files.
#>
git ls-files -u
# The :1:hello.rb is just a shorthand for looking up that blob SHA-1.

<# 
Now that we have the content of all three stages in our working directory, we can manually fix up
theirs to fix the whitespace issue and re-merge the file with the little-known git merge-file
command which does just that.
#>
dos2unix hello.theirs.rb

git merge-file -p \
# hello.ours.rb hello.common.rb hello.theirs.rb > hello.rb
git diff -b
<# At this point we have nicely merged the file. In fact, this actually works better than the ignore-
space-change option because this actually fixes the whitespace changes before merge instead of
simply ignoring them. In the ignore-space-change merge, we actually ended up with a few lines with
DOS line endings, making things mixed.
#>

<# If you want to get an idea before finalizing this commit about what was actually changed between
one side or the other, you can ask git diff to compare what is in your working directory that
you’re about to commit as the result of the merge to any of these stages. Let’s go through them all.
To compare your result to what you had in your branch before the merge, in other words, to see
what the merge introduced, you can run git diff --ours:
#>
git diff --ours

<# If we want to see how the result of the merge differed from what was on their side, you can run git
diff --theirs. In this and the following example, we have to use -b to strip out the whitespace
because we’re comparing it to what is in Git, not our cleaned up hello.theirs.rb file.
#>
git diff --theirs -b

# Finally, you can see how the file has changed from both sides with git diff --base.
git diff --base -b

# At this point we can use the git clean command to clear out the extra files we created to do the manual merge but no longer need.
git clean -f

<# Checking Out Conflicts
Perhaps we’re not happy with the resolution at this point for some reason, or maybe manually
editing one or both sides still didn’t work well and we need more context.
Let’s change up the example a little. For this example, we have two longer lived branches that each
have a few commits in them but create a legitimate content conflict when merged.
#>
git log --graph --oneline --decorate --all
<#We now have three unique commits that live only on the master branch and three others that live
on the mundo branch. If we try to merge the mundo branch in, we get a conflict.
#>

<# Both sides of the merge added content to this file, but some of the commits modified the file in the
same place that caused this conflict.
Let’s explore a couple of tools that you now have at your disposal to determine how this conflict
came to be. Perhaps it’s not obvious how exactly you should fix this conflict. You need more
context.
One helpful tool is git checkout with the --conflict option. This will re-checkout the file again and
replace the merge conflict markers. This can be useful if you want to reset the markers and try to
resolve them again.
You can pass --conflict either diff3 or merge (which is the default). If you pass it diff3, Git will use
a slightly different version of conflict markers, not only giving you the “ours” and “theirs” versions,
but also the “base” version inline to give you more context.
#>
git checkout --conflict=diff3 hello.rb

<# If you like this format, you can set it as the default for future merge conflicts by setting the
merge.conflictstyle setting to diff3.
#>
git config --global merge.conflictstyle diff3

<# Merge Log
Another useful tool when resolving merge conflicts is git log. This can help you get context on
what may have contributed to the conflicts. Reviewing a little bit of history to remember why two
lines of development were touching the same area of code can be really helpful sometimes.
To get a full list of all of the unique commits that were included in either branch involved in this
merge, we can use the “triple dot” syntax that we learned in Triple Dot.
#>
git log --oneline --left-right HEAD...MERGE_HEAD

<# That’s a nice list of the six total commits involved, as well as which line of development each
commit was on.
We can further simplify this though to give us much more specific context. If we add the --merge
option to git log, it will only show the commits in either side of the merge that touch a file that’s
currently conflicted.
#>
git log --oneline --left-right --merge
<# If you run that with the -p option instead, you get just the diffs to the file that ended up in conflict.
This can be really helpful in quickly giving you the context you need to help understand why
something conflicts and how to more intelligently resolve it
#>

<# Combined Diff Format
Since Git stages any merge results that are successful, when you run git diff while in a conflicted
merge state, you only get what is currently still in conflict. This can be helpful to see what you still
have to resolve.
When you run git diff directly after a merge conflict, it will give you information in a rather
unique diff output format.
#>
git diff

<# You can also get this from the git log for any merge to see how something was resolved after the
fact. Git will output this format if you run git show on a merge commit, or if you add a --cc option
to a git log -p (which by default only shows patches for non-merge commits).
#>
git log --cc -p -1

<# Undoing Merges
Now that you know how to create a merge commit, you’ll probably make some by mistake. One of
the great things about working with Git is that it’s okay to make mistakes, because it’s possible (and
in many cases easy) to fix them.
#>

<# Fix the references
If the unwanted merge commit only exists on your local repository, the easiest and best solution is
to move the branches so that they point where you want them to. In most cases, if you follow the
errant git merge with git reset --hard HEAD~, this will reset the branch pointers so they look like
this:
#>
git reset --hard HEAD~
<# We covered reset back in Reset Demystified, so it shouldn’t be too hard to figure out what’s going
on here. Here’s a quick refresher: reset --hard usually goes through three steps:
1. Move the branch HEAD points to. In this case, we want to move master to where it was before
the merge commit (C6).
2. Make the index look like HEAD.
3. Make the working directory look like the index.
The downside of this approach is that it’s rewriting history, which can be problematic with a shared
repository. Check out The Perils of Rebasing for more on what can happen; the short version is that
if other people have the commits you’re rewriting, you should probably avoid reset. This approach
also won’t work if any other commits have been created since the merge; moving the refs would
effectively lose those changes.#>

<# Reverse the commit
If moving the branch pointers around isn’t going to work for you, Git gives you the option of
making a new commit which undoes all the changes from an existing one. Git calls this operation a
“revert”, and in this particular scenario, you’d invoke it like this:
#>
git revert -m 1 HEAD
<#The -m 1 flag indicates which parent is the “mainline” and should be kept. When you invoke a
merge into HEAD (git merge topic), the new commit has two parents: the first one is HEAD (C6), and
the second is the tip of the branch being merged in (C4). In this case, we want to undo all the
changes introduced by merging in parent #2 (C4), while keeping all the content from parent #1 (C6)#>
# FACTS
<# The new commit ^M has exactly the same contents as C6, so starting from here it’s as if the merge
never happened, except that the now-unmerged commits are still in HEAD's history. Git will get
confused if you try to merge topic into master again:#>
git merge topic
#Already up-to-date.
<#There’s nothing in topic that isn’t already reachable from master. What’s worse, if you add work to
topic and merge again, Git will only bring in the changes since the reverted merge:
#>

<# The best way around this is to un-revert the original merge, since now you want to bring in the
changes that were reverted out, then create a new merge commit:
#>
git revert ^M
<# In this example, M and ^M cancel out. ^^M effectively merges in the changes from C3 and C4, and C8
merges in the changes from C7, so now topic is fully merged.
#>

<# By default, when Git sees a conflict between two branches being merged, it will add merge conflict
markers into your code and mark the file as conflicted and let you resolve it. If you would prefer
for Git to simply choose a specific side and ignore the other side instead of letting you manually
resolve the conflict, you can pass the merge command either a -Xours or -Xtheirs.#>
#However if we run it with -Xours or -Xtheirs it does not.
git merge -Xours mundo
<# In that case, instead of getting conflict markers in the file with “hello mundo” on one side and “hola
world” on the other, it will simply pick “hola world”. However, all the other non-conflicting changes
on that branch are merged successfully in.
This option can also be passed to the git merge-file command we saw earlier by running
something like git merge-file --ours for individual file merges.
#>

<# If you want to do something like this but not have Git even try to merge changes from the other side
in, there is a more draconian option, which is the “ours” merge strategy. This is different from the
“ours” recursive merge option.
This will basically do a fake merge. It will record a new merge commit with both branches as
parents, but it will not even look at the branch you’re merging in. It will simply record as the result
of the merge the exact code in your current branch.#>
git merge -s ours mundo
# Merge made by the 'ours' strategy.
git diff HEAD HEAD~
<# You can see that there is no difference between the branch we were on and the result of the merge.
This can often be useful to basically trick Git into thinking that a branch is already merged when
doing a merge later on. For example, say you branched off a release branch and have done some
work on it that you will want to merge back into your master branch at some point. In the meantime
some bugfix on master needs to be backported into your release branch. You can merge the bugfix
branch into the release branch and also merge -s ours the same branch into your master branch
(even though the fix is already there) so when you later merge the release branch again, there are
no conflicts from the bugfix.
#>

<# Subtree Merging
The idea of the subtree merge is that you have two projects, and one of the projects maps to a
subdirectory of the other one. When you specify a subtree merge, Git is often smart enough to
figure out that one is a subtree of the other and merge appropriately.
We’ll go through an example of adding a separate project into an existing project and then merging
the code of the second into a subdirectory of the first.
First, we’ll add the Rack application to our project. We’ll add the Rack project as a remote reference
in our own project and then check it out into its own branch:
#>
$ git remote add rack_remote https://github.com/rack/rack
$ git fetch rack_remote --no-tags
<# Now we have the root of the Rack project in our rack_branch branch and our own project in the
master branch. If you check out one and then the other, you can see that they have different project
roots:
#>
ls
git checkout master

<# In this case, we want to pull the Rack project into our master project as a subdirectory. We can do
that in Git with git read-tree. You’ll learn more about read-tree and its friends in Git Internals, but
for now know that it reads the root tree of one branch into your current staging area and working
directory. We just switched back to your master branch, and we pull the rack_branch branch into the
rack subdirectory of our master branch of our main project:#>
git read-tree --prefix=rack/ -u rack_branch
<# When we commit, it looks like we have all the Rack files under that subdirectory – as though we
copied them in from a tarball. What gets interesting is that we can fairly easily merge changes from
one of the branches to the other. So, if the Rack project updates, we can pull in upstream changes
by switching to that branch and pulling:
#>
git checkout rack_branch

<# Then, we can merge those changes back into our master branch. To pull in the changes and
prepopulate the commit message, use the --squash option, as well as the recursive merge strategy’s
-Xsubtree option. The recursive strategy is the default here, but we include it for clarity.
#>
git checkout master
git merge --squash -s recursive -Xsubtree=rack rack_branch
<#All the changes from the Rack project are merged in and ready to be committed locally. You can also
do the opposite – make changes in the rack subdirectory of your master branch and then merge
them into your rack_branch branch later to submit them to the maintainers or push them upstream.#>
<#Another slightly weird thing is that to get a diff between what you have in your rack subdirectory
and the code in your rack_branch branch – to see if you need to merge them – you can’t use the
normal diff command. Instead, you must run git diff-tree with the branch you want to compare
to:
294
#>
git diff-tree -p rack_branch

<# Or, to compare what is in your rack subdirectory with what the master branch on the server was the
last time you fetched, you can run:
#>
git diff-tree -p rack_remote/master

# To enable rerere functionality, you simply have to run this config setting:
git config --global rerere.enabled tru

# When we merge the two branches together, we’ll get a merge conflict:
git merge i18n-world
# However, git rerere will also tell you what it has recorded the pre-merge state for with git rerere status:
git rerere status
# And git rerere diff will show the current state of the resolution — what you started with to resolve and what you’ve resolved it to.
git rerere diff

<# Also (and this isn’t really related to rerere), you can use git ls-files -u to see the conflicted files
and the before, left and right versions:
#>
git ls-files -u

<# Now, let’s undo that merge and then rebase it on top of our master branch instead. We can move our
branch back by using git reset as we saw in Reset Demystified.
#>
git reset --hard HEAD^

# You can also recreate the conflicted file state with git checkout:
git checkout --conflict=merge hello.rb
cat hello.rb
#! /usr/bin/env 

# We saw an example of this in Advanced Merging. For now though, let’s re-resolve it by just running git rerere again:
git rerere

<# We have re-resolved the file automatically using the rerere cached resolution. You can now add and
continue the rebase to complete it.
#>
git add hello.rb
git rebase --continue
<#So, if you do a lot of re-merges, or want to keep a topic branch up to date with your master branch
without a ton of merges, or you rebase often, you can turn on rerere to help your life out a bit#>

