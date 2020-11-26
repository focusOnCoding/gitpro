# Graphical Interfaces
<# gitk and git-gui
When you install Git, you also get its visual tools, gitk and git-gui.
gitk is a graphical history viewer. Think of it like a powerful GUI shell over git log and git grep.
This is the tool to use when you’re trying to find something that happened in the past, or visualize
your project’s history.#>

# Gitk is easiest to invoke from the command-line. Just cd into a Git repository, and type:
$ gitk [git log options]

<# Gitk accepts many command-line options, most of which are passed through to the underlying git
log action. Probably one of the most useful is the --all flag, which tells gitk to show commits
reachable from any ref, not just HEAD. Gitk’s interface looks like this:
#>

<# On the top is something that looks a bit like the output of git log --graph; each dot represents a
commit, the lines represent parent relationships, and refs are shown as colored boxes. The yellow
dot represents HEAD, and the red dot represents changes that are yet to become a commit. At the
bottom is a view of the selected commit; the comments and patch on the left, and a summary view

<# on the right. In between is a collection of controls used for searching history.
git-gui, on the other hand, is primarily a tool for crafting commits. It, too, is easiest to invoke from
the command line:
#>
$ git gui

<# Git in Visual Studio
Starting with Visual Studio 2013 Update 1, Visual Studio users have a Git client built directly into
their IDE. Visual Studio has had source-control integration features for quite some time, but they
were oriented towards centralized, file-locking systems, and Git was not a good match for this
workflow. Visual Studio 2013’s Git support has been separated from this older feature, and the
result is a much better fit between Studio and Git.
To locate the feature, open a project that’s controlled by Git (or just git init an existing project),
and select View > Team Explorer from the menu. You’ll see the "Connect" view, which looks a bit
like this:
#>

<# Git in Visual Studio Code
Visual Studio Code has git support built in. You will need to have git version 2.0.0 (or newer)
installed.
The main features are:
• See the diff of the file you are editing in the gutter.
• The Git Status Bar (lower left) shows the current branch, dirty indicators, incoming and
outgoing commits.
• You can do the most common git operations from within the editor:
◦ Initialize a repository.
◦ Clone a repository.
◦ Create branches and tags.
◦ Stage and commit changes.
◦ Push/pull/sync with a remote branch.
◦ Resolve merge conflicts.
◦ View diffs.
• With an extension, you can also handle GitHub Pull Requests:
#>

<# Git in Bash
If you’re a Bash user, you can tap into some of your shell’s features to make your experience with
Git a lot friendlier. Git actually ships with plugins for several shells, but it’s not turned on by
default.

<# First, you need to get a copy of the contrib/completion/git-completion.bash file out of the Git source
code. Copy it somewhere handy, like your home directory, and add this to your .bashrc:#>
. ~/git-completion.bash

# Once that’s done, change your directory to a Git repository, and type:#>
$ git chec<tab>
<# …and Bash will auto-complete to git checkout. This works with all of Git’s subcommands,
command-line parameters, and remotes and ref names where appropriate.
It’s also useful to customize your prompt to show information about the current directory’s Git
repository. This can be as simple or complex as you want, but there are generally a few key pieces
of information that most people want, like the current branch, and the status of the working
directory. To add these to your prompt, just copy the contrib/completion/git-prompt.sh file from
Git’s source repository to your home directory, add something like this to your .bashrc:
#>
. ~/git-prompt.sh
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\w$(__git_ps1 " (%s)")\$ '

<# Git in PowerShell
The legacy command-line terminal on Windows (cmd.exe) isn’t really capable of a customized Git
experience, but if you’re using PowerShell, you’re in luck. This also works if you’re running
PowerShell Core on Linux or macOS. A package called posh-git (https://github.com/dahlbyk/poshgit) provides powerful tab-completion facilities, as well as an enhanced prompt to help you stay on
top of your repository status. It looks like this

<# Installation
Prerequisites (Windows only)
Before you’re able to run PowerShell scripts on your machine, you need to set your local
ExecutionPolicy to RemoteSigned (basically, anything except Undefined and Restricted). If you choose
AllSigned instead of RemoteSigned, also local scripts (your own) need to be digitally signed in order
to be executed. With RemoteSigned, only scripts having the ZoneIdentifier set to Internet (were
downloaded from the web) need to be signed, others not. If you’re an administrator and want to set
it for all users on that machine, use -Scope LocalMachine. If you’re a normal user, without
administrative rights, you can use -Scope CurrentUser to set it only for you.

More about PowerShell Scopes: https://docs.microsoft.com/en-us/powershell/module/
microsoft.powershell.core/about/about_scopes.

More about PowerShell ExecutionPolicy: https://docs.microsoft.com/en-us/powershell/module/
microsoft.powershell.security/set-executionpolicy.#>

# To set the value of ExecutionPolicy to RemoteSigned for all users use the next command:
Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force
<# PowerShell Gallery
If you have at least PowerShell 5 or PowerShell 4 with PackageManagement installed, you can use
the package manager to install posh-git for you.

<# More information about PowerShell Gallery: https://docs.microsoft.com/en-us/powershell/scripting/
gallery/overview. #>
Install-Module posh-git -Scope CurrentUser -Force
Install-Module posh-git -Scope CurrentUser -AllowPrerelease -Force # Newer beta
# version with PowerShell Core support

<# If you want to install posh-git for all users, use -Scope AllUsers instead and execute the command
from an elevated PowerShell console. If the second command fails with an error like Module
'PowerShellGet' was not installed by using Install-Module, you’ll need to run another command
first: #>
Install-Module PowerShellGet -Force -SkipPublisherCheck

<# Then you can go back and try again. This happens, because the modules that ship with Windows
PowerShell are signed with a different publishment certificate.

<# Update PowerShell Prompt
To include git information in your prompt, the posh-git module needs to be imported. To have poshgit imported every time PowerShell starts, execute the Add-PoshGitToProfile command which will
add the import statement into your $profile script. This script is executed everytime you open a
new PowerShell console. Keep in mind, that there are multiple $profile scripts. E. g. one for the
console and a separate one for the ISE. #>
Import-Module posh-git
Add-PoshGitToProfile -AllHosts
<# From Source
Just download a posh-git release from https://github.com/dahlbyk/posh-git/releases, and
uncompress it. Then import the module using the full path to the posh-git.psd1 file:#>
Import-Module <path-to-uncompress-folder>\src\posh-git.psd1
Add-PoshGitToProfile -AllHosts

<# This will add the proper line to your profile.ps1 file, and posh-git will be active the next time you
open PowerShell.
For a description of the Git status summary information displayed in the prompt see:
https://github.com/dahlbyk/posh-git/blob/master/README.md#git-status-summary-information For
more details on how to customize your posh-git prompt see: https://github.com/dahlbyk/posh-git/
blob/master/README.md#customization-variables.
#>