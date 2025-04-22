# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class SuperAdminsController < ApplicationController
  layout "layouts/page"

  before_action :authenticate_super_associate!

  def index
  end

  def search_nonprofits
    render json: QueryNonprofits.for_admin(params)
  end

  def search_profiles
    render json: QueryProfiles.for_admin(params)
  end

  def search_fullcontact
    begin
      result = FullContact.person(email: params[:search])
    rescue Exception
      result = ""
    end
    render json: [result]
  end

  def resend_user_confirmation
    ParamValidation.new(params || {},
      profile_id: {required: true, is_integer: true})

    profile = Profile.includes(:user).where("id = ?", params[:profile_id]).first
    unless profile.user
      raise ArgumentError, "#{params[:profile_id]} is a profile without a valid user"
    end

    profile.user.send_confirmation_instructions

    render json: {status: :ok}
  end

  def recurring_donations_without_cards
    odd_donations = QueryRecurringDonations.recurring_donations_without_cards
    respond_to do |format|
      format.html
      format.csv do
        csv_out = CSV.generate do |csv|
          csv << ["supporter id", "recurring donation id", "rd created date", "rd modified", "donation id", "donation card id",
            "edit_token", "nonprofit id",
            "last charge succeeded id", "last charge succeeded created at", "last charge attempted id", "last charge attempted created at", "amount"]

          odd_donations.each do |rd|
            csv << [rd.supporter.id, rd.id, rd.created_at, rd.updated_at, rd.donation.id, rd.donation.card_id, rd.edit_token, rd.nonprofit.id,
              rd.most_recent_paid_charge.id, rd.most_recent_paid_charge.created_at, rd.most_recent_charge.id, rd.most_recent_charge.created_at,
              rd.amount]
          end
        end

        send_data(csv_out, filename: "recurring_donations_without_cards-#{Time.now.to_date}.csv")
      end
    end
  end

  def export_supporters_with_rds
    nonprofit = params[:np]
    ids = params[:ids]
    results = QuerySupporters.for_export(nonprofit, ids: ids)
    results[0].push("Management URLS")
    results.drop(1).each do |row|
      recurring_donations = Supporter.includes(:recurring_donations).find(row.last).recurring_donations.select(&:active).map { |rd| "* #{root_url}recurring_donations/#{rd.id}/edit?t=#{rd.edit_token}" }.join("\n")
      row.push(recurring_donations)
    end

    send_data(Format::Csv.from_vectors(results), filename: "supporters_with_multiple_donations.csv")
  end
end
