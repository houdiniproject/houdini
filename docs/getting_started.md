# Getting Started

## Dependencies

---

You'll need to have the following dependencies installed:

* Ruby 2.7
* Node 14
* Yarn
* PostgreSQL 10 or 12

## Local Config

---

Instructions for running Development environment using macOS Catalina

### Initial steps

_Dependencies:_

Have a ruby version installed, you can learn more about how to use multiple
versions of Ruby installed in your computer with
[rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io).

An instance of PostgresSQL running.

_Setting up secrets:_

Run `cp .env.template .env` to copy the provided template file for env
variables to create your own.

You'll need to provide a `DEVISE_SECRET_KEY` and `SECRET_TOKEN` which you can
obtain by running `bundle exec bin/rails secret`.

Set the following secrets in your `.env` file with your _Stripe account_ information.

* `STRIPE_API_KEY` with your Stripe _private_ key.
* `STRIPE_API_PUBLIC` with your Stripe _public_ key.

The last secrets you'll need are related to AWS. You can learn how
to [create an S3 Bucket](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html)
within the AWS Documentation, and to obtain your access and secret key, you
can [learn more here](https://aws.amazon.com/blogs/security/wheres-my-secret-access-key/).

* `S3_BUCKET_NAME`
* `AWS_ACCESS_KEY`
* `AWS_SECRET_ACCESS_KEY`

_Setting up the local database:_

Run `bin/rails db:setup` to run all the db tasks within one command. This will
create the dbs for each environment, load the `structure.sql`, run
pending migrations and will also run the seed functionality.

---

**Known problems**
If you encounter `database doesnt exist in bin/rails db create` after running
both `bin/rails db:setup` and `bin/rails db:create`, you'll need to comment out
the lines these lines at `pg_type_map.rb`

```ruby
Qx.config(type_map: PG::BasicTypeMapForResults.new(ActiveRecord::Base.connection.raw_connection))
Qx.execute("SET TIME ZONE utc")
```

### Running in development

Run the development server with:

`bin/rails server`

The development server will periodically check for changes in CSS and JavaScript
assets and rebuild them in-process. If you are doing significant JavaScript
development and would like faster feedback on build errors and automatic
reloading, run `bin/webpack-dev-server` in a second console. Now after making a
change to the JavaScript code you should see Webpack immediately rebuild the
assets and perform a full page reload.

It's worth noting that the in-process, the one-off `bin/webpack` and
`bin/webpack-dev-server` builds all set `NODE_ENV=development` by default which
skips some optimisation steps. The `bin/rake assets:precompile` task sets
`NODE_ENV=production` by default. Any of these can be overridden as required by
setting the `NODE_ENV` environment variable, for example:

`NODE_ENV=development bin/rake assets:precompile`

That's not something you'll need often, but can help when troubleshooting
differences between development and production asset builds.

## Testing

---

Run `bundle exec rspec` to run test suite.

## Formatting

We are using [Standard](https://github.com/testdouble/standard) that is a
wrapper on top of Rubocop with a predefined set of Rules. If you use VS Code
you will want to install
[vscode-ruby](https://marketplace.visualstudio.com/items?itemName=rebornix.Ruby)
extension and enable formatting on save.

To enable formatting on save add these lines to your `settings.json`.

```json
{
  "[ruby]": {
    "editor.formatOnSave": true
  },
  "ruby.lint": {
    "rubocop": true
  },
  "ruby.format": "rubocop",
  "editor.formatOnSaveTimeout": 5000
}
```
