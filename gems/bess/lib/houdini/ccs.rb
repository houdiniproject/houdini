# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Houdini::Ccs
    extend ActiveSupport::Autoload

    autoload :GithubAdapter
    autoload :LocalTarGzAdapter

    ADAPTER = 'Adapter'
    private_constant :ADAPTER

    # based on ActiveJob's configuration
    class << self
        def build(name, **options)
            lookup(name).new(**options)
        end

        def lookup(name)
            const_get(name.to_s.camelize << ADAPTER)
        end
    end
end