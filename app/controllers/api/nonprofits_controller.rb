# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

class Api::NonprofitsController < ApplicationController
  rescue_from ActiveModel::ValidationError do |error|
    render json: {errors: error.model.errors}, status: 400
  end

  def create
    @nonprofit_form = RegisterNonprofitForm.new(
      nonprofit_attributes: nonprofit_attributes,
      user_attributes: user_attributes
    )

    @nonprofit_form.save!

    render jbuilder: @nonprofit_form, status: :created
  end

  def nonprofit_attributes
    params.permit(nonprofit: [:name,
      :website,
      :zip_code,
      :state_code,
      :city,
      :email,
      :phone])[:nonprofit] || {}
  end

  def user_attributes
    params.permit(user: [:name,
      :email,
      :password,
      :password_confirmation])[:user] || {}
  end
end
