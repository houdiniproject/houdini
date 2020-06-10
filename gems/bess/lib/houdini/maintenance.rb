# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class Houdini::Maintenance
    include ActiveModel::AttributeAssignment
    attr_accessor :active, :token, :page

    def initialize(attributes={})
        assign_attributes(attributes) if attributes
    end
end