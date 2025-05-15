# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module IncludeAsset
  # These are custom asset include functions for use in views that cache-bust using the current git version

  def self.js(path)
    %(<script src="#{path}?v=#{asset_version}" type="text/javascript"></script>).html_safe
  end

  def self.css(path)
    %(<link rel='stylesheet' type='text/css' media='all' href="#{path}?v=#{asset_version}">).html_safe
  end

  private

  def self.asset_version
    ENV["ASSET_VERSION"]
  end
end
