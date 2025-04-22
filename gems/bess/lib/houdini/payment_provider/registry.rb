# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'ostruct'

class Houdini::PaymentProvider::Registry
  def initialize(configurations)
    @configurations = configurations.deep_dup
    @providers = OpenStruct.new
  end

  def build_all
    configurations.each do |key, options = {}|
      resolve(key)
      providers[key] = Houdini::PaymentProvider.build(key, options)
    end

    providers
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
