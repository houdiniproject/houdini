# Grape::Devise

Grape::Devise adds support for devise helpers from inside Grape::APIs.

NOTE: this project was originally at https://github.com/justinm/grape_devise 
but is not longer supported so we moved it into our repo.

## Installing

Installing is simple. Just add the grape_devise gem to your Gemfile, run
```bundle install``` and it's ready to go.

```
gem 'grape_devise'
```

## Usage

The devise API can now be accessed from inside of Grape request blocks.

```
class MyAPI < Grape::API
    get "/requires-authentication" do
        authenticate_user!
    end
    
    get "/who-am-i" do
        current_user
    end
end

```

## FAQ

####Can I use this with rails
Yes you can! Grape::Devise works with your existing rails sessions to provide
seamless authentication between your rails app and grape APIs.

