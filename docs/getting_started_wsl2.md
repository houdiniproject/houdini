# Getting Started Using WSL2 (Windows Subsystem for Linux)

## Installation prep

Houdini requires a few pieces of software to be installed, as well as some
optional pieces that make development much easier.

These include:

* PostgreSQL 12 (10 probably works)
* NodeJS 14 (we require 14 because we want the full internationalization built-in)
* Ruby 2.7.8

There are a few optional tools that make working on Houdini easier:

* RBENV - rbenv is a version manager tool for the Ruby programming language on
Unix-like systems. It is useful for switching between multiple Ruby versions on
the same machine and for ensuring that each project you are working on always
runs on the correct Ruby version.
* Automatic Version Switching for Node (AVN) - similar to RVM, AVN makes it
simple to switch between versions of Node. When properly configured,
it automatically switches version at the console when you change to a directory
for a project prepared for AVN, like Houdini.

### One-time setup

You'll want to run the next commands as root. You could do this by typing
`sudo /bin/sh` and running the commands from there, or `sudo su`.

> Note: you can also run the following commands in the Windows terminal to
change the Ubuntu user to root:
>
>#### Ubuntu 20.04
>
>`ubuntu2004 config --default-user root`
>
>#### Ubuntu 18.04
>
>`ubuntu1804 config --default-user root`
>
>To revert to using the default user of Ubuntu, simply execute the command
`ubuntu2004 config --default-user 'your-default-user'`

#### Curl install

```bash
apt update
apt install curl -yy
```

#### Node and Yarn install

```bash
curl -sL https://deb.nodesource.com/setup_14.x | bash -
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
apt update
```

#### Postgres install

```bash
apt install git postgresql-12 libpq-dev libjemalloc-dev libvips42 yarn -yy
```

You'll run the next commands as your normal user.

> Note: in the case of a production instance, this might be your web server's user.
> Note: We use [RBENV](https://https://github.com/rbenv/rbenv.io) inside the
project folder to have more control over the exact version of Ruby.
> Tip: To get out of the root shell, run `exit`

Run the following command as the `postgres` user and then enter your
`houdini_user` password at the prompt.

**Note: For development, Houdini expects the password to be 'password'.**
**This would be terrible for production, but for development, it's likely not a**
**huge issue.**

#### Create user account for the database connection

```bash
sudo -u postgres createuser houdini_user -s -d -P
```

Now that we have all of our prerequisites prepared, we need to get the Houdini code.

#### Cloning project

```bash
git clone https://github.com/HoudiniProject/houdini
```

This will download the latest Houdini code.

Let's run the Houdini project setup, and we'll be ready to go!

#### Get the latest rbenv

```bash
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
```

#### Add rbenv to bashrc

```bash
echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc
```

> Note: close and reopen your terminal.

#### Download the rbenv install feature

```bash
git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
```

#### Ruby install

```bash
rbenv install 2.7.8
```

> Note: if a build failure occurs, installing the following packages may solve
the problem:

```bash
sudo apt install make build-essential libxml2 libssl-dev zlib1g-dev -y
```

#### Setup project

> Note: First, make sure that the PostgreSQL service is running.

```bash
sudo service postgresql status # for checking the status of your database.
sudo service postgresql start # to start running your database.
```

```bash
cd houdini
bin/setup
```

> *Note*: The `.env` file holds your environment variables for development;
on production, you might have these set somewhere else other than this file.
> *Tip*: On Heroku, the environment variables are set in your Dashboard.

Also, you should set the `STRIPE_API_KEY` and `STRIPE_API_PUBLIC` environment
variables, which you'd get from the Stripe dashboard. On your development
environment, make sure to use test keys. If you don't, you're going to be
charged real money!

### Stripe keys setup

#### Get Stripe keys

Go to [Stripe](https://stripe.com), create an account, or just log in if you
already have one. Access the Stripe dashboard and copy both the publishable and
secret keys.

> Make sure to use test keys. If you don't, you're going to be charged real money!

![get Stripe keys](https://user-images.githubusercontent.com/31708472/157132661-79bf89a0-13cb-4860-9793-a40bb3229bfb.png)

#### Configure the `.env` file

Then, after retrieving both keys, copy them into your `.env` file on these lines:

```bash
export STRIPE_API_KEY='REPLACE' # use your test private key from your Stripe account
export STRIPE_API_PUBLIC='REPLACE' # use your test public key from your Stripe account
```

### Testing

To verify everything is set up correctly, you can try running through the Ruby
test cases:

```bash
./bin/rails spec
```

You should expect to see the output of the test execution, including messages
about pending test cases, and eventually get the output to the effect of below:

```bash
Finished in 6 minutes 25 seconds (files took 10.35 seconds to load)
2433 examples, 0 failures, 42 pending

Coverage report generated for RSpec to .../houdini/coverage. 10552 / 12716 LOC 
(82.98%) covered.
```

The important thing to look for is that the number of failures is zero.

We also recommend you run through the JavaScript test cases by running:

```bash
yarn test:js
```

Lastly, you can use [Storybook](https://storybook.js.org/) to experiment with
the various new React components.

```bash
yarn storybook
```

If you create a new React component, make sure you add a Storybook and Jest
tests for that component!

#### Creating your first nonprofits and user

To create a nonprofit, use the command line to run the following command and fill
in the questions with the required information:

```bash
bin/rails houdini:nonprofit:create
```

There are available arguments that add configurations on the nonprofit's creation:

```bash
# Make the nonprofit admin a superuser (they can access any nonprofit's dashboards)
-s, [--super-admin], [--no-super-admin]
# Autoconfirm the admin instead of waiting for them to click the email link
[--confirm-admin], [--no-confirm-admin]  
# Default: true
```

Additionally, it is possible to provide arguments to fill in the fields for the
nonprofit creation without coming across the questions:

```bash
 # Provide the nonprofit's name
[--nonprofit-name=NONPROFIT_NAME]
 # Provide the nonprofit's state code     
[--state-code=STATE_CODE]
# Provide the nonprofit's city            
[--city=CITY]         
# [OPTIONAL] Provide the nonprofit public website                    
[--nonprofit-website=NONPROFIT_WEBSITE]
# [OPTIONAL] Provide the nonprofit public email   
[--nonprofit-email=NONPROFIT_EMAIL]
# [OPTIONAL] Provide the nonprofit's phone
[--nonprofit-phone=NONPROFIT_PHONE]
# Provide the nonprofit's admin's name
[--user-name=USER_NAME]
# Provide the nonprofit's admin's email address (It'll be used for logging in)
[--user-email=USER_EMAIL]
# Provide the nonprofit's admin's password
[--user-password=USER_PASSWORD]      
```

You can use this in the future for creating additional nonprofits.

### Startup

```bash
bin/rails server
```

You can connect to your server at [http://localhost:5000]

#### Super admin

There is a way to set your user as a super_admin. This role lets you access any
of the nonprofits on your Houdini instance. Additionally, it gives you access
to the super admin control panel to search all supporters and nonprofits, which
is located at `/admin` URL.

To create the super user, go to the Rails console by calling:

```bash
bin/rails console
```

In the console, run the following:

```ruby
admin = User.find(1) # or the ID of the user you want to add the role
role = Role.create(user: admin, name: "super_admin")
```

#### Code Analysis

We use `Rubocop` to perform static code analysis:

```bash
rubocop
```
