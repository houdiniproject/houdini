


$: << File.join(File.dirname(__FILE__), '..', 'lib')

ENV['RAILS_ENV'] ||= 'test'
require 'rspec/rails'
require 'rspec/autorun'

RSpec.configure do | config |
  # some config ...
end