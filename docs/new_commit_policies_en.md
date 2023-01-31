## Commit Policies

### First Case

Commits are essential for tracking changes and additions to the project.

The imperative mode (assertive actions and orders) should be used to mention what was done.

If the commit concerns a simple issue, make the commit as follows:

```git
git commit -m "#IdIssue - Message"
```
### A more complex case 

Due to its importance, if the commit concerns something more complex, use the following template for standardization, replacing the text of the comments '# will not be read in the commit':

```txt
. #Id-of-Issue - Commit title: start with capital letter, objective
# No more than 50 chars, this line has 50                   #
#Skip line

# Body: Explain what and why
# No more than 72 characters (this line has)                                                                             #

#OPTIONAL: If there is, include this line of co-authors of your commit for each contributor.
#Skip 2 lines


# Co-authored-by: name1 <user1@users.noreply.github.com>
# Co-authored-by: name2 <user2@users.noreply.github.com>
#Skip line

```

To use the template, add the template file .gitmessage, being in your local repository folder, at the root, as follows:



```git
git config commit.template .gitmessage
```

Or, you can just create a file .gitmessage and add the commit body suggest above. Next time you make the commit, just type "git commit", and a text editor will apears(in my case, VIM). Fill all the commit body with the data you want to describe.  

Finally, it is totally possible to change the commit body text
