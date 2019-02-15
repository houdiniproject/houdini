module GrapeDevise
end

require "devise"
require "grape"
require "grape_devise/api"

Devise.helpers << GrapeDevise::API
Grape::Endpoint.send :include, GrapeDevise::API
