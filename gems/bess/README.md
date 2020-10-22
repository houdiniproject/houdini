# Bess
In order to simplify and make Houdini extensible, we move some of Houdini's setup and
configuration into a separate Gem. We call this support library Bess, in honor of 
Harry Houdini's wife and long-time assistant, [Bess Houdini](https://en.wikipedia.org/wiki/Bess_Houdini).

## Usage
Everything you can get via `Bess` is accessible via the `Houdini` module in the main houdini app. 

## Installation
This really should only be used in Houdini itself for now.

```ruby
gem 'bess', path: 'gems/bess'
```

And then execute:
```bash
$ bundle
```
