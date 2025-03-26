# CommitChange's version of Houdini

This is a Rails 4.2 app.

The frontend is written in a few custom frameworks, the largest of which is called Flimflam.
We endeavor to migrate to React as quickly as possible to increase development
comfort and speed.

All backend code and React components should be well-tested


## Prerequisites

Houdini is designed and tested to run with the following:

* Ruby 2.7
* Node 14
* PostgreSQL 12
* run on Heroku-20

## Dev Setup

#### Get the code
```bash
git clone https://github.com/Commitchange/houdini
git checkout supporter_level_goal
```

##### Get your .env file
If you don't already have access to the CommitChange 1Password vault, ask to be added. Then
download the .env file in 1Password and place it in the root directory.

> *Note:* Double check that your .env file has the '.' in front of the file name.

#### Dockerized
This is a work-in-progress method of running a development environment. The standard is still the bare metal instructions below.

Mac users can ignore this, but if your host machine is Linux, you might run into permission issues with the tmp files created by the postgres image. To proactively avoid this, run `cp docker-compose.override.yml.example docker-compose.override.yml` and change the values inside the newly copied file to match the output of `echo $(id -u):$(id -g)`

One-time setup:
```bash
touch ~/.netrc #prevents docker compose from creating it as a directory if you don't have it yet

docker-compose run web bin/rake db:setup
```

Running:
```bash
docker-compose up
```

Restoring the DB from Prod (Linux):
```bash
# Enter `password` when prompted for a password after the download step.
docker-compose exec web script/restore_from_heroku.sh
```

Restoring the DB from Prod (Mac). The above command will work on Mac, but will take an hour or more due to differences in how docker handles storage. Use the below to reduce how long it takes (will still take a long time).
```bash
curl -o ./tmp/shared/latest.dump `heroku pg:backups:url -a commitchange`

# Enter `password` when prompted for a password.
docker-compose exec db -e CC_PROD_DUMP_PATH="/tmp/shared/latest.dump" script/pg_restore_local_from_production.sh
```

#### One-time setup (Ubuntu)

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

> *Note*: We use [rbenv](https://github.com/rbenv/rbenv) to have more control over the exact version of
> Ruby. This tool is useful for switching between multiple Ruby versions on the same machine and for
> ensuring that each project you are working on always runs on the correct Ruby version. You could also
> build ruby from source.

> *Note*: We recommend building Ruby with jemalloc support as we
> do in these instructions. In practice, it manages memory far
> more efficiently in Rails-based projects.

> *Tip*: To get out of the root shell, run `exit`

Get the latest rbenv
```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
```
Add rbenv to bashrc:
```bash
echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
```
> *Note:* close and reopen your terminal.

Download the rbenv install feature:
```bash
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```
Ruby install
```bash
cd houdini
rbenv install 2.7
```

Run the following command as the `postgres` user and then enter your admin
password at the prompt.

> *Note*: For development, Houdini expects the password to be 'password'. This would be terrible
for production but for development, it's likely not a huge issue.

> *Tip*: To run this, add `sudo -u postgres ` to the beginning of the following command.

`createuser admin -s -d -P`

#### One-time setup (Mac)

Set your Ruby version with `rbenv`.

```bash
brew install rbenv
rbenv versions # see which ruby versions are already installed
rbenv install  # the app currently uses version 2.7.8
rbenv local # rbenv local --unset reverses the action

# To switch between rbenv versions installed locally, use the following command:
rbenv shell 2.7.8

```

Set your Node version with `NVM`.

```bash
brew install nvm
brew info nvm # command that shows the remaining steps to complete to install nvm properly
mkdir ~/.nvm
nvm install 14
nvm use 14
# Add the following lines to your ~/.bashprofile or ~/.zshrc:
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.zshrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.zshrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> ~/.zshrc

# Reference Stack Overflow post: https://stackoverflow.com/questions/53118850/brew-install-nvm-nvm-command-not-found
```

Make sure you've installed Yarn.

```bash
yarn --version
brew install yarn
```

Set your Postgres version with homebrew.

```bash
brew install postgresql@16
brew switch postgres@16

# To start postgres locally run:
brew services start postgresql@16

```

You might get segmentation faults if you don't configure `pg` with the correct macports. One of these should work.
```bash
gem install pg -- --with-pg-config="${HOMEBREW_PREFIX}/opt/libpq/bin/pg_config"
# Or?
bundle config build.pg --with-pg-config="${HOMEBREW_PREFIX}/opt/libpq/bin/pg_config"
```

You may also need to set the env variable `PGGSSENCMODE=disable` to resolve segmentation faults.

Create necessary postgres users in the `psql` console.

```bash
psql postgres # if this doesn't work, make sure postgres is running
CREATE ROLE admin WITH SUPERUSER CREATEDB LOGIN PASSWORD 'password';
CREATE ROLE postgres WITH SUPERUSER CREATEDB LOGIN PASSWORD 'password';
```

You may need to disable AirPlay Receiver in your System Settings if it is hogging port 5000.


#### System configuration (all)
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

If you get `ActiveRecord::NoDatabaseError` errors, run `bin/rake db:create:all` to make sure all the databases are built.

## Frontend

Assets get compiled from `/client` to `/public/client`

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

## (Mac Setup) Build for Production 
# In order to get prod env set, you need to download Github CLI and Heroku CLI. 

# Github CLI setup 
```
gh # to check if GH CLI has been downloaded 
brew install gh  # if GH CLI has not been downloaded
gh 
gh auth
gh auth login
```
# Answer the following questions: 
—? What account do you want to log into? GitHub.com
? What is your preferred protocol for Git operations? HTTPS
? Authenticate Git with your GitHub credentials? Yes
? How would you like to authenticate GitHub CLI? Login with a web browser
—copy one time code, and enter into browser 


# Heroku CLI setup 
```
brew tap heroku/brew && brew install heroku 
heroku login 
heroku git:remote —remote=production -a commitchange 
git branch 
git push production HEAD:master 
```

# One-time setup to build for production
```
git checkout supporter_level_goal
git pull 
git remote add private https://github.com/commitchange/deploy-houdini.git
git branch -u private/master PRIVATE_MASTER
git fetch private 
git checkout private/master
git switch -c PRIVATE_MASTER
git branch -u private/master PRIVATE_MASTER
git checkout private/prod_deploy
git switch -c PRIVATE_PROD_DEPLOY
git branch -u private/prod_deploy PRIVATE_PROD_DEPLOY
```

```
git checkout supporter_level_goal
./create_new_release.sh
git push private HEAD:master
git checkout PRIVATE_PROD_DEPLOY
git merge PRIVATE_MASTER
git push private HEAD:prod_deploy
npm run build-all-production
git add public
git commit -m "<a build message>"
git push private HEAD:prod_deploy
git push production HEAD:master
```
### Build for staging

* Run the workflow at https://github.com/CommitChange/deploy-houdini/actions/workflows/create-release.yml.
* Once the deploy finishes, increase ASSET_VERSION in https://dashboard.heroku.com/apps/commitchange-test/settings by 1
* To get the latest backup of the prod database on staging, you need to run the following command locally. NOTE: this will
override any changes you've made in the staging database.

```
heroku pg:backups:restore $(heroku pg:backups:url --app commitchange) --app commitchange-test
```


## Creating issues

* *I'm a community member* - You should file an issue upstream in https://github.com/houdiniproject/houdini

* *I work for CommitChange and...*
  * *this is a CommitChange issue* - create an issue in https://github.com/commitchange/tix
  * *this may be an issue upstream* - create an issue in https://github.com/commitchange/tix and maybe upstream. If you do file upstream, link to it the upstream issue in the tix issue.
