<# Credential Storage
If you use the SSH transport for connecting to remotes, it’s possible for you to have a key without a
passphrase, which allows you to securely transfer data without typing in your username and
password. However, this isn’t possible with the HTTP protocols – every connection needs a
username and password. This gets even harder for systems with two-factor authentication, where
the token you use for a password is randomly generated and unpronounceable.#>

<# Fortunately, Git has a credentials system that can help with this. Git has a few options provided in
the box:
• The default is not to cache at all. Every connection will prompt you for your username and
password.
• The “cache” mode keeps credentials in memory for a certain period of time. None of the
passwords are ever stored on disk, and they are purged from the cache after 15 minutes.
• The “store” mode saves the credentials to a plain-text file on disk, and they never expire. This
means that until you change your password for the Git host, you won’t ever have to type in your
credentials again. The downside of this approach is that your passwords are stored in cleartext
in a plain file in your home directory.
• If you’re using a Mac, Git comes with an “osxkeychain” mode, which caches credentials in the
secure keychain that’s attached to your system account. This method stores the credentials on
disk, and they never expire, but they’re encrypted with the same system that stores HTTPS
certificates and Safari auto-fills.
• If you’re using Windows, you can install a helper called “Git Credential Manager for Windows.”
This is similar to the “osxkeychain” helper described above, but uses the Windows Credential
Store to control sensitive information. It can be found at https://github.com/Microsoft/GitCredential-Manager-for-Windows.
You can choose one of these methods by setting a Git configuration value:
#>
git config --global credential.helper cache

<# Some of these helpers have options. The “store” helper can take a --file <path> argument, which
customizes where the plain-text file is saved (the default is ~/.git-credentials). The “cache” helper
accepts the --timeout <seconds> option, which changes the amount of time its daemon is kept
running (the default is “900”, or 15 minutes). Here’s an example of how you’d configure the “store”
helper with a custom file name:#>
git config --global credential.helper 'store --file ~/.my-credentials'
<# Git even allows you to configure several helpers. When looking for credentials for a particular host,
Git will query them in order, and stop after the first answer is provided. When saving credentials,
Git will send the username and password to all of the helpers in the list, and they can choose what
to do with them. Here’s what a .gitconfig would look like if you had a credentials file on a thumb
drive, but wanted to use the in-memory cache to save some typing if the drive isn’t plugged in:
#>
[credential]

<# Under the Hood
How does this all work? Git’s root command for the credential-helper system is git credential,
which takes a command as an argument, and then more input through stdin.
This might be easier to understand with an example. Let’s say that a credential helper has been
configured, and the helper has stored credentials for mygithost. Here’s a session that uses the “fill”
command, which is invoked when Git is trying to find credentials for a host:
#>
git credential fill ①
protocol=https ②
host=mygithost ③
protocol=https ④
host=mygithost
username=bob
password=s3cre7
git credential fill ⑤
protocol=https
host=unknownhost
Username for 'https://unknownhost': bob
Password for 'https://bob@unknownhost':
protocol=https
host=unknownhost
username=bob
password=s3cre7

# Here’s the same example from above, but skipping git-credential and going straight for gitcredential-store:
git credential-store --file ~/git.store store ①
<#protocol=https
host=mygithost
username=bob
password=s3cre7
#>
git credential-store --file ~/git.store get ②
#Here’s what the ~/git.store file looks like:
https://bob:s3cre7@mygithost

<# A Custom Credential Cache
Given that git-credential-store and friends are separate programs from Git, it’s not much of a leap
to realize that any program can be a Git credential helper. The helpers provided by Git cover many
common use cases, but not all. For example, let’s say your team has some credentials that are
shared with the entire team, perhaps for deployment. These are stored in a shared directory, but
you don’t want to copy them to your own credential store, because they change often. None of the
existing helpers cover this case; let’s see what it would take to write our own. There are several key
features this program needs to have:
Once again, we’ll write this extension in Ruby, but any language will work so long as Git can
execute the finished product. Here’s the full source code of our new credential helper:
341
#!/usr/bin/env ruby
require 'optparse'
path = File.expand_path '~/.git-credentials' ①
OptionParser.new do |opts|
  opts.banner = 'USAGE: git-credential-read-only [options] <action>'
  opts.on('-f', '--file PATH', 'Specify path for backing store') do |argpath|
  path = File.expand_path argpath
  end
end.parse!
exit(0) unless ARGV[0].downcase == 'get' ②
exit(0) unless File.exists? path
known = {} ③
while line = STDIN.gets
  break if line.strip == ''
  k,v = line.strip.split '=', 2
  known[k] = v
end
File.readlines(path).each do |fileline| ④
  prot,user,pass,host = fileline.scan(/^(.*?):\/\/(.*?):(.*?)@(.*)$/).first
  if prot == known['protocol'] and host == known['host'] and user ==
known['username'] then
  puts "protocol=#{prot}"
  puts "host=#{host}"
  puts "username=#{user}"
  puts "password=#{pass}"
  exit(0)
  end
end
#>

<# We’ll save our helper as git-credential-read-only, put it somewhere in our PATH and mark it
executable. Here’s what an interactive session looks like:
#>
git credential-read-only --file=/mnt/shared/creds get

<# Since its name starts with “git-”, we can use the simple syntax for the configuration value:
$ git config --global credential.helper 'read-only --file /mnt/shared/creds'
As you can see, extending this system is pretty straightforward, and can solve some common
problems for you and your team.
#>