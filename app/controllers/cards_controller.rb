# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class CardsController < ApplicationController
  before_action :authenticate_user!, except: [:create]

  # post /cards
  def create
    account = Supporter.find(card_params[:holder_id]).nonprofit.stripe_account_id
    render(
      JsonResp.new(params) do |_d|
        requires(:card).nested do
          requires(:name, :stripe_card_token).as_string
          requires(:holder_id).as_int
          requires(:holder_type).one_of('Supporter')
        end
      end.when_valid do |d|
        InsertCard.with_stripe(d[:card], account, params[:event_id], current_user)
      end
    )
  end

  private

  def card_params
    params.require(:card).permit(:cardholders_name, :email, :name, :failure_message, :status, :stripe_card_token, :stripe_card_id, :stripe_customer_id, :holder, :inactive)
  end
end
