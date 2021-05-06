[![](https://img.shields.io/badge/zulip-join_chat-brightgreen.svg)](https://houdini.zulipchat.com)
![Houdini build](https://github.com/houdiniproject/houdini/workflows/Houdini%20build/badge.svg)

> *Note*: This is the latest version (pre-2.0) of Houdini and
> is currently in HEAVY development. You may want
> to use
> [v1](https://github.com/houdiniproject/houdini/tree/1-0-stable)
> instead.

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

The frontend is written in a few custom frameworks, the largest of which is called Flimflam. 
We endeavor to migrate to React as quickly as possible to increase development
comfort and speed.

All new backend code and React components well tested.

## Prerequisites

Houdini is designed and tested to run with the following:

* Ruby 2.6
* Node 14
* Yarn
* PostgreSQL 10  or 12
* Ubuntu 18.04, 20.04 or equivalent

## Get involved

Houdini's success depends on you!

### Join our Zulip chat

https://houdini.zulipchat.com

### Help with translations

Visit the Internationalization channel on Houdini Zulip and discuss

### Help with usability tests

Check on [contribution_guide_usability_testing.md](docs/contribution_guide_usability_testing.md) and create an issue with your test design or run test sessions for [opened usability testing issues](https://github.com/houdiniproject/houdini/issues?q=is%3Aissue+is%3Aopen+%5BUX%5D+).

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

* PostgreSQL 12 (10 probably works)
* NodeJS 14 (we require 14 because we want the full internationalization built-in)
* Ruby 2.7.2

There a few optional tools which make working on Houdini
easier

* Ruby Version Manager (RVM) - RVM makes it simple to switch
between versions of Ruby for different projects. Additionally, you can
use different "gemsets" per version so you can separate the
state of a set of different projects. It will also switch
versions at the console when you change to a directory for
an project prepared for RVM, like Houdini.
* Automatic Version Switching for Node (AVN) - similar to RVM, AVN makes it simple to switch between versions of Node. When
properly configured, it automatically switches version at
the console whe you change to a directory for a project
prepared for AVN, like Houdini.

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
rvm install 2.7.2 --disable-binary --with-jemalloc
```

 Run the following command as the `postgres` user and then enter your houdini_user
 password at the prompt.

> *Note*: For development, Houdini expects the password to be 'password'. This would be terrible
for production but for development, it's likely not a huge issue.

> *Tip*: To run this, add `sudo -u postgres ` to the beginning of the following command.

`createuser houdini_user -s -d -P`

Now that we have all of our prerequisites prepared, we need to get the Houdini code.

`git clone https://github.com/HoudiniProject/houdini`

This will download the latest Houdini code. Change to the 
`houdini` directory and we can set the rest of Houdini up.

Let's run the Houdini project setup and we'll be ready to go!
P
```bash
bin/setup
```

> *Note*: The .env file holds your environment variables for development; on production you might
> have these set somewhere else other than this file.

> *Tip*: On Heroku, the environment variables are set in your Dashboard.

Also, you should set the STRIPE_API_KEY and STRIPE_API_PUBLIC
environment variables which you'd get from the Stripe
dashboard. On your development environment,
make sure to use test keys. If you don't, you're
going to be charged real money!

#### Testing

To verify everying is set up correctly, you can try running through the test cases:

```bash
./bin/rails spec
```

You should expect to see the output of the test execution,
including messages about pending test cases, and 
eventually get the output to the effect of below:

```text
Finished in 6 minutes 25 seconds (files took 10.35 seconds to load)
2433 examples, 0 failures, 42 pending

Coverage report generated for RSpec to .../houdini/coverage. 10552 / 12716 LOC (82.98%) covered.
```

The important thing to look for is that the number of
failures is zero.

##### Creating your first nonprofits and user

To create a nonprofit, use the command line to run the following command and fill in the questions with the required information:

```bash
bin/rails houdini:nonprofit:create
```

There are available arguments that add congirugrations on the nonprofit's creation:

```bash
  -su, [--super-admin], [--no-super-admin]     # Make the nonprofit admin a super user (they can access any nonprofit's dashboards)
      [--confirm-admin], [--no-confirm-admin]  # Require the nonprofit admin to be confirmed via email
                                               # Default: true
```

Additionally, it is possible to provide arguments to fill in the fields for the nonprofit creation without coming across the questions:

```bash
      [--nonprofit-name=NONPROFIT_NAME]        # Provide the nonprofit's name
      [--state-code=STATE_CODE]                # Provide the nonprofit' state code
      [--city=CITY]                            # Provide the nonprofit's city
      [--nonprofit-website=NONPROFIT_WEBSITE]  # Provide the nonprofit public website
      [--nonprofit-email=NONPROFIT_EMAIL]      # Provide the nonprofit public email
      [--user-name=USER_NAME]                  # Provide the nonprofit's admin's name
      [--user-email=USER_EMAIL]                # Provide the nonprofit's admin's email address (It'll be used for logging in)
      [--user-phone=USER_PHONE]                # [OPTIONAL] Provide the nonprofit's 's phone
      [--user-password=USER_PASSWORD]          # Provide the nonprofit's admin's password
```

You can use this in the future for creating additional nonprofits.
#### Startup

`bin/rails server`
You can connect to your server at http://localhost:5000


##### Super admin

There is a way to set your user as a super_admin. This role lets you access any of the nonprofits
on your Houdini instance. Additionally, it gives you access to the super admin control panel to search all supporters and
nonprofits, which is located at `/admin` url.
  
To create the super user, go to the rails console by calling:

`bin/rails console`

In the console, run the following:

```ruby
admin=User.find(1) #or the id of the user you want to add the role
role=Role.create(user:admin,name: "super_admin")
```

#### Code Analysis

We use `Rubocop` to perform static code analysis:

```bash
rubocop
```

## Known Issues

For a list of [how to solve known issues](docs/KNOWN_ISSUES.MD)

## Run in production

You will likely want to make a few changes in your configuration of Houdini before running in production as you
would for any Rails project. These include:

* Use a [proper cache store](https://guides.rubyonrails.org/caching_with_rails.html#cache-stores). The development uses
 `memory_store` which isn't shared between processes or server
 and clears every time your server software restarts. Memcached
 or Redis are good choices here.

### Providing the complete corresponding source code

> **Note: This is not legal advice and provides a suggestion which may be compliant. You should talk with your legal counsel if you have
> questions or concerns with how to comply with the various licenses of Houdini.**

Providing the complete, corresponding source code (CCS) of your project is a requirement of some of the licenses used by Houdini. There are two methods for doing so right now:

1. Providing a tarball of the current running code
2. Providing a link to Github where the code is pulled from

The easiest method is to provide a tarball. Houdini automatically provides a link on the Terms & Privacy page which generates a tarball for the current running code at runtime.
For this to work though, the following characteristics must be true:

* Your have to have committed any changes you made to the project in `HEAD` in your git repository
* The `.git` folder for your repository must be a direct subfolder of your `$RAILS_ROOT`
* Your web server must be able to run `git archive`
