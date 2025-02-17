# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Houdini::WebhookAdapter
  extend ActiveSupport::Autoload
  include ActiveModel::AttributeAssignment

  autoload :OpenFnAdapter

  attr_accessor :webhook_url, :headers
  def initialize(**attributes)
    assign_attributes(**attributes) if attributes
  end

  def transmit(payload)
    RestClient::Request.execute(
      method: :post,
      url: webhook_url,
      payload: payload,
      headers: headers
    )
  end

  ADAPTER = "Adapter"
  private_constant :ADAPTER

  # based on ActiveJob's configuration
  class << self
    def build(name, options)
      lookup(name).new(**options)
    end

    def lookup(name)
      const_get(name.to_s.camelize << ADAPTER)
    end
  end
end
