# Introduction

Thank you for your interest in contributing to Houdini! This guide aims to facilitate contribution to our project. Follow all the steps below to submit your contribution:

1. Fork the repository.
2. Choose an existing issue or create a new one following the available templates.
3. Create a branch in your fork following the branch [creation template](#branch-creation-rules), make commits following the established 
[commit policies](#commit-policy), and open a draft PR.
4. Comment on the issue indicating that you're working on resolving the described problem, including the number of the opened PR.
## Branch Creation Rules

To create branches, use the issue number you're working on, followed by a brief title describing what will be done, as shown in the example below:

```bash
git checkout -b #42/Bug_Fixes_and_Improvements
```

## Commit Policy

To make a commit, follow the format indicated below, using one of the suggested prefixes:

Available prefixes  for commits:

* [feat]: For added features.
* [fix]: For bug fixes.
* [refactor]: For code changes that improve structure or readability.
* [docs]: For changes exclusively in the documentation.

Example commit with the [feat] tag:

```bash
git commit -m "[feat] Add support for OAuth2 authentication"
```


Thank you for your contribution! We are looking forward to reviewing your PR and incorporating your changes into the project.