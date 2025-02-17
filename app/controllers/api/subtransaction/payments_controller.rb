# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# A controller for interacting with a transaction's payments
class Api::Subtransaction::PaymentsController < Api::ApiController
  include Controllers::Api::Transaction::Current
  include Controllers::Nonprofit::Authorization
  before_action :authenticate_nonprofit_user!

  # Gets the nonprofits supporters
  # If not logged in, causes a 401 error
  def index
    @payments =
      current_transaction
        .subtransaction
        .payments
        .order("created DESC")
        .page(params[:page])
        .per(params[:per])
  end

  # Gets the a single nonprofit supporter
  # If not logged in, causes a 401 error
  def show
    @payment =
      current_transaction
        .subtransaction
        .payments.find_by(paymentable_id: params[:id]).paymentable
  end
end
