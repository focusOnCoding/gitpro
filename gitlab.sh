#Basic Usage
#The first thing you’ll want to do with GitLab is create a new project. You can do this by clicking on
#the “+” icon on the toolbar. You’ll be asked for the project’s name, which namespace it should
#belong to, and what its visibility level should be. Most of what you specify here isn’t permanent,
#and can be changed later through the settings interface. Click “Create Project”, and you’re done.

#Once the project exists, you’ll probably want to connect it with a local Git repository. Each project is
#accessible over HTTPS or SSH, either of which can be used to configure a Git remote. The URLs are
#visible at the top of the project’s home page. For an existing local repository, this command will
#create a remote named gitlab to the hosted location:
$ git remote add gitlab https://server/namespace/project.git
#If you don’t have a local copy of the repository, you can simply do this:
$ git clone https://server/namespace/project.git
#The web UI provides access to several useful views of the repository itself. Each project’s home page
#shows recent activity, and links along the top will lead you to views of the project’s files and commit
#log*/