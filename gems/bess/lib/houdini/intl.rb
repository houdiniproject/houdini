# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::Intl
    include ActiveModel::AttributeAssignment
    attr_accessor :currency, :available_locales, :language, :currencies, :all_currencies, :all_countries

    def initialize(attributes={})
        assign_attributes(attributes) if attributes
    end
end