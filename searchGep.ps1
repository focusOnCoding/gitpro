<# Searching
With just about any size codebase, you’ll often need to find where a function is called or defined, or
display the history of a method. Git provides a couple of useful tools for looking through the code
and commits stored in its database quickly and easily. We’ll go through a few of them.
Git Grep
Git ships with a command called grep that allows you to easily search through any committed tree,
the working directory, or even the index for a string or regular expression. For the examples that
follow, we’ll search through the source code for Git itself.
By default, git grep will look through the files in your working directory. As a first variation, you
can use either of the -n or --line-number options to print out the line numbers where Git has found
matches:
#>
git grep -n gmtime_r

<# In addition to the basic search shown above, git grep supports a plethora of other interesting
options.
For instance, instead of printing all of the matches, you can ask git grep to summarize the output
by showing you only which files contained the search string and how many matches there were in
each file with the -c or --count option:
#>
git grep --count gmtime_r