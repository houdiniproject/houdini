# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module InsertDirectDebitDetail
  def self.execute(params)
    supporter = Supporter.find(params[:supporter_id])

    direct_debit_detail = {}
    begin
      DirectDebitDetail.transaction do
        direct_debit_detail = DirectDebitDetail.create(
          bic: params[:sepa_params][:bic],
          iban: params[:sepa_params][:iban],
          account_holder_name: params[:sepa_params][:name],
          holder: supporter
        )
      end
    rescue ActiveRecord::ActiveRecordError => e
      return {json: {error: "Oops! There was an error saving your direct debit details, and it did not complete. Please try again in a moment. Error: #{e}"}, status: :unprocessable_entity}
    end

    {status: :ok, json: direct_debit_detail}
  end
end
