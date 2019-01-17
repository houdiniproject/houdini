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

This is a Rails 3.2 app; [we want to upgrade](https://github.com/houdiniproject/houdini/issues/47).

Much of the business logic is in `/lib`. 

The frontend is written in a few custom frameworks, the largest of which is called Flimflam. 
We endeavor to migrate to React as quickly as possible to increase development
comfort and speed.

All backend code and React components should be TDD.

## Get involved
Houdini's success depends on you!

### Join our Zulip chat
https://houdini.zulipchat.com

### Help with translations
Visit the Internationalization channel on Houdini Zulip and discuss
## Dev Setup

#### Get the code  
`git clone https://github.com/HoudiniProject/houdini`

#### Docker install (if you don't have docker and docker-compose installed)
##### install Docker and Docker compose
You need to install Docker and Docker Compose.
* *Note:* Docker and Docker Compose binaries from Docker itself are proprietary software based entirely upon
free software. If you feel more comfortable, you may build them from source.

* *Note 2:* For Debian, the Docker package is simply too out of date to be usable. 
Even the version for latest Ubuntu LTS  is too old. For reliability, we strongly
recommend using the Docker debian feed from docker itself OR making sure you keep your
own build up to date.

##### Add yourself to the docker group
Adding yourself as a Docker group user as follows:

`sudo usermod -aG docker $USER`

You will likely need to logout and log back in again.
 
#### Build your docker-container and start it up for initial set up.
We'll keep this running in the console we'll call **console 1**
```
./dc build
./dc up
```
#### System configuration
There are a number of steps for configuring your Houdini instance for startup
##### Start a new console we'll call **console 2**.

##### In console 2, copy the env template to your .env file
   ```
   cp .env.template .env
   ```
##### In console 2, run the following and copy the output to you .env file to set you `DEVISE_SECRET_KEY` environment variable.   
`./run rake secret # copy this result into your DEVISE_SECRET_KEY`

##### In console 2, , run the following and copy the output to you .env file to set you `SECRET_TOKEN` environment variable.
```
./run rake secret # copy this result into your SECRET_TOKEN
```

##### Set the following secrets in your .env file with your Stripe account information
- `STRIPE_API_KEY` with your Stripe PRIVATE key
- `STRIPE_API_PUBLIC` with your Stripe PUBLIC key

##### You SHOULD set your AMAZON s3 information (optional but STRONGLY recommended)
If you don't, file uploads WILL NOT WORK but it's not required.

##### In console 2,  install npm packages
`./run npm install`

##### In console 2, fill the db
`./run rake db:create db:structure:load db:seed test:prepare` 

##### Set up mailer info 
You can set this in `config/default_organization.yml` or better yet, make a copy with your own org name and add that to your .env file as `ORG_NAME`
If you need help setting up your mailer, visit `config/environment.rb` where the settings schema is verified and documented.

#### Startup
##### Switch back to console 1 and run `Ctrl-c` to end the session.

##### In console 1, restart the containers
`./dc up`

##### In console 2, run:
`./run npm run watch`

##### You can go to http://localhost:5000

To get started, register your nonprofit using the "Get Started" link.

## Additional info 

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

Providing the complete, corresponding source code (CCS) of your project is a requirement of some of the licensed used by Houdini. There are two methods for doing so right now:

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
