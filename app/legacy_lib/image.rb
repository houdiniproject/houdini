# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Image
  AssetPath = "https://dmnsmycmdpaix.cloudfront.net/uploads"

  DefaultProfileUrl = Settings.default.image.profile
  DefaultNonprofitUrl = Settings.default.image.nonprofit
  DefaultCampaignUrl = Settings.default.image.campaign

  def self._url(resource_name, image_name, version = "normal")
    %(
      concat(#{Qexpr.quote AssetPath}
      , '/', #{Qexpr.quote resource_name}
      , '/', #{Qexpr.quote image_name}
      , '/', #{resource_name + ".id"}
      , '/', #{Qexpr.quote version}, '_', #{resource_name + "." + image_name})
      )
  end
end
