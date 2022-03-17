# Production deployment

## System requirements

Webpack currently requires more than 2GB RAM to build the JavaScript assets, so
a server with 3-4GB RAM is likely required. Optimisations may be possible, but
due to the bootstrap-loader integration we can't currently switch to a newer
Webpack.


## Production mode

Running `bin/rails server` will by default start Houdini/Rails in "development"
mode (`Rails.env == "development"`). This flag is used to conditionally
configure various aspects of the application such as the database settings
(`config/database.yml`), the in-process Webpack compilation
(`config/webpacker.yml`), any additional Gems required (`Gemfile`) and others
(`config/environments/development.rb`, `production.rb` etc.)

To start Houdini in production mode, you can run `bin/rails server
--environment=production` or run:

```
export RAILS_ENV=production
bin/rails server
```


## Configuring the database

See ["Configuring a
database"](https://guides.rubyonrails.org/configuring.html#configuring-a-database)
in the Ruby on Rails guide.


## Building assets

In development mode, Houdini's images, CSS and JS are compiled automatically in
the web server process, but in production mode, this must be done beforehand. To
compile the assets, run:

```
bin/rake assets:precompile
```

As mentioned above, this step is memory intensive and can fail on systems with
less than 2GB RAM or less.


## Running the web application

While the web application can be run with just `source .env && bin/rails server
--production`, you'll normally want to delegate this to your operating system to
manage; typically via SystemD on Debian/Ubuntu-based systems. Here's an example
SystemD configuration to be placed in `/etc/systemd/system/houdini.service` or similar:

```
[Unit]
Description=Houdini

[Service]
Type=simple
User=www-data
Group=www-data
Environment=GEM_HOME=/srv/houdini/.gems
WorkingDirectory=/srv/houdini
ExecStart=bash -c "source /srv/houdini/.env && /srv/houdini/bin/rails server"

[Install]
WantedBy=multi-user.target
```

To load this configuration, run `sudo systemctl daemon-reload` and `sudo systemctl start houdini`. To see the logs, run `sudo journalctl -f -u houdini.service`.

Note that this assumes you have pre-installed the Gem requirements with:

```
cd /srv/houdini
export GEM_HOME=.gems
bundle install
```


## Nginx configuration

```
server {
  listen 80;
  server_name yourwebsite.org;
  
  root /srv/houdini/public;
  
  try_files $uri/index.html $uri.html @app;

  location @app {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;
    proxy_pass http://127.0.0.1:5000;
    
    # Required if you add HTTPS.
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}
```

For details, see ["Using a Reverse
Proxy"](https://guides.rubyonrails.org/configuring.html#using-a-reverse-proxy)
in the Ruby on Rails guide.

To add HTTPS, consider installing CertBot and its associated Nginx plugin, then
running `certbot --nginx`.
