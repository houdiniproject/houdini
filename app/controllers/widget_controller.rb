class WidgetController < ApplicationController
    def v2
        expires_in 10.minutes
        head :found, location: helpers.asset_pack_url("donate-button-v2.js"), content_type: "application/javascript"
    end

    def i18n
        head :found, location: helpers.asset_pack_url("i18n.js"), content_type: "application/javascript"
    end
end
