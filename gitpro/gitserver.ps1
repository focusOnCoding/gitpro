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