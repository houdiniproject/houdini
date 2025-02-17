# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# A controller for interacting with a subtransactions payments
class Api::PaymentsController < Api::ApiController
  include Controllers::Api::Transaction::Current
  include Controllers::Nonprofit::Authorization
  before_action :authenticate_nonprofit_user!

  def index
    @payments =
      current_subtransaction
        .payments
        .order("created DESC")
        .page(params[:page])
        .per(params[:per])
  end

  def show
    @payment = current_payment
  end

  private

  def current_subtransaction
    current_transaction.subtransaction
  end

  def current_payment
    current_subtransaction.payments.where(paymentable_id: params[:id])
  end
end
