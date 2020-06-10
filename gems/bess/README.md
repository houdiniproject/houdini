# Bess
In order to simplify and make Houdini extensible, we move some of Houdini's setup and
configuration into a separate Gem. We call this support library Bess, in honor of 
Harry Houdini's wife and long-time assistant, Bess Houdini.

## Usage
Everything you can get via `Bess` is accessible via `Houdini` in the main houdini app.

As an example, let's say Bess has a string constant named `Bess::PRESTO`. From
your Houdini app, you can use `Houdini::PRESTO` to access this constant. 

We recommend using this pattern.

## Installation
This really should only be used in Houdini itself for now.

```ruby
gem 'bess', path: 'gems/bess'
```

And then execute:
```bash
$ bundle
```
