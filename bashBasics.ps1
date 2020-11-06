# bash basics

# carent path
pwd

# list files in documents {relative path}
ls Documents/

# change dir
cd Documents/

# change to home DIR
cd ~

# jump to this path
pushd /etc

# check file extantion
file etc

# find or search for files
locate fstab # wont work the first time i install it

# find ather commands
which cal

# history show
history

# get commad discription
whatis cal

# get which command to use
apropos time # this will give me all the commads i can use to work with time

# manual
man

# make 3 dir
mkdir siya dlamini twentySeven

# append data to a file or create file
touch

# change something in a file but have a copy
cp ~/.bashrc bashrc # copy file from home then work on it in this dir

 # move file or rename file
 mv bashrc.bak bashrc

 # delet file
 rm filename
 # rdelet everything in dir
 rm -r file 

 # remove emty folders
 rmdir *

 # show content in file
 cat file2

 # write to file using commad clt + d when im done typing
 cat >> file2

 # Concetinat
 cat file2 file2.txt

 # view content
 more file2

 # see content  
 less file2

 # piPning
 history l less # redaration

 # combining commands
 ls -al / > lsOutPut.txt