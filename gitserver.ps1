<# The Protocols
Git can use four distinct protocols to transfer data: Local, HTTP, Secure Shell (SSH) and Git. Here
we’ll discuss what they are and in what basic circumstances you would want (or not want) to use
them#>

# local Protocol
<# The most basic is the Local protocol, in which the remote repository is in another directory on the
same host. This is often used if everyone on your team has access to a shared filesystem such as an
NFS mount, or in the less likely case that everyone logs in to the same computer. The latter wouldn’t
be ideal, because all your code repository instances would reside on the same computer, making a
catastrophic loss much more likely#>

<# If you have a shared mounted filesystem, then you can clone, push to, and pull from a local filebased repository. To clone a repository like this, or to add one as a remote to an existing project, use
the path to the repository as the URL. For example, to clone a local repository, you can run
something like this:#>
git clone /srv/git/project.git
# Or you can do this:
git clone file:///srv/git/project.git
<# Git operates slightly differently if you explicitly specify file:// at the beginning of the URL. If you
just specify the path, Git tries to use hardlinks or directly copy the files it needs. If you specify
file://, Git fires up the processes that it normally uses to transfer data over a network, which is
generally much less efficient. The main reason to specify the file:// prefix is if you want a clean
copy of the repository with extraneous references or objects left out — generally after an import
from another VCS or something similar (see Git Internals for maintenance tasks). We’ll use the
normal path here because doing so is almost always faster.
To add a local repository to an existing Git project, you can run something like this:
#>
git remote add local_proj /srv/git/project.git

# To add a local repository to an existing Git project, you can run something like this:
git remote add local_proj /srv/git/project.git

<# If the server does not respond with a Git HTTP smart service, the Git client will try to fall back to the
simpler Dumb HTTP protocol. The Dumb protocol expects the bare Git repository to be served like
normal files from the web server. The beauty of Dumb HTTP is the simplicity of setting it up.
Basically, all you have to do is put a bare Git repository under your HTTP document root and set up
a specific post-update hook, and you’re done (See Git Hooks). At that point, anyone who can access
the web server under which you put the repository can also clone your repository. To allow read
access to your repository over HTTP, do something like this:#>
cd /var/www/htdocs/
git clone --bare /path/to/git_project gitproject.git
cd gitproject.git
mv hooks/post-update.sample hooks/post-update
chmod a+x hooks/post-update
# to clone the above
git clone https://example.com/gitproject.git

<# The SSH Protocol
A common transport protocol for Git when self-hosting is over SSH. This is because SSH access to
servers is already set up in most places — and if it isn’t, it’s easy to do. SSH is also an authenticated
network protocol and, because it’s ubiquitous, it’s generally easy to set up and use.
To clone a Git repository over SSH, you can specify an ssh:// URL like this:#>
git clone ssh://[user@]server/project.git
# Or you can use the shorter scp-like syntax for the SSH protocol:
git clone [user@]server:project.git

#! SHH FACTS
<# The Pros
The pros of using SSH are many. First, SSH is relatively easy to set up — SSH daemons are
commonplace, many network admins have experience with them, and many OS distributions are
set up with them or have tools to manage them. Next, access over SSH is secure — all data transfer
is encrypted and authenticated. Last, like the HTTPS, Git and Local protocols, SSH is efficient,
making the data as compact as possible before transferring it.
The Cons
The negative aspect of SSH is that it doesn’t support anonymous access to your Git repository. If
you’re using SSH, people must have SSH access to your machine, even in a read-only capacity,
which doesn’t make SSH conducive to open source projects for which people might simply want to
clone your repository to examine it. If you’re using it only within your corporate network, SSH may
be the only protocol you need to deal with. If you want to allow anonymous read-only access to
your projects and also want to use SSH, you’ll have to set up SSH for you to push over but
something else for others to fetch from.
#>

<# The Git Protocol
Finally, we have the Git protocol. This is a special daemon that comes packaged with Git; it listens
on a dedicated port (9418) that provides a service similar to the SSH protocol, but with absolutely
no authentication. In order for a repository to be served over the Git protocol, you must create a
git-daemon-export-ok file — the daemon won’t serve a repository without that file in it — but, other
than that, there is no security. Either the Git repository is available for everyone to clone, or it isn’t.
This means that there is generally no pushing over this protocol. You can enable push access but,
given the lack of authentication, anyone on the internet who finds your project’s URL could push to
that project. Suffice it to say that this is rare.
#>

#! SETTING UP A SERVER
<# n order to initially set up any Git server, you have to export an existing repository into a new bare
repository — a repository that doesn’t contain a working directory. This is generally
straightforward to do. In order to clone your repository to create a new bare repository, you run the
clone command with the --bare option. By convention, bare repository directory names end with
the suffix .git, like so:
#>
git clone --bare my_project my_project.git
<# You should now have a copy of the Git directory data in your my_project.git directory.
This is roughly equivalent to something like:
#>
cp -Rf my_project/.git my_project.git

<# Putting the Bare Repository on a Server
Now that you have a bare copy of your repository, all you need to do is put it on a server and set up
your protocols. Let’s say you’ve set up a server called git.example.com to which you have SSH
access, and you want to store all your Git repositories under the /srv/git directory. Assuming that
/srv/git exists on that server, you can set up your new repository by copying your bare repository
over:#>
scp -r my_project.git user@git.example.com:/srv/git
# At this point, other users who have SSH-based read access to the /srv/git directory on that server can clone your repository by running:
git clone user@git.example.com:/srv/git/my_project.git
<# If a user SSHs into a server and has write access to the /srv/git/my_project.git directory, they will
also automatically have push access.
#>

<# Git will automatically add group write permissions to a repository properly if you run the git init
command with the --shared option. Note that by running this command, you will not destroy any
commits, refs, etc. in the process.#>
ssh user@git.example.com
cd ./srv/git/my_project.git
git init --bare --shared

<# Generating Your SSH Public Key
Many Git servers authenticate using SSH public keys. In order to provide a public key, each user in
your system must generate one if they don’t already have one. This process is similar across all
operating systems. First, you should check to make sure you don’t already have a key. By default, a
user’s SSH keys are stored in that user’s ~/.ssh directory. You can easily check to see if you have a
key already by going to that directory and listing the contents:
#>
ls
cd ~/.ssh
authorized_keys2  id_dsa       known_hosts
config            id_dsa.pub

<# You’re looking for a pair of files named something like id_dsa or id_rsa and a matching file with a
.pub extension. The .pub file is your public key, and the other file is the corresponding private key. If
you don’t have these files (or you don’t even have a .ssh directory), you can create them by running
a program called ssh-keygen, which is provided with the SSH package on Linux/macOS systems and
comes with Git for Windows:
#>
ssh-keygen -o
<# Now, each user that does this has to send their public key to you or whoever is administrating the
Git server (assuming you’re using an SSH server setup that requires public keys). All they have to
do is copy the contents of the .pub file and email it.#>

<# Setting Up the Server
Let’s walk through setting up SSH access on the server side. In this example, you’ll use the
authorized_keys method for authenticating your users. We also assume you’re running a standard
Linux distribution like Ubuntu.
A good deal of what is described here can be automated by using the ssh-copy-id
command, rather than manually copying and installing public keys.
First, you create a git user account and a .ssh directory for that user.
#>
sudo adduser git
su gitmkdir .ssh && chmod 700 .ssh
cd
touch .ssh/authorized_keys && chmod 600 .ssh/authorized_keys

<# Next, you need to add some developer SSH public keys to the authorized_keys file for the git user.
Let’s assume you have some trusted public keys and have saved them to temporary files. Again, the
public keys look something like this:
#>
cat /tmp/id_rsa.john.pub
# You just append them to the git user’s authorized_keys file in its .ssh directory:
#!{this is the group of people that have sent me theyer public keys and this is how i addthem to the git users .ssh dir}
cat /tmp/id_rsa.john.pub >> ~/.ssh/authorized_keys
cat /tmp/id_rsa.josie.pub >> ~/.ssh/authorized_keys
cat /tmp/id_rsa.jessica.pub >> ~/.ssh/authorized_keys
<# Now, you can set up an empty repository for them by running git init with the --bare option,
which initializes the repository without a working directory:#>
$ cd /srv/git
mkdir project.git
cd project.git
git init --bare
<# Then, John, Josie, or Jessica can push the first version of their project into that repository by adding
it as a remote and pushing up a branch. Note that someone must shell onto the machine and create
a bare repository every time you want to add a project. Let’s use gitserver as the hostname of the
server on which you’ve set up your git user and repository. If you’re running it internally, and you
set up DNS for gitserver to point to that server, then you can use the commands pretty much as is
(assuming that myproject is an existing project with files in it):
#>
# on John's computer
cd myproject
git init
git add .
git commit -m 'Initial commit'
git remote add origin git@gitserver:/srv/git/project.git
git push origin master
# that this point, the others can clone it down and push changes back up just as easily:
git clone git@gitserver:/srv/git/project.git
cd project
vim README
git commit -am 'Fix for README file'
git push origin master
<# You should note that currently all these users can also log into the server and get a shell as the git
user. If you want to restrict that, you will have to change the shell to something else in the
/etc/passwd file.
#>

<# You can easily restrict the git user account to only Git-related activities with a limited shell tool
called git-shell that comes with Git. If you set this as the git user account’s login shell, then that
account can’t have normal shell access to your server. To use this, specify git-shell instead of bash
or csh for that account’s login shell. To do so, you must first add the full pathname of the git-shell
command to /etc/shells if it’s not already there:
#>
cat /etc/shells   # see if git-shell is already in there. If not...
which git-shell   # make sure git-shell is installed on your system.
sudo -e /etc/shells  # and add the path to git-shell from last command
# Now you can edit the shell for a user using chsh <username> -s <shell>:
sudo chsh git -s $(which git-shell)

<# At this point, users are still able to use SSH port forwarding to access any host the git server is able
to reach. If you want to prevent that, you can edit the authorized_keys file and prepend the
following options to each key you’d like to restrict:
#>
no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty

# Git Daemon git protocall no sercuoe
<# Next we’ll set up a daemon serving repositories using the “Git” protocol. This is a common choice
for fast, unauthenticated access to your Git data. Remember that since this is not an authenticated
service, anything you serve over this protocol is public within its network.#>
git daemon --reuseaddr --base-path=/srv/git/ /srv/git/

<# Since systemd is the most common init system among modern Linux distributions, you can use it for
that purpose. Simply place a file in /etc/systemd/system/git-daemon.service with these contents:
#>
[Unit]
Description=Start Git Daemon
[Service]
ExecStart=/usr/bin/git daemon --reuseaddr --base-path=/srv/git/ /srv/git/
Restart=always
RestartSec=500ms
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=git-daemon
User=git
Group=git
[Install]
WantedBy=multi-user.target

<# Next, you have to tell Git which repositories to allow unauthenticated Git server-based access to.
You can do this in each repository by creating a file named git-daemon-export-ok.
#>
cd /path/to/project.git
touch git-daemon-export-ok
# The presence of that file tells Git that it’s OK to serve this project without authentication.

