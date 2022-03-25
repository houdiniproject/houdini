# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class CardsController < ApplicationController
  before_action :authenticate_user!, except: [:create]

  # post /cards
  def create
    account = Supporter.find(card_params[:holder_id]).nonprofit.stripe_account_id

    @source_token = InsertCard.with_stripe(card_params, acct, params[:event_id], current_user)
    
  end

  private

  def card_params
    params.require(:card).permit(:cardholders_name, :email, :name, :failure_message, :status, :stripe_card_token, :stripe_card_id, :stripe_customer_id, :holder_id, :holder_type, :inactive)
  end
end
