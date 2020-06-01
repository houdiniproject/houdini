[![](https://img.shields.io/badge/zulip-join_chat-brightgreen.svg)](https://houdini.zulipchat.com) [![Build Status](https://travis-ci.com/houdiniproject/houdini.svg?branch=master)](https://travis-ci.com/houdiniproject/houdini)

The Houdini Project is free and open source fundraising infrastructure. It includes...
- Crowdfunding campaigns
- Donate widget page and generator
- Fundraising events
- Nonprofit Profiles
- Nonprofit payment history and payouts dashboard
- Nonprofit recurring donation management dashboard
- Nonprofit metrics overview / business intelligence dashboard
- Nonprofit supporter relationship management dashboard (CRM)
- Nonprofit org user account management
- Simple donation management for donors

Much of the business logic is in `/lib`. 

The frontend is written in a few custom frameworks, the largest of which is called Flimflam. 
We endeavor to migrate to React as quickly as possible to increase development
comfort and speed.

All backend code and React components should be TDD.

## Prerequisites
Houdini is designed and tested to run with the following:
* Ruby 2.6
* Node 12
* Yarn
* PostgreSQL 11
* Ubuntu 20.04 or equivalent

## Get involved
Houdini's success depends on you!

### Join our Zulip chat
https://houdini.zulipchat.com

### Help with translations
Visit the Internationalization channel on Houdini Zulip and discuss

## Dev Setup
#### Tips for specific circumstances
* Docker: Docker was previously used for development of Houdini. 
See [docker.md](docs/docker.md) for more info.
* Mac: Mac dev setup may require some unique configuration. 
See [mac_getting_started.md](docs/mac_getting_started.md) for more info.

### Installation prep
Houdini requires a few pieces of software be installed, as well as some optional pieces
which make development much easier.

These include:

* PostgreSQL 12
* NodeJS 12 LTS
* Ruby 2.6.2 (NOTE: the default of Ruby 2.7.1 in Debian will likely function but you will receive a ton of deprecation warnings from Ruby)
* RVM (optional, simplifies managing multiple ruby versions)

#### One-time setup

You'll want to run the next commands as root or via sudo. You could do this by typing `sudo /bin/sh` running the commands from there.

TIP: this is the root shell. There's no restrictions on what you do here so be careful!
```bash
apt update
apt install curl -yy
curl -sL https://deb.nodesource.com/setup_12.x | bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt update
apt install git postgresql-12 libpq-dev libjemalloc-dev libvips42 yarn -yy
```

You'll run the next commands as your normal user.

NOTE: in the case of a production instance, this might be
your web server's user.

NOTE 2: We use [RVM](https://rvm.io) to have more control over the exact version of Ruby. For development, it's also way easier because you can
use a consistent version of Ruby (and different sets of installed gems) for different projects. You could also use rbenv
or simply build ruby from source.

NOTE 3: We don't recommend using Ruby 2.7, the current Ubuntu default at this time. Ruby 2.7 will function but spits out tons
of deprecation warnings when using Rails applications.

TIP: To get out of the root shell, run `exit`

```bash
# add rvm keys
curl -sSL https://rvm.io/mpapis.asc | gpg --import -
curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
curl -sSL https://get.rvm.io | bash -s stable
source $HOME/.rvm/scripts/rvm
echo 'source "$HOME/.rvm/scripts/rvm"' >> ~/.bashrc
rvm install 2.6.6 --disable-binary --with-jemalloc
```

 Run the following command as the `postgres` user and then enter your houdini_user
 password at the prompt.

NOTE: For development, Houdini expects the password to be 'password'. This would be terrible
for production but for development, it's likely not a huge issue.

TIP: To run this, add `sudo -u postgres ` to the beginning of the following command.

`createuser houdini_user -s -d -P`

Now that we have all of our prerequisites prepared, we need to get the Houdini code.

`git clone https://github.com/HoudiniProject/houdini`

This will download the latest Houdini code. Change to the 
`houdini` directory and we can set the rest of Houdini up.

Let's run the Houdini project setup and we'll be ready to go!

```bash
bin/setup
```

NOTE: The .env file holds your environment variables for development; on production you might
have these set somewhere else other than this file.

TIP: On Heroku, the environment variables are set in your Dashboard.

Also, you should set the STRIPE_API_KEY and STRIPE_API_PUBLIC environment variables which you'd get from the Stripe dashboard. On your development environment, make sure to use test keys. If you don't, you're
going to be charged real money!

#### Startup
`bin/rails server`
You can connect to your server at http://localhost:5000

##### Super admin
There is a way to set your user as a super_admin. This role lets you access any of the nonprofits
on your Houdini instance. Additionally, it gives you access to the super admin control panel to search all supporters and
nonprofits, which is located at `/admin` url.
  
To create the super user, go to the rails console by calling:

`./dc run web rails console`

In the console, run the following:
 
```
admin=User.find(1) #or the id of the user you want to add the role
role=Role.create(user:admin,name: "super_admin")
```

## Known Issues
For a list of [how to solve known issues](docs/KNOWN_ISSUES.MD)


## To run in production

##### Docker
While Docker should be very possible to use for production, the current Docker solution
is optimized heavily for dev purposes. If you know more about creating a solid production Docker setup, please do
contribute!

(To be continued)
- rake assets:precompile
- if production: make sure memcached is running.


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
