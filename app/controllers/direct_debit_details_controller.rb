# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
class DirectDebitDetailsController < ApplicationController
  # POST /sepa
  # This endpoint is used for saving direct debit account details
  # when SEPA payment is selected in the donation widget. Actual charge is
  # happening offline, after donations are exported to an external CRM.
  def create
    render(
      JsonResp.new(params) do |_data|
        requires(:supporter_id).as_int
        requires(:sepa_params).nested do
          requires(:iban, :name, :bic).as_string
        end
      end.when_valid do |_data|
        InsertDirectDebitDetail.execute(params)
      end
    )
  end
end
