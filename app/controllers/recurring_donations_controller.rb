# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class RecurringDonationsController < ApplicationController
  def edit
    @data = QueryRecurringDonations.fetch_for_edit params[:id]

    if @data && params[:t] == @data["recurring_donation"]["edit_token"]
      @nonprofit = RecurringDonation.find(params[:id]).nonprofit
      @data["change_amount_suggestions"] = CalculateSuggestedAmounts.calculate(@data["recurring_donation"]["amount"])
      @data["miscellaneous_np_info"] = FetchMiscellaneousNpInfo.fetch(@data["nonprofit"]["id"])
      if @data["miscellaneous_np_info"]["donate_again_url"].blank?
        @data["miscellaneous_np_info"]["donate_again_url"] = url_for(controller: :nonprofits, action: :show, id: @data["nonprofit"]["id"], only_path: false)
      end
      respond_to do |format|
        format.html
      end
    else
      flash[:notice] = "Unable to find donation. Please follow the exact link provided in your email"
      redirect_to root_url
    end
  end

  def destroy
    @data = QueryRecurringDonations.fetch_for_edit params[:id]
    if params[:edit_token] != @data["recurring_donation"]["edit_token"]
      render json: {error: "Invalid token"}, status: :unprocessable_entity
    else
      updated = UpdateRecurringDonations.cancel(params[:id], current_user ? current_user.email : @data["supporter"]["email"])
      render json: updated
    end
  end

  def update
    data = QueryRecurringDonations.fetch_for_edit params[:id]
    if data && params[:edit_token] == data["recurring_donation"]["edit_token"]
      data["supporter"] = UpdateSupporter.general_info(params[:supporter][:id], params[:supporter]) if params[:supporter]
      data["recurring_donation"] ||= {}
      data["recurring_donation"] = UpdateRecurringDonations.update_card_id(data["recurring_donation"], params[:token]) if params[:token]
      data["recurring_donation"] = UpdateRecurringDonations.update_paydate(data["recurring_donation"], params[:paydate]) if params[:paydate]
      render json: data, status: data.is_a?(ValidationError) ? :unprocessable_entity : :ok
    else
      render json: {error: "Invalid token"}, status: :unprocessable_entity
    end
  end

  def update_amount
    rd = RecurringDonation.where("id = ?", params[:id]).first
    if rd && params[:edit_token] == rd["edit_token"]
      begin
        amount_response = UpdateRecurringDonations.update_amount(rd, params[:token], params[:amount], params[:fee_covered])
        flash[:notice] = "Your recurring donation amount has been successfully changed to #{print_currency(amount_response.amount, "$")}"
        render_json { amount_response }
      rescue => e
        render_json { raise e }
      end
    else
      render json: {error: "Invalid token"}, status: :unprocessable_entity
    end
  end

  private

  def print_currency(cents, unit = "EUR", sign = true)
    dollars = cents.to_f / 100.0
    dollars = view_context.number_to_currency(dollars, unit: "#{unit}", precision: (dollars.round == dollars) ? 0 : 2)
    dollars = dollars[1..-1] if !sign
    dollars
  end
end
