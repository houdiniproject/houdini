# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class Api::NonprofitsController < Api::ApiController
  include Controllers::Nonprofit::Current
  include Controllers::Nonprofit::Authorization

  before_action :authenticate_nonprofit_user!, only: %i[show]

  def create
    @nonprofit = Nonprofit.new(clean_params.merge({user_id: current_user_id}))
    @nonprofit.save!
    render status: :created
  end

  def show
    @nonprofit = current_nonprofit
  end

  private

  def clean_params
    params.permit(:name, :zip_code, :state_code, :city, :phone, :email, :website)
  end
end
