# Introduction

Thank you for your interest in contributing to Houdini! This guide aims to facilitate contribution to our project. Follow all the steps below to submit your contribution:

1. Fork the Repository
2. Comment "**WIP**" on the existing Issue or create an issue according to the implemented issue templates.
3. Create a Branch in Your Fork according to the [Branch Creation Rules](#branch-creation-rules) and make your commits following the [commit creation policies](#commit-policy).

4. After finishing the changes, make a pull request following the [pull request policies](#pull-request-policy).



## Branch Creation Rules

To create branches, use the issue number you're working on, followed by a brief title describing what will be done, as shown in the example below:

```bash
git checkout -b #42/Bug_Fixes_and_Improvements
```

## Commit Policy

* Use clear and descriptive commit messages.
* Include the issue number at the beginning of the commit message: `[#42]`.
  
Example commit message:
```bash
git commit -m "(#42) Implementation of XYZ function"
```

## Pull Request Policy

To create a pull request, follow the defined template below:

### Related Issues:
- #Issue_number

### Description:
Description of what this request will change in the project.

### Changes Made:
_**`Type of change`**_
- Project documentation update.
- Bug fixes.
- Implementation of new features.


Thank you for your contribution! We are looking forward to reviewing your PR and incorporating your changes into the project.