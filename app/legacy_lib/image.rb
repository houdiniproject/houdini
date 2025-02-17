# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Image
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
