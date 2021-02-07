# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class Houdini::WebhookAdapter
  extend ActiveSupport::Autoload
  include ActiveModel::AttributeAssignment

  autoload :OpenFn

  attr_accessor :url, :auth_headers
  def initialize(attributes={})
    assign_attributes(attributes) if attributes
  end

  def post(payload)
    RestClient::Request.execute(
      method: :post,
      url: url,
      payload: payload,
      headers: auth_headers
    )
  end
end
