# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module FetchBackgroundImage
  def self.with_model(model)
    model.background_image_url(:normal) unless model.background_image.file.nil?
  end
end
