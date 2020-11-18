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

# MAKE MYSELF THE ONLY PERSON WHO CAN USE THE FILE 7=W 4=R 1=X
chomd 700 file2.txt
chmod 744 file2.txt # now other people can also read this file
# standat Pamission
chmod 644 file2.txt # or 755 is the one to use on executeble  files

# kill programmes
kill firefox # end firefox process

watch # rerun every two seconds
watch free -h # see how much free memory my PC: has