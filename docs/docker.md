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

##### In console 2,  install yarn
`./run yarn`

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
`./run yarn watch`

##### You can go to http://localhost:5000

To get started, register your nonprofit using the "Get Started" link.