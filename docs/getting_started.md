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
obtain by running `bundle exec rake secret`.

Set the following secrets in your `.env` file with your _Stripe account_ information.

- `STRIPE_API_KEY` with your Stripe _private_ key.
- `STRIPE_API_PUBLIC` with your Stripe _public_ key.

The last secrets you'll need are related to AWS. You can learn how
to [create an S3 Bucket](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html)
within the AWS Documentation, and to obtain your access and secret key, you
can [learn more here](https://aws.amazon.com/blogs/security/wheres-my-secret-access-key/).

- `S3_BUCKET_NAME`
- `AWS_ACCESS_KEY`
- `AWS_SECRET_ACCESS_KEY`

_Setting up the local database:_

Run `rake db:setup` to run all the db tasks within one command. This will
create the dbs for each environment, load the `structure.sql`, run
pending migrations and will also run the seed functionality.

---

**Known problems**
If you encounter `database doesnt exist in rake db create` after running
both `rake db:setup` and `rake db:create`, you'll need to comment out
the lines these lines at `pg_type_map.rb`

```ruby
Qx.config(type_map: PG::BasicTypeMapForResults.new(ActiveRecord::Base.connection.raw_connection))
Qx.execute("SET TIME ZONE utc")
```

### How to run

You'll need 2 consoles to run the project. One for the rails env and another
one to run the asset pipeline through [webpack](https://webpack.js.org),
since it's _not incorporated yet_ into the rails asset pipeline.

```bash
# Console one (1)
bundle exec rails server
```

```bash
# Console two (2)
yarn watch
# #### Notes ####
# If you get errors from running this command.
# You'll need to manually run the following commands.
npm run export-button-config
npm run export-i18n
npm run generate-api-js
# Now we're able to watch!
npx webpack --watch
```

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
