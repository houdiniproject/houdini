# CommitChange's version of Houdini

This is a Rails 4.2 app.

The frontend is written in a few custom frameworks, the largest of which is called Flimflam. 
We endeavor to migrate to React as quickly as possible to increase development
comfort and speed.

All backend code and React components should be well-tested


## Prerequisites

Houdini is designed and tested to run with the following:

* Ruby 2.6
* Node 14
* PostgreSQL 12
* run on Heroku-20

## Dev Setup

#### Get the code  
```bash
git clone https://github.com/Commitchange/houdini
git checkout supporter_level_goal
```

#### One-time setup

You'll want to run the next commands as root or via sudo (for Ubuntu 18.04 users or anyone running ProgresSQL 10, change "postgresql-12" below to "postgresql-10"). You could do this by typing `sudo /bin/sh` running the commands from there.

```bash
apt update
apt install curl -yy
curl -sL https://deb.nodesource.com/setup_14.x | bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt update
apt install git postgresql-12 libpq-dev libjemalloc-dev libvips42 yarn -yy
```

You'll run the next commands as your normal user.

> *Note*: in the case of a production instance, this might be
> your web server's user.

> *Note*: We use [RVM](https://rvm.io) to have more control over the exact version of Ruby. For development, it's also way easier because you can
> use a consistent version of Ruby (and different sets of installed gems) for different projects. You could also use rbenv
> or simply build ruby from source.

> *Note*: We recommend building Ruby with jemalloc support as we
> do in these instructions. In practice, it manages memory far
> more efficiently in Rails-based projects.

> *Tip*: To get out of the root shell, run `exit`

```bash
# add rvm keys
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable
source $HOME/.rvm/scripts/rvm
echo 'source "$HOME/.rvm/scripts/rvm"' >> ~/.bashrc
rvm install 2.6.10 --disable-binary --with-jemalloc
```

 Run the following command as the `postgres` user and then enter your houdini_user
 password at the prompt.

> *Note*: For development, Houdini expects the password to be 'password'. This would be terrible
for production but for development, it's likely not a huge issue.

> *Tip*: To run this, add `sudo -u postgres ` to the beginning of the following command.

`createuser houdini_user -s -d -P`

Now that we have all of our prerequisites prepared, we need to get the Houdini code.

`git clone https://github.com/CommitChange/houdini`
#### System configuration
There are a number of steps for configuring your Houdini instance for startup
##### Run bin/setup
```sh
bin/setup
```
#### Startup
##### run foreman for development

When you run foreman in dev, you start up the server, the job runner and webpack.
```sh
foreman start
```
## Frontend

Assets get compiled from `/client` to `/public/client`

## React Generators
If creating new React or Typescript code,  please use the Rails generators with the 'react:' prefix. This include:

### react:packroot
This generator creates a new entry for Webpack. This is a place where Webpack will start
when packing a new javascript output file. It also creates a corresponding component for the entry.
Usually, you will have one of these per page.

### react:component
This generator creates a React component along with a test file for testing with Jest. 
Each component should have its own file. 

### react:lib
This generator creates a basic Typescript module along with a test file.

## Documentation

You can get generate documentation for the Ruby source by running:

`bundle exec yard doc`

Alternatively, you can have it run in local webserver and autoupdate by running:

`bundle exec yard server -r`

### Providing the complete corresponding source code

**Note: This is not legal advice and provides a suggestion which may be compliant. You should talk with your legal counsel if you have
questions or concerns with how to comply with the various licenses of Houdini**

Providing the complete, corresponding source code (CCS) of your project is a requirement of some of the licenses used by Houdini. There are two methods for doing so right now:

1. Providing a tarball of the current running code
2. Providing a link to Github where the code is pulled from

The easiest method is to provide a tarball. Houdini automatically provides a link on the Terms & Privacy page which generates a tarball for the current running code at runtime.
For this to work though, the following characteristics must be true:

* Your have to have committed any changes you made to the project in `HEAD` in your git repository
* The `.git` folder for your repository must be a direct subfolder of your `$RAILS_ROOT`
* Your web server must be able to run `git archive`.


### Style

#### Ruby
- 2 spaces for tabs

#### New frontend code
- All new front end code should be written in Typescript 
and React (using TSX files). Please use the React Generators for creation.
- 2 spaces for tabs

#### Legacy Javascript
- 2 spaces for tabs
- Comma-led lines
- ES6 imports

#### Git

- No need to rebase, just merge


## How to build releases at CommitChange

### Build for production

* Make your changes on `supporter_level_goal` (or any branch in the public houdini repo) and commit
* Push your changes to remote
* Run `./create_new_release.sh`. This moves you to `PRIVATE_MASTER` (ask Eric for the remote and access) and merges the changes.
* Push to remote for `PRIVATE_MASTER`
* Checkout `PRIVATE_PROD_DEPLOY`
*`git merge PRIVATE_PROD_MASTER`
* If you have changes on assets or on javascript, then run: `./run_production yarn build-all`. After that finishes, run `git add public` and then `git commit`
* If no changes on assets or javascript, don’t do the last step
* Push to the remote for `PRIVATE_PROD_DEPLOY` (ask Eric for the remote and access)
* Push to heroku production  using `git commit production PRIVATE_PROD_DEPLOY:master` ( ask Eric for access to `production`)

### Build for staging

* Make your changes on `supporter_level_goal` (or any branch in the public houdini repo) and commit
* Push your changes to remote
* Run `./create_new_staging_release.sh`. This moves you to `PRIVATE_STAGING_MASTER` and merges the changes.
* Push to remote for `PRIVATE_STAGING_MASTER` (ask Eric for remote and access)
* Checkout `PRIVATE_STAGING_DEPLOY`
* `git merge PRIVATE_STAGING_MASTER`
* If you have changes on assets or on javascript, then run: `./run_staging yarn build-all-staging`. After that finishes, run `git add public` and then `git commit`
* If no changes on assets or javascript, don’t do the last step
* Push to the remote for `PRIVATE_STAGING_DEPLOY` (ask Eric for remote and access)
* Push to heroku staging using `git commit cc-test PRIVATE_STAGING_DEPLOY:master` (ask Eric for access to production)

## Creating issues

* *I'm a community member* - You should file an issue upstream in https://github.com/houdiniproject/houdini

* *I work for CommitChange and...*
  * *this is a CommitChange issue* - create an issue in https://github.com/commitchange/tix
  * *this may be an issue upstream* - create an issue in https://github.com/commitchange/tix and maybe upstream. If you do file upstream, link to it the upstream issue in the tix issue.
