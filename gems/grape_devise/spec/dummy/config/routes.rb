require "devise"

Dummy::Application.routes.draw do

  devise_for :users
  mount API => '/'
end
