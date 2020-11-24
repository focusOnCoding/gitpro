<# Exporting Your Repository
Git attribute data also allows you to do some interesting things when exporting an archive of your
project.#>
export-ignore

<#You can tell Git not to export certain files or directories when generating an archive. If there is a
subdirectory or file that you don’t want to include in your archive file but that you do want checked
into your project, you can determine those files via the export-ignore attribute.
For example, say you have some test files in a test/ subdirectory, and it doesn’t make sense to
include them in the tarball export of your project. You can add the following line to your Git
attributes file:
#>
test/ export-ignore

<# Now, when you run git archive to create a tarball of your project, that directory won’t be included
in the archive.
export-subst
When exporting files for deployment you can apply git log's formatting and keyword-expansion
processing to selected portions of files marked with the export-subst attribute.
For instance, if you want to include a file named LAST_COMMIT in your project, and have metadata
about the last commit automatically injected into it when git archive runs, you can for example set
up your .gitattributes and LAST_COMMIT files like this:
LAST_COMMIT export-subst
#>
echo 'Last commit date: $Format:%cd by %aN$' > LAST_COMMIT
git add LAST_COMMIT .gitattributes
git commit -am 'adding LAST_COMMIT file for archives'
#When you run git archive, the contents of the archived file will look like this:
git archive HEAD | tar xCf ../deployment-testing -
cat ../deployment-testing/LAST_COMMIT

<# The substitutions can include for example the commit message and any git notes, and git log can
do simple word wrapping:
#>
echo '$Format:Last commit: %h by %aN at %cd%n%+w(76,6,9)%B$' > LAST_COMMIT
git commit -am 'export-subst uses git log'\''s custom formatter
git archive @ | tar xfO - LAST_COMMIT

<# Merge Strategies
You can also use Git attributes to tell Git to use different merge strategies for specific files in your
project. One very useful option is to tell Git to not try to merge specific files when they have
conflicts, but rather to use your side of the merge over someone else’s.
This is helpful if a branch in your project has diverged or is specialized, but you want to be able to
merge changes back in from it, and you want to ignore certain files. Say you have a database
settings file called database.xml that is different in two branches, and you want to merge in your
other branch without messing up the database file. You can set up an attribute like this:#>
database.xml merge=ours
# And then define a dummy ours merge strategy with:
git config --global merge.ours.driver true

<# If you merge in the other branch, instead of having merge conflicts with the database.xml file, you
see something like this:#>
git merge topic

#In this case, database.xml stays at whatever version you originally had

