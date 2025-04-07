# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "houdini_upgrade/engine"

module HoudiniUpgrade
  require "houdini_upgrade/table_to_migrate"
  UPLOADERS_TO_MIGRATE = [
    TableToMigrate.new(:nonprofits, [:main_image,
      :second_image,
      :third_image,
      :background_image,
      :logo]),
    TableToMigrate.new(:campaigns, [
      :main_image,
      :background_image,
      :banner_image
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
