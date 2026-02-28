# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class AddModernAchievements < ActiveRecord::Migration[6.1]
  module TemporaryConcern
    extend ActiveSupport::Concern

    included do
      serialize :achievements, Array
      serialize :categories, Array
    end
  end

  def change
    add_column :nonprofits, :achievements_json, :jsonb
    add_column :nonprofits, :categories_json, :jsonb

    reversible do |dir|
      dir.up do
        Nonprofit.include(::AddModernAchievements::TemporaryConcern)
        Nonprofit.find_each do |np|
          np.achievements_json = np.achievements
          unless np.save
            puts "NP ##{np.id} could not be saved"
            np.save(validate: false)
          end
          np.reload

          raise "NP ##{np.id} does not have identical values" if np.achievements_json != np.achievements
        end
      end
    end

    rename_column :nonprofits, :achievements, :achievements_legacy
    rename_column :nonprofits, :categories, :categories_legacy

    rename_column :nonprofits, :achievements_json, :achievements
    rename_column :nonprofits, :categories_json, :categories
  end
end
