# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class DirectDebitDetailsController < ApplicationController
  # POST /sepa
  # This endpoint is used for saving direct debit account details
  # when SEPA payment is selected in the donation widget. Actual charge is
  # happening offline, after donations are exported to an external CRM.
  def create
    render(
      JsonResp.new(params) do |data|
        requires(:supporter_id).as_int
        requires(:sepa_params).nested do
          requires(:iban, :name, :bic).as_string
        end
      end.when_valid do |data|
        InsertDirectDebitDetail.execute(params)
      end
    )
  end
end
