# combining commands
 ls -al / > lsOutPut.tx

 # working with users
 sudo -s # always super user
 exit # back to reguler user

 # change to another user
 su - siyabonga # change to siyabongs home dir

 #! deanguros 
 su - # home/root.

 # get more inforemation about users
 id 

 # File Pamissions 
 ls -l # show long list

 # if i wrote a bash script from a file 
 # and now what to make that a executeble exe id do the below
chmod +X file2.txt # make this file exe

# MAKE MYSELF THE ONLY PERSON WHO CAN USE THE FILE 
chomd 700 file2.txt