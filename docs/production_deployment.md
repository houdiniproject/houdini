# Production deployment

## System requirements

Webpack currently requires about 3GB RAM free to build the JavaScript assets in
production mode, so a server with at least 4GB RAM is likely
required. Optimisations may be possible, but due to the bootstrap-loader
integration we can't currently switch to a newer Webpack.

## Enable production mode

Running `bin/rails server` will by default start Houdini/Rails in "development"
mode (`Rails.env == "development"`). This flag is used to conditionally
configure various aspects of the application such as the database settings
(`config/database.yml`), the in-process Webpack compilation
(`config/webpacker.yml`), any additional Gems required (`Gemfile`) and others
(`config/environments/development.rb`, `production.rb` etc.)

To start Houdini in production mode, you can run `bin/rails server
--environment=production` or run:

```sh
export RAILS_ENV=production
bin/rails server
```

## Configure the database

See ["Configuring a
database"](https://guides.rubyonrails.org/configuring.html#configuring-a-database)
in the Ruby on Rails guide.

## Build the assets

In development mode, Houdini's images, CSS and JS are compiled automatically in
the web server process, but in production mode this should be done beforehand
(`config.assets.compile = false`). To compile the assets, run:

```sh
RAILS_ENV=production bin/rails assets:clobber
RAILS_ENV=production bin/rails assets:precompile
```

As mentioned above, this step is memory intensive and will likely fail on
systems with less than 3GB RAM free.

These assets are also not served in production mode by default
(`config.public_file_server.enabled = false`), with the intention that they are
served directly from Nginx as configured below. You can override this behavior
by setting the environment variable `RAILS_SERVE_STATIC_FILES=true`.

You may also consider serving [static assets from a
CDN](https://guides.rubyonrails.org/asset_pipeline.html#cdns). This is
especially useful if you've configured Rails to serve static assets directly as
mentioned above.

See ["Webpacker"](https://edgeguides.rubyonrails.org/webpacker.html) in the Ruby
on Rails guide for details.

## Run the web application

While the web application can be run with just `source .env && bin/rails server
--production`, you'll normally want to delegate this to your operating system to
manage; typically via SystemD on Debian/Ubuntu-based systems. Here's an example
SystemD configuration to be placed in `/etc/systemd/system/houdini.service` or similar:

```sh
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

To load this configuration, run `sudo systemctl daemon-reload` and `sudo
systemctl start houdini`. To see the logs, run `sudo journalctl -f -u
houdini.service`.

Note that this assumes you have pre-installed the Gem requirements with:

```sh
cd /srv/houdini
export GEM_HOME=.gems
bundle install
```

## Configure Nginx

```nginx
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

## Use a production-grade cache

The development mode configuration uses `memory_store` for caching which isn't
shared between processes or server and clears every time your server software
restarts. See [Cache
Stores](https://guides.rubyonrails.org/caching_with_rails.html#cache-stores) in
the Rails documentation for details on deploying a production-grade
cache. Memcached or Redis are good choices here.

## Provide the complete corresponding source code

> **Note: This is not legal advice and provides a suggestion which may be
> compliant. You should talk with your legal counsel if you have questions or
> concerns with how to comply with the various licenses of Houdini.**

Providing the complete, corresponding source code (CCS) of your project is a
requirement of some of the licenses used by Houdini. There are two methods for
doing so right now:

1. Providing a tarball of the current running code
2. Providing a link to Github where the code is pulled from

The easiest method is to provide a tarball. Houdini automatically provides a
link on the Terms & Privacy page which generates a tarball for the current
running code at runtime.  For this to work though, the following characteristics
must be true:

* Your have to have committed any changes you made to the project in `HEAD` in
  your git repository
* The `.git` folder for your repository must be a direct subfolder of your
  `$RAILS_ROOT`
* Your web server must be able to run `git archive`
