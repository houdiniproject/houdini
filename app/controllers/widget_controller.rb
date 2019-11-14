class WidgetController < ApplicationController
    def v2
        redirect_to(asset_pack_url("donate-button-v2.js"))
    end
end
