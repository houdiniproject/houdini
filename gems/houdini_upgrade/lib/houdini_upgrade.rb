# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "houdini_upgrade/engine"

module HoudiniUpgrade
  require 'houdini_upgrade/table_to_migrate'
  UPLOADERS_TO_MIGRATE = [
    TableToMigrate.new(:nonprofits, [:main_image, 
      :second_image, 
      :third_image, 
      :background_image, 
      :logo]),
    TableToMigrate.new(:campaigns, [
      :main_image, 
      :second_image, 
      :third_image, 
      :background_image, 
      :logo
    ]),
    TableToMigrate.new(:events, [
      :main_image,
      :background_image
    ]),
    TableToMigrate.new(:image_attachments, [
      :file
    ]),
    TableToMigrate.new(:profiles, [
      :picture
    ])
  ]
end
