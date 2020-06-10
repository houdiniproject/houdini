# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Houdini::PaymentProvider
    extend ActiveSupport::Autoload

    autoload :Registry
    autoload :StripeProvider

    PROVIDER = 'Provider'
    private_constant :PROVIDER

    # based on ActiveJob's configuration
    class << self
        def build(name, **options)
            lookup(name).new(**options)
        end

        def lookup(name)
            const_get(name.to_s.camelize << PROVIDER)
        end
    end 
end