# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
module Nonprofits
  class CardsController < ApplicationController
    include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization

    before_action :authenticate_nonprofit_user!

    def edit
      @nonprofit = current_nonprofit
    end

    # POST /nonprofits/:nonprofit_id/card
    def create
      render(
        JsonResp.new(params) do |_d|
          requires(:nonprofit_id).as_int
          requires(:card).nested do
            requires(:name, :stripe_card_token, :stripe_card_id).as_string
            requires(:holder_id).as_int
            requires(:holder_type).one_of('Supporter', 'Nonprofit')
          end
        end.when_valid do |d|
          InsertCard.with_stripe(d[:card])
        end
      )
    end

    def required_params
      params.require(:nonprofit_id, card: [:name, :stripe_card_token, :stripe_card_id, :holder_id, :holder_type])
    end
  end
end
