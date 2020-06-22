# FullContact
An Houdini add-on to use FullContact's Enrich API. This add-on provides a few features:

* a event listener for supporter_create which downloads information from the Enrich API.
* adds a has_many relation on Supporter for every set of data about that Supporter downloaded.
Each item is an instance of `Houdini::FullContact::Info`

## Usage
You can provide your FullContact API key in one of two ways:

* Setting the `FULL_CONTACT_KEY` environment variable or
* Setting the `houdini.full_contact.api_key` configuration option

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'houdini_full_contact', path: 'gems/houdini_full_contact
```

And then execute:
```bash
$ bundle
```

And then install the database migrations for houdini_full_contact:
```bash
bin/rails houdini_full_contact:install:migrations
```
