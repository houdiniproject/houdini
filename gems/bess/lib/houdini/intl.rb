# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Houdini::Intl
  include ActiveModel::AttributeAssignment
  attr_accessor :currency, :available_locales, :language, :currencies, :all_currencies, :all_countries

  def initialize(attributes = {})
    assign_attributes(attributes) if attributes
  end
end
