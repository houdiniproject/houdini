# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CardsController < ApplicationController

	before_action :authenticate_user!, :except => [:create]

	# post /cards
	def create
    acct = Supporter.find(params[:card][:holder_id]).nonprofit.stripe_account_id
    render(
      JsonResp.new(params) do |d|
        requires(:card).nested do
          requires(:name, :stripe_card_token).as_string
          requires(:holder_id).as_int
          requires(:holder_type).one_of('Supporter')
        end
      end.when_valid do |d|
        InsertCard.with_stripe(d[:card], acct,  params[:event_id], current_user)
      end
    )
	end

end
