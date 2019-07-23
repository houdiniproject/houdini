# Getting Started

## Dependencies

---

You'll need to have in your Mac the following dependencies installed, if you don't want to use the provided Docker containers.

* Ruby `2.4.5`
* Rails `5.0.7.1`
* Node `11.12.0`

## Local Config

---

Instructions for running Development environment using macOS Catalina

### Initial steps
*Dependencies:*

Have a ruby version installed, you can learn more about how to use multiple versions of Ruby installed in your computer with [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io).

An instance of PostgresSQL running.

*Setting up secrets:*

Run `cp .env.template .env` to copy the provided template file for env variables to create your own.

You'll need to provide a `DEVISE_SECRET_KEY` and `SECRET_TOKEN` which you can obtain by running `bundle exec rake secret`.

Set the following secrets in your `.env` file with your *Stripe account* information.

* `STRIPE_API_KEY` with your Stripe *private* key.
* `STRIPE_API_PUBLIC` with your Stripe *public* key.

The last secrets you'll need are related to AWS. You can learn how to [create an S3 Bucket](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html) within the AWS Documentation, and to obtain your access and secret key, you can [learn more here](https://aws.amazon.com/blogs/security/wheres-my-secret-access-key/).

* `S3_BUCKET_NAME`
* `AWS_ACCESS_KEY`
* `AWS_SECRET_ACCESS_KEY`

*Setting up the local database:*

Run `rake db:setup` to run all the db tasks within one command. This will create the dbs for each environment, load the `structure.sql`, run pending migrations and will also run the seed functionality.

### How to run
You'll need 2 consoles to run the project. One for the rails env and another one to run the asset pipeline through [webpack](https://webpack.js.org) , since it's *not incorporated yet* into the rails asset pipeline.

```bash
# Console one (1)
bundle exec rails server
```

```bash
# Console two (2)
npm run watch
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
