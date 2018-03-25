module FetchBackgroundImage

	def self.with_model(model)
		return model.background_image_url(:normal) unless model.background_image.file.nil?
	end
end
