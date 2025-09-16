# frozen_string_literal: true

module Maintenance
  class UpdateNpTimezoneNamesTask < MaintenanceTasks::Task
    def collection
      # Collection to be iterated over
      # Must be Active Record Relation or Array
      Nonprofit.where.not(timezone: nil)
    end

    def process(element)
      zone = ActiveSupport::TimeZone.all.find { |z| z.tzinfo.name == element.timezone }
      element.update_attribute(:timezone, zone.name) if zone.present?
    end

    def count
      collection.count
    end
  end
end
