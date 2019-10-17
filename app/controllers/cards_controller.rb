# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CardsController < ApplicationController

	before_filter :authenticate_user!, :except => [:create]

	# post /cards
  def create
    supporter = Supporter.find(params[:card][:holder_id])
    acct = supporter.nonprofit.stripe_account_id
    render(
      JsonResp.new(params) do |d|
        requires(:card).nested do
          requires(:name, :stripe_card_token).as_string
          requires(:holder_id).as_int
          requires(:holder_type).one_of('Supporter')
        end
      end.when_valid do |d|
        recaptcha_result = check_recaptcha(action: 'create_card', minimum_score: ENV['MINIMUM_RECAPTCHA_SCORE'].to_f)
        unless recaptcha_result[:success]

          failure_details = {
            supporter: supporter.attributes,
            validated_params: d,
            action: 'create_card',
            minimum_score_required: ENV['MINIMUM_RECAPTCHA_SCORE'],
            recaptcha_result: recaptcha_result
          }
          failure = RecaptchaRejection.new
          failure.details_json = failure_details
          failure.save!
        end

        InsertCard.with_stripe(d[:card], acct,  params[:event_id], current_user)
      end
    )
	end

end
