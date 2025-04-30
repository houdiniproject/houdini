# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module InsertDirectDebitDetail
  def self.execute(params)
    supporter = Supporter.find(params[:supporter_id])

    direct_debit_detail = {}
    begin
      DirectDebitDetail.transaction {
        direct_debit_detail = DirectDebitDetail.create(
          bic: params[:sepa_params][:bic],
          iban: params[:sepa_params][:iban],
          account_holder_name: params[:sepa_params][:name],
          holder: supporter
        )
      }
    rescue ActiveRecord::ActiveRecordError => e
      return {json: {error: "Oops! There was an error saving your direct debit details, and it did not complete. Please try again in a moment. Error: #{e}"}, status: :unprocessable_entity}
    end

    {status: :ok, json: direct_debit_detail}
  end
end
