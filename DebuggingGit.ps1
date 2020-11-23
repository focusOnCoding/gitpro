# Debuging in git
<# File Annotation
If you track down a bug in your code and want to know when it was introduced and why, file
annotation is often your best tool. It shows you what commit was the last to modify each line of any
file. So if you see that a method in your code is buggy, you can annotate the file with git blame to
determine which commit was responsible for the introduction of that line.
The following example uses git blame to determine which commit and committer was responsible
for lines in the top-level Linux kernel Makefile and, further, uses the -L option to restrict the output
of the annotation to lines 69 through 82 of that file:
#>
git blame -L 69,82 Makefile

<# Notice that the first field is the partial SHA-1 of the commit that last modified that line. The next two
fields are values extracted from that commit — the author name and the authored date of that
commit — so you can easily see who modified that line and when. After that come the line number
and the content of the file. Also note the ^1da177e4c3f4 commit lines, where the ^ prefix designates
lines that were introduced in the repository’s initial commit and have remained unchanged ever
since. This is a tad confusing, because now you’ve seen at least three different ways that Git uses
the ^ to modify a commit SHA-1, but that is what it means here.#>

<# Another cool thing about Git is that it doesn’t track file renames explicitly. It records the snapshots
and then tries to figure out what was renamed implicitly, after the fact. One of the interesting
features of this is that you can ask it to figure out all sorts of code movement as well. If you pass -C
to git blame, Git analyzes the file you’re annotating and tries to figure out where snippets of code
within it originally came from if they were copied from elsewhere. For example, say you are
refactoring a file named GITServerHandler.m into multiple files, one of which is GITPackUpload.m. By
blaming GITPackUpload.m with the -C option, you can see where sections of the code originally came
from:
#>
git blame -C -L 141,153 GITPackUpload.m

<# Binary Search
Annotating a file helps if you know where the issue is to begin with. If you don’t know what is
breaking, and there have been dozens or hundreds of commits since the last state where you know
the code worked, you’ll likely turn to git bisect for help. The bisect command does a binary search
through your commit history to help you identify as quickly as possible which commit introduced
an issue.
Let’s say you just pushed out a release of your code to a production environment, you’re getting bug
reports about something that wasn’t happening in your development environment, and you can’t
imagine why the code is doing that. You go back to your code, and it turns out you can reproduce
the issue, but you can’t figure out what is going wrong. You can bisect the code to find out. First you
run git bisect start to get things going, and then you use git bisect bad to tell the system that the
current commit you’re on is broken. Then, you must tell bisect when the last known good state was,
using git bisect good <good_commit>:
#>
git bisect start
git bisect bad
git bisect good v1.0

<# Git figured out that about 12 commits came between the commit you marked as the last good
commit (v1.0) and the current bad version, and it checked out the middle one for you. At this point,
you can run your test to see if the issue exists as of this commit. If it does, then it was introduced
sometime before this middle commit; if it doesn’t, then the problem was introduced sometime after
the middle commit. It turns out there is no issue here, and you tell Git that by typing git bisect
good and continue your journey:
#>
git bisect good
<# Now you’re on another commit, halfway between the one you just tested and your bad commit. You
run your test again and find that this commit is broken, so you tell Git that with git bisect bad:
#>
git bisect bad
<# This commit is fine, and now Git has all the information it needs to determine where the issue was
introduced. It tells you the SHA-1 of the first bad commit and show some of the commit information
and which files were modified in that commit so you can figure out what happened that may have
introduced this bug:
#>
git bisect good

# When you’re finished, you should run git bisect reset to reset your HEAD to where you were
# before you started, or you’ll end up in a weird state:
git bisect reset

<# This is a powerful tool that can help you check hundreds of commits for an introduced bug in
minutes. In fact, if you have a script that will exit 0 if the project is good or non-0 if the project is
bad, you can fully automate git bisect. First, you again tell it the scope of the bisect by providing
the known bad and good commits. You can do this by listing them with the bisect start command
if you want, listing the known bad commit first and the known good commit second:#>
git bisect start HEAD v1.0
git bisect run test-error.sh
<# Doing so automatically runs test-error.sh on each checked-out commit until Git finds the first
broken commit. You can also run something like make or make tests or whatever you have that runs
automated tests for you.
#>

