# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::PaymentProvider::Registry
    def initialize(configurations)
        @configurations = configurations.deep_dup
        @providers = {}
    end
    
    def build_all
        configurations.keys.each do |key|
            resolve(key)
            configurations[key] = Houdini::PaymentProvider.build(key)
        end

      configurations
    end

    private
      attr_reader :configurations, :providers
      def resolve(class_name)
        require "houdini/payment_provider/#{class_name.to_s.underscore}_provider"
        Houdini::PaymentProvider.const_get(:"#{class_name.to_s.camelize}Provider")
      rescue LoadError
        raise "Missing provider for #{class_name.inspect}"
    end
end