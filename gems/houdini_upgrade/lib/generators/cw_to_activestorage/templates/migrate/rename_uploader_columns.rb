# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RenameUploaderColumns < ActiveRecord::Migration[5.2]
    rename_column :campaigns, :main_image, :main_image_temp
    rename_column :campaigns, :background_image, :background_image_temp
    rename_column :campaigns, :banner_image, :banner_image_temp

    rename_column :events, :main_image, :main_image_temp
    rename_column :events, :background_image, :background_image_temp

    rename_column :image_attachments, :file, :file_temp

    rename_column :nonprofits, :main_image, :main_image_temp
    rename_column :nonprofits, :second_image, :second_image_temp
    rename_column :nonprofits, :third_image, :third_image_temp
    rename_column :nonprofits, :background_image, :background_image_temp
    rename_column :nonprofits, :logo, :logo_temp

    rename_column :profiles, :picture, :picture_temp
end