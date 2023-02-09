## Commit Policies

### Simple Cases

#### IMPORTANT: This method is recommended for simple commits, simple alterations on the code. With the issue tagged, is possible to know, premeditatedly, if a Issue is still open and live. Most of the work will use this commit format, because of the highly friendly and simple way to do. 

Commits are essential for tracking changes and additions to the project.

The imperative mode (assertive actions and orders) should be used to mention what was done.

If the commit concerns a simple issue, make the commit as follows:

```git
git commit -m "#IdIssue - Message"
```


### A more Complex Case

#### IMPORTANT: Is just necessary to keep in mind to use this method only in the case that the commit it's not about some usual fix, a quickly alteration, or addition of a small snippet of code. This method is for more complex alteration. Do not use in case of a simple commit. Pair programming, per example, can make use of this form better than the simpler form. One more time, if your alterarion is very simple, we encourage you to use the simple way, like was said before - just type "git commit -m "#idIssue - Message" and go on. 

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

finally, it is totally possible to change the commit body text



## Pull Request Policies
To join branches to the main, we have to make a Pull Request (PR), pointing what about the problem (solved or not is), what was done, and what issue(or issues) were resolved. To make a more complete PR, it is suggested the template below:

####  IMPORTANT: It's recommended use the <b>WIP</b> term in case of the Pull Request is a work-in-progress. This term indicates that: the code has not finished, wants a feedback of the present work until now, or just use the CI infrastructure of the project. To use this, just type [WIP] on a prefix of a Pull Request that you are working on. This trick helps a lot the manager of the project. 

```markdown

# About the description

Include here a little overview of what was changed and the Issue that you worked(are working), with the context. List all dependences that are not concluded for this PR be considered finished. Is very important cite if the issue is closed or not.
Here you can put images too, if this will help you to explain the work. 


## The types of changes made


- [ ] Bug fix 
- [ ] New Feature 
- [ ] Breaking change - means some alterations that can break or change the current system functioning
- [ ] Document alteration

# How was tested

Describe the tests you ran to validate the code. 

# Checklist:

- [ ] My code follows the project principles.
- [ ] I revised my code.
- [ ] I commented my codes to help other person who will read it later
- [ ] My contribution does not generates problem or error to run the code.
- [ ] I tested my code to validate the solution. 

```

