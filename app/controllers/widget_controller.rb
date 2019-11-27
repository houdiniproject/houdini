class WidgetController < ApplicationController
    def v2
        expires_in 10.minutes
        head :found, location: helpers.asset_pack_url("donate-button-v2.js"), content_type: "application/javascript"
    end

    def i18n
        head :found, location: helpers.asset_pack_url("i18n.js"), content_type: "application/javascript"
    end

    def v1_css
        expires_in 10.minutes
        head :found, location: helpers.stylesheet_url("widget/donate-button.css"), content_type: "text/css"
    end

    def v2_css
        expires_in 10.minutes
        head :found, location: helpers.stylesheet_url("widget/donate-button-v2.css"), content_type: "text/css"
    end
end
