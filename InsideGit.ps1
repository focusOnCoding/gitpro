<# Git Internals
You may have skipped to this chapter from a much earlier chapter, or you may have gotten here
after sequentially reading the entire book up to this point — in either case, this is where we’ll go
over the inner workings and implementation of Git. We found that understanding this information
was fundamentally important to appreciating how useful and powerful Git is, but others have
argued to us that it can be confusing and unnecessarily complex for beginners. Thus, we’ve made
this discussion the last chapter in the book so you could read it early or later in your learning
process. We leave it up to you to decide.
#>

<# When you run git init in a new or existing directory, Git creates the .git directory, which is where
almost everything that Git stores and manipulates is located. If you want to back up or clone your
repository, copying this single directory elsewhere gives you nearly everything you need. This
entire chapter basically deals with what you can see in this directory. Here’s what a newlyinitialized .git directory typically looks like:
432
$ ls -F1
config
description
HEAD
hooks/
info/
objects/
refs/

<# Depending on your version of Git, you may see some additional content there, but this is a fresh git
init repository — it’s what you see by default. The description file is used only by the GitWeb
program, so don’t worry about it. The config file contains your project-specific configuration
options, and the info directory keeps a global exclude file for ignored patterns that you don’t want
to track in a .gitignore file. The hooks directory contains your client- or server-side hook scripts,
which are discussed in detail in Git Hooks#>

<# This leaves four important entries: the HEAD and (yet to be created) index files, and the objects and
refs directories. These are the core parts of Git. The objects directory stores all the content for your
database, the refs directory stores pointers into commit objects in that data (branches, tags,
remotes and more), the HEAD file points to the branch you currently have checked out, and the index
file is where Git stores your staging area information. You’ll now look at each of these sections in
detail to see how Git operates.#>

<# Git Objects
Git is a content-addressable filesystem. Great. What does that mean? It means that at the core of Git
is a simple key-value data store. What this means is that you can insert any kind of content into a
Git repository, for which Git will hand you back a unique key you can use later to retrieve that
content.#>

<# As a demonstration, let’s look at the plumbing command git hash-object, which takes some data,
stores it in your .git/objects directory (the object database), and gives you back the unique key that
now refers to that data object.
First, you initialize a new Git repository and verify that there is (predictably) nothing in the objects
directory:
#>
$ git init test
# Initialized empty Git repository in /tmp/test/.git/
$ cd test
$ find .git/objects
.git/objects
.git/objects/info
.git/objects/pack
$ find .git/objects -type f
<# Git has initialized the objects directory and created pack and info subdirectories in it, but there are
no regular files. Now, let’s use git hash-object to create a new data object and manually store it in
your new Git database:
#>
$ echo 'test content' | git hash-object -w --stdin

<# In its simplest form, git hash-object would take the content you handed to it and merely return the
unique key that would be used to store it in your Git database. The -w option then tells the command
to not simply return the key, but to write that object to the database. Finally, the --stdin option tells
git hash-object to get the content to be processed from stdin; otherwise, the command would
expect a filename argument at the end of the command containing the content to be used.#>

<# The output from the above command is a 40-character checksum hash. This is the SHA-1 hash — a
checksum of the content you’re storing plus a header, which you’ll learn about in a bit. Now you
can see how Git has stored your data:
#>
$ find .git/objects -type f

<# If you again examine your objects directory, you can see that it now contains a file for that new
content. This is how Git stores the content initially — as a single file per piece of content, named
with the SHA-1 checksum of the content and its header. The subdirectory is named with the first 2
characters of the SHA-1, and the filename is the remaining 38 characters.#>

<# Once you have content in your object database, you can examine that content with the git cat-file
command. This command is sort of a Swiss army knife for inspecting Git objects. Passing -p to catfile instructs the command to first figure out the type of content, then display it appropriately:
#>
$ git cat-file -p d670460b4b4aece5915caf5c68d12f560a9fe3e4

<# Now, you can add content to Git and pull it back out again. You can also do this with content in files.
For example, you can do some simple version control on a file. First, create a new file and save its
contents in your database:
#>
$ echo 'version 1' > test.txt
$ git hash-object -w test.txt

# Then, write some new content to the file, and save it again:
$ echo 'version 2' > test.txt
$ git hash-object -w test.txt

# Your object database now contains both versions of this new file (as well as the first content you stored there):
$ find .git/objects -type f

<# At this point, you can delete your local copy of that test.txt file, then use Git to retrieve, from the
object database, either the first version you saved:#>
$ git cat-file -p 83baae61804e65cc73a7201a7252750c76066a30 > test.txt
$ cat test.txt

# or the second version:
#>
$ git cat-file -p 1f7a7a472abf3dd9643fd615f6da379c4acb3e3a > test.txt
$ cat test.txt

<# But remembering the SHA-1 key for each version of your file isn’t practical; plus, you aren’t storing
the filename in your system — just the content. This object type is called a blob. You can have Git tell
you the object type of any object in Git, given its SHA-1 key, with git cat-file -t:
#>
$ git cat-file -t 1f7a7a472abf3dd9643fd615f6da379c4acb3e3a

<# Tree Objects
The next type of Git object we’ll examine is the tree, which solves the problem of storing the
filename and also allows you to store a group of files together. Git stores content in a manner
similar to a UNIX filesystem, but a bit simplified. All the content is stored as tree and blob objects,
with trees corresponding to UNIX directory entries and blobs corresponding more or less to inodes
or file contents. A single tree object contains one or more entries, each of which is the SHA-1 hash
of a blob or subtree with its associated mode, type, and filename. For example, the most recent tree
in a project may look something like this:
#>
$ git cat-file -p master^{tree}

<# The master^{tree} syntax specifies the tree object that is pointed to by the last commit on your
master branch. Notice that the lib subdirectory isn’t a blob but a pointer to another tree:
#>
$ git cat-file -p 99f1a6d12cb4b6f19c8655fca46c3ecf317074e0

# Shell FACTS
<# Depending on what shell you use, you may encounter errors when using the
master^{tree} syntax.
In CMD on Windows, the ^ character is used for escaping, so you have to double it
to avoid this: git cat-file -p master^^{tree}. When using PowerShell, parameters
using {} characters have to be quoted to avoid the parameter being parsed
incorrectly: git cat-file -p 'master^{tree}'.
If you’re using ZSH, the ^ character is used for globbing, so you have to enclose the
whole expression in quotes: git cat-file -p "master^{tree}".
#>

<# You can fairly easily create your own tree. Git normally creates a tree by taking the state of your
staging area or index and writing a series of tree objects from it. So, to create a tree object, you first
have to set up an index by staging some files. To create an index with a single entry — the first
version of your test.txt file — you can use the plumbing command git update-index. You use this
command to artificially add the earlier version of the test.txt file to a new staging area. You must
pass it the --add option because the file doesn’t yet exist in your staging area (you don’t even have a
staging area set up yet) and --cacheinfo because the file you’re adding isn’t in your directory but is
in your database. Then, you specify the mode, SHA-1, and filename:
#>
$ git update-index --add --cacheinfo 100644 \ 83baae61804e65cc73a7201a7252750c76066a30 test.txt

<# In this case, you’re specifying a mode of 100644, which means it’s a normal file. Other options are
100755, which means it’s an executable file; and 120000, which specifies a symbolic link. The mode is
taken from normal UNIX modes but is much less flexible — these three modes are the only ones
that are valid for files (blobs) in Git (although other modes are used for directories and
submodules).#>

<# Now, you can use git write-tree to write the staging area out to a tree object. No -w option is
needed — calling this command automatically creates a tree object from the state of the index if
that tree doesn’t yet exist:
#>
$ git write-tree
$ git cat-file -p d8329fc1cc938780ffdd9f94e0d364e0ea74f579

# You can also verify that this is a tree object using the same git cat-file command you saw earlier:
$ git cat-file -t d8329fc1cc938780ffdd9f94e0d364e0ea74f579

# You’ll now create a new tree with the second version of test.txt and a new file as well:
$ echo 'new file' > new.txt
$ git update-index --add --cacheinfo 100644 \
  1f7a7a472abf3dd9643fd615f6da379c4acb3e3a test.txt
$ git update-index --add new.txt
<# Your staging area now has the new version of test.txt as well as the new file new.txt. Write out
that tree (recording the state of the staging area or index to a tree object) and see what it looks like:#>
$ git write-tree
$ git cat-file -p 0155eb4229851634a0f03eb265b69f5a2d56f341

<# Notice that this tree has both file entries and also that the test.txt SHA-1 is the “version 2” SHA-1
from earlier (1f7a7a). Just for fun, you’ll add the first tree as a subdirectory into this one. You can
read trees into your staging area by calling git read-tree. In this case, you can read an existing tree
into your staging area as a subtree by using the --prefix option with this command:
#>
$ git read-tree --prefix=bak d8329fc1cc938780ffdd9f94e0d364e0ea74f579
$ git write-tree
$ git cat-file -p 3c4e9cd789d88d8d89c1073707c3585e41b0e614

<# Commit Objects
If you’ve done all of the above, you now have three trees that represent the different snapshots of
your project that you want to track, but the earlier problem remains: you must remember all three
SHA-1 values in order to recall the snapshots. You also don’t have any information about who saved
the snapshots, when they were saved, or why they were saved. This is the basic information that
the commit object stores for you.
To create a commit object, you call commit-tree and specify a single tree SHA-1 and which commit
objects, if any, directly preceded it. Start with the first tree you wrote:
#>
$ echo 'First commit' | git commit-tree d8329f

<# You will get a different hash value because of different creation time and author
data. Moreover, while in principle any commit object can be reproduced precisely
given that data, historical details of this book’s construction mean that the printed
commit hashes might not correspond to the given commits. Replace commit and
tag hashes with your own checksums further in this chapter.
#>

# Now you can look at your new commit object with git cat-file:
$ git cat-file -p fdf4fc3

<# The format for a commit object is simple: it specifies the top-level tree for the snapshot of the
project at that point; the parent commits if any (the commit object described above does not have
any parents); the author/committer information (which uses your user.name and user.email
configuration settings and a timestamp); a blank line, and then the commit message.
Next, you’ll write the other two commit objects, each referencing the commit that came directly
before it:
#>
$ echo 'Second commit' | git commit-tree 0155eb -p fdf4fc3
$ echo 'Third commit' | git commit-tree 3c4e9c -p cac0cab

<# Each of the three commit objects points to one of the three snapshot trees you created. Oddly
enough, you have a real Git history now that you can view with the git log command, if you run it
on the last commit SHA-1:
#>
$ git log --stat 1a410e

<# Amazing. You’ve just done the low-level operations to build up a Git history without using any of
the front end commands. This is essentially what Git does when you run the git add and git commit
commands — it stores blobs for the files that have changed, updates the index, writes out trees, and
writes commit objects that reference the top-level trees and the commits that came immediately
before them. These three main Git objects — the blob, the tree, and the commit — are initially stored
as separate files in your .git/objects directory. Here are all the objects in the example directory
now, commented with what they store:
#>
$ find .git/objects -type f

<# Object Storage
We mentioned earlier that there is a header stored with every object you commit to your Git object
database. Let’s take a minute to see how Git stores its objects. You’ll see how to store a blob
object — in this case, the string “what is up, doc?” — interactively in the Ruby scripting language.
You can start up interactive Ruby mode with the irb command:#>
$ irb
>> content = "what is up, doc?"
=> "what is up, doc?"

<# Git first constructs a header which starts by identifying the type of object — in this case, a blob. To
that first part of the header, Git adds a space followed by the size in bytes of the content, and adding
a final null byte:
#>
>> header = "blob #{content.bytesize}\0"
=> "blob 16\u0000"

<# Git concatenates the header and the original content and then calculates the SHA-1 checksum of
that new content. You can calculate the SHA-1 value of a string in Ruby by including the SHA1
digest library with the require command and then calling Digest::SHA1.hexdigest() with the string:#>
>> store = header + content
=> "blob 16\u0000what is up, doc?"
>> require 'digest/sha1'
=> true
>> sha1 = Digest::SHA1.hexdigest(store)
=> "bd9dbf5aae1a3862dd1526723246b20206e5fc37"
<# Let’s compare that to the output of git hash-object. Here we use echo -n to prevent adding a
newline to the input.
#>
$ echo -n "what is up, doc?" | git hash-object --stdin

# Let’s compare that to the output of git hash-object. Here we use echo -n to prevent adding anewline to the input.
$ echo -n "what is up, doc?" | git hash-object --stdin

<# Git compresses the new content with zlib, which you can do in Ruby with the zlib library. First, you
need to require the library and then run Zlib::Deflate.deflate() on the content:#>
>> require 'zlib'
=> true
>> zlib_content = Zlib::Deflate.deflate(store)
=> "x\x9CK\xCA\xC9OR04c(\xCFH,Q\xC8,V(-\xD0QH\xC9O\xB6\a\x00_\x1C\a\x9D"

<# Finally, you’ll write your zlib-deflated content to an object on disk. You’ll determine the path of the
object you want to write out (the first two characters of the SHA-1 value being the subdirectory
name, and the last 38 characters being the filename within that directory). In Ruby, you can use the
FileUtils.mkdir_p() function to create the subdirectory if it doesn’t exist. Then, open the file with
File.open() and write out the previously zlib-compressed content to the file with a write() call on
the resulting file handle:#>
>> path = '.git/objects/' + sha1[0,2] + '/' + sha1[2,38]
=> ".git/objects/bd/9dbf5aae1a3862dd1526723246b20206e5fc37"
>> require 'fileutils'
=> true
>> FileUtils.mkdir_p(File.dirname(path))
=> ".git/objects/bd"
>> File.open(path, 'w') { |f| f.write zlib_content }
=> 32
# Let’s check the content of the object using git cat-file:
$ git cat-file -p bd9dbf5aae1a3862dd1526723246b20206e5fc37

<# That’s it – you’ve created a valid Git blob object.
All Git objects are stored the same way, just with different types – instead of the string blob, the
header will begin with commit or tree. Also, although the blob content can be nearly anything, the
commit and tree content are very specifically formatted.#>

<# Git References
If you were interested in seeing the history of your repository reachable from commit, say, 1a410e,
you could run something like git log 1a410e to display that history, but you would still have to
remember that 1a410e is the commit you want to use as the starting point for that history. Instead, it
would be easier if you had a file in which you could store that SHA-1 value under a simple name so
you could use that simple name rather than the raw SHA-1 value.
In Git, these simple names are called “references” or “refs”; you can find the files that contain those
SHA-1 values in the .git/refs directory. In the current project, this directory contains no files, but it
does contain a simple structure:#>
$ find .git/refs
.git/refs
.git/refs/heads
.git/refs/tags
$ find .git/refs -type f

<# To create a new reference that will help you remember where your latest commit is, you can
technically do something as simple as this:#>
$ echo 1a410efbd13591db07496601ebc7a059dd55cfe9 > .git/refs/heads/master

<# Now, you can use the head reference you just created instead of the SHA-1 value in your Git
commands:
#>
$ git log --pretty=oneline master

<# You aren’t encouraged to directly edit the reference files; instead, Git provides the safer command
git update-ref to do this if you want to update a reference:
#>
$ git update-ref refs/heads/master 1a410efbd13591db07496601ebc7a059dd55cfe9

<# That’s basically what a branch in Git is: a simple pointer or reference to the head of a line of work.
To create a branch back at the second commit, you can do this:
#>
$ git update-ref refs/heads/test cac0ca
# Your branch will contain only work from that commit down:
$ git log --pretty=oneline test
<# When you run commands like git branch <branch>, Git basically runs that update-ref command to
add the SHA-1 of the last commit of the branch you’re on into whatever new reference you want to
create.#>

<# The HEAD
The question now is, when you run git branch <branch>, how does Git know the SHA-1 of the last
commit? The answer is the HEAD file.
Usually the HEAD file is a symbolic reference to the branch you’re currently on. By symbolic
reference, we mean that unlike a normal reference, it contains a pointer to another reference.

<# However in some rare cases the HEAD file may contain the SHA-1 value of a git object. This happens
when you checkout a tag, commit, or remote branch, which puts your repository in "detached
HEAD" state.#>

# If you look at the file, you’ll normally see something like this:
$ cat .git/HEAD

# If you run git checkout test, Git updates the file to look like this:
$ cat .git/HEAD

<# When you run git commit, it creates the commit object, specifying the parent of that commit object
to be whatever SHA-1 value the reference in HEAD points to.
You can also manually edit this file, but again a safer command exists to do so: git symbolic-ref.
You can read the value of your HEAD via this command:
#>
$ git symbolic-ref HEAD

# You can also set the value of HEAD using the same command:
$ git symbolic-ref HEAD refs/heads/test
$ cat .git/HEAD

# You can’t set a symbolic reference outside of the refs style:
$ git symbolic-ref HEAD test

<# Tags
We just finished discussing Git’s three main object types (blobs, trees and commits), but there is a
fourth. The tag object is very much like a commit object — it contains a tagger, a date, a message,
and a pointer. The main difference is that a tag object generally points to a commit rather than a
tree. It’s like a branch reference, but it never moves — it always points to the same commit but
gives it a friendlier name.#>

<# As discussed in Git Basics, there are two types of tags: annotated and lightweight. You can make a
lightweight tag by running something like this:#>
$ git update-ref refs/tags/v1.0 cac0cab538b970a37ea1e769cbbde608743bc96d

<# That is all a lightweight tag is — a reference that never moves. An annotated tag is more complex,
however. If you create an annotated tag, Git creates a tag object and then writes a reference to
point to it rather than directly to the commit. You can see this by creating an annotated tag (using
the -a option):
#>
$ git tag -a v1.1 1a410efbd13591db07496601ebc7a059dd55cfe9 -m 'Test tag'

# Here’s the object SHA-1 value it created:
$ cat .git/refs/tags/v1.1

# Now, run git cat-file -p on that SHA-1 value:
$ git cat-file -p 9585191f37f7b0fb9444f35a9bf50de191beadc2

<# Notice that the object entry points to the commit SHA-1 value that you tagged. Also notice that it
doesn’t need to point to a commit; you can tag any Git object. In the Git source code, for example,
the maintainer has added their GPG public key as a blob object and then tagged it. You can view the
public key by running this in a clone of the Git repository: #>
$ git cat-file blob junio-gpg-pub

<# The Linux kernel repository also has a non-commit-pointing tag object — the first tag created points
to the initial tree of the import of the source code.#>

<# Remotes
The third type of reference that you’ll see is a remote reference. If you add a remote and push to it,
Git stores the value you last pushed to that remote for each branch in the refs/remotes directory.
For instance, you can add a remote called origin and push your master branch to it:
#>
$ git remote add origin git@github.com:schacon/simplegit-progit.git
$ git push origin master

<# Then, you can see what the master branch on the origin remote was the last time you
communicated with the server, by checking the refs/remotes/origin/master file:
#>
$ cat .git/refs/remotes/origin/master

<# Remote references differ from branches (refs/heads references) mainly in that they’re considered
read-only. You can git checkout to one, but Git won’t point HEAD at one, so you’ll never update it
with a commit command. Git manages them as bookmarks to the last known state of where those
branches were on those servers.#>

<# Packfiles
If you followed all of the instructions in the example from the previous section, you should now
have a test Git repository with 11 objects — four blobs, three trees, three commits, and one tag:
#>
$ find .git/objects -type f

<# Git compresses the contents of these files with zlib, and you’re not storing much, so all these files
collectively take up only 925 bytes. Now you’ll add some more sizable content to the repository to
demonstrate an interesting feature of Git. To demonstrate, we’ll add the repo.rb file from the Grit
library — this is about a 22K source code file:
#>
$ curl https://raw.githubusercontent.com/mojombo/grit/master/lib/grit/repo.rb >
repo.rb
$ git checkout master
$ git add repo.rb
$ git commit -m 'Create repo.rb'

<# If you look at the resulting tree, you can see the SHA-1 value that was calculated for your new
repo.rb blob object:
#>
$ git cat-file -p master^{tree}

# You can then use git cat-file to see how large that object is:
$ git cat-file -s 033b4468fa6b2a9547a70d88d1bbe8bf3f9ed0d5

<# At this point, modify that file a little, and see what happens:#>
$ echo '# testing' >> repo.rb
$ git commit -am 'Modify repo.rb a bit'

# Check the tree created by that last commit, and you see something interesting:
$ git cat-file -p master^{tree}

# The blob is now a different blob, which means that although you added only a single line to the end
# of a 400-line file, Git stored that new content as a completely new object:
$ git cat-file -s b042a60ef7dff760008df33cee372b945b6e884e

<# You have two nearly identical 22K objects on your disk (each compressed to approximately 7K).
Wouldn’t it be nice if Git could store one of them in full but then the second object only as the delta
between it and the first?#>

<# It turns out that it can. The initial format in which Git saves objects on disk is called a “loose” object
format. However, occasionally Git packs up several of these objects into a single binary file called a
“packfile” in order to save space and be more efficient. Git does this if you have too many loose
objects around, if you run the git gc command manually, or if you push to a remote server. To see
what happens, you can manually ask Git to pack up the objects by calling the git gc command:
#>
$ git gc

<# If you look in your objects directory, you’ll find that most of your objects are gone, and a new pair
of files has appeared:
#>
$ find .git/objects -type f

<# How does Git do this? When Git packs objects, it looks for files that are named and sized similarly,
and stores just the deltas from one version of the file to the next. You can look into the packfile and
see what Git did to save space. The git verify-pack plumbing command allows you to see what was
packed up:
#>
$ git verify-pack -v .git/objects/pack/pack

<# The Refspec
Throughout this book, we’ve used simple mappings from remote branches to local references, but
they can be more complex. Suppose you were following along with the last couple sections and had
created a small local Git repository, and now wanted to add a remote to it:
#>
$ git remote add origin https://github.com/schacon/simplegit-progit
# Running the command above adds a section to your repository’s .git/config file, specifying the

<# The format of the refspec is, first, an optional +, followed by <src>:<dst>, where <src> is the pattern
for references on the remote side and <dst> is where those references will be tracked locally. The +
tells Git to update the reference even if it isn’t a fast-forward.#>

<# In the default case that is automatically written by a git remote add origin command, Git fetches all
the references under refs/heads/ on the server and writes them to refs/remotes/origin/ locally. So,
if there is a master branch on the server, you can access the log of that branch locally via any of the
following:#>
$ git log origin/master
$ git log remotes/origin/master
$ git log refs/remotes/origin/master

<# They’re all equivalent, because Git expands each of them to refs/remotes/origin/master.
If you want Git instead to pull down only the master branch each time, and not every other branch
on the remote server, you can change the fetch line to refer to that branch only:#>
fetch = +refs/heads/master:refs/remotes/origin/master

<# This is just the default refspec for git fetch for that remote. If you want to do a one-time only fetch,
you can specify the specific refspec on the command line, too. To pull the master branch on the
remote down to origin/mymaster locally, you can run:#>
$ git fetch origin master:refs/remotes/origin/mymaster

<# You can also specify multiple refspecs. On the command line, you can pull down several branches
like so:
#>
$ git fetch origin master:refs/remotes/origin/mymaster \ topic:refs/remotes/origin/topic
<# In this case, the master branch pull was rejected because it wasn’t listed as a fast-forward reference.
You can override that by specifying the + in front of the refspec.
You can also specify multiple refspecs for fetching in your configuration file. If you want to always
fetch the master and experiment branches from the origin remote, add two lines:
#>
[remote "origin"]
  url = https://github.com/schacon/simplegit-progit
  fetch = +refs/heads/master:refs/remotes/origin/master
  fetch = +refs/heads/experiment:refs/remotes/origin/experiment

# Since Git 2.6.0 you can use partial globs in the pattern to match multiple branches, so this works:
fetch = +refs/heads/qa*:refs/remotes/origin/qa*

<# Even better, you can use namespaces (or directories) to accomplish the same with more structure.
If you have a QA team that pushes a series of branches, and you want to get the master branch and
any of the QA team’s branches but nothing else, you can use a config section like this:#>
[remote "origin"]
  url = https://github.com/schacon/simplegit-progit
  fetch = +refs/heads/master:refs/remotes/origin/master
  fetch = +refs/heads/qa/*:refs/remotes/origin/qa/*
<# If you have a complex workflow process that has a QA team pushing branches, developers pushing
branches, and integration teams pushing and collaborating on remote branches, you can
namespace them easily this way.
#>

<# Pushing Refspecs
It’s nice that you can fetch namespaced references that way, but how does the QA team get their
branches into a qa/ namespace in the first place? You accomplish that by using refspecs to push.
If the QA team wants to push their master branch to qa/master on the remote server, they can run:#>