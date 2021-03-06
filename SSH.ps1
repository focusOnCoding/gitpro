#ssh
ssh-keygen

# You will see the following text:
# Generating public/private rsa key pair.
# Enter file in which to save the key 
(/home/username/.ssh/id_rsa)
# Press enter to save your keys to the default /home/username/.ssh directory.
# Then you'll be prompted to enter a password: 
Enter passphrase (empty for no passphrase):

<# Manage Multiple SSH Keys
Though it's considered good practice to have only one public-private key pair per device,
sometimes you need to use multiple keys or you have unorthodox key names. For
example, you might be using one SSH key pair for working on your company's internal
projects, but you might be using a different key for accessing a client's servers. On top of
that, you might be using a different key pair for accessing your own private server.
Managing SSH keys can become cumbersome as soon as you need to use a second key.
Traditionally, you would use ssh-add to store your keys to ssh-agent , typing in the
password for each key. The problem is that you would need to do this every time you
restart your computer, which can quickly become tedious.
A better solution is to automate adding keys, store passwords, and to specify which key
to use when accessing certain servers.
SSH config
Enter SSH config , which is a per-user conguration le for SSH communication. Create
a new le: ~/.ssh/config and open it for editing:
#>
nano ~/.ssh/config

<# Managing Custom Named SSH key
The rst thing we are going to solve using this config le is to avoid having to add
custom-named SSH keys using ssh-add . Assuming your private SSH key is named ~/.ss
h/id_rsa , add following to the config le:#>
Host github.com
 HostName github.com
 User git
 IdentityFile ~/.ssh/id_rsa
 IdentitiesOnly yes

<# Next, make sure that ~/.ssh/id_rsa is not in ssh-agent by opening another terminal
and running the following command:#>
ssh-add -D

<# This command will remove all keys from currently active ssh-agent session.
Now if you try closing a GitHub repository, your config le will use the key at ~/.ssh/i
da_rsa .Here are some other useful conguration examples:
#>
Host bitbucket-corporate
 HostName bitbucket.org
 User git
 IdentityFile ~/.ssh/id_rsa_corp
 IdentitiesOnly yes
 
# Now you can use git clone git@bitbucket-corporate:company/project.git
Host bitbucket-personal
 HostName bitbucket.org
 User git
 IdentityFile ~/.ssh/id_rsa_personal
 IdentitiesOnly yes
# Now you can use git clone git@bitbucket-personal:username/other-pi-project.git
Host myserver
 HostName ssh.username.com
 Port 1111
 IdentityFile ~/.ssh/id_rsa_personal
 IdentitiesOnly yes
 User username
 IdentitiesOnly yes

# Now you can SSH into your server using ssh myserver . You no longer need to enter a
# port and username every time you SSH into your private server.

<# Password management
The last piece of the puzzle is managing passwords. It can get very tedious entering a
password every time you initialize an SSH connection. To get around this, we can use the
password management software that comes with macOS and various Linux
distributions.
For this tutorial we will use macOS's Keychain Access program. Start by adding your key
to the Keychain Access by passing -K option to the ssh-add command:#>
ssh-add -K ~/.ssh/id_rsa_whatever

<# But if you remove the keys from ssh-agent with ssh-add -D or restart your computer,
you will be prompted for password again when you try to use SSH. Turns out there's one
more hoop to jump through. Open your SSH config le by running nano ~/.ssh/config
and add the following:#>
Host *
 AddKeysToAgent yes
 UseKeychain yes
<# With that, whenever you run ssh it will look for keys in Keychain Access. If it nds one,
you will no longer be prompted for a password. Keys will also automatically be added to
ssh-agent every time you restart your machin#>