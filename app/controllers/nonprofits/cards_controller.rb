# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module Nonprofits
	class CardsController < ApplicationController
    include Controllers::NonprofitHelper

		before_filter :authenticate_nonprofit_user!

    def edit
      @nonprofit = current_nonprofit
    end

    # POST /nonprofits/:nonprofit_id/card
    def create
      render(
        JsonResp.new(params) do |d|
          requires(:nonprofit_id).as_int
          requires(:card).nested do
            requires(:name, :stripe_card_token, :stripe_card_id).as_string
            requires(:holder_id).as_int
            requires(:holder_type).one_of('Supporter', 'Nonprofit')
          end
        end.when_valid do |d|
          UpdateBillingSubscriptions.activate_from_trial(d[:nonprofit_id])
          InsertCard.with_stripe(d[:card])
        end
      )
    end

  end
end
