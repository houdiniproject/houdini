# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# A controller for interacting with a nonprofit's supporters
class ApiNew::TransactionsController < ApiNew::ApiController
  include Controllers::ApiNew::Transaction::Current
  include Controllers::Nonprofit::Authorization
  before_action :authenticate_nonprofit_user!

  # Gets the nonprofits supporters
  # If not logged in, causes a 401 error
  def index
    set_json_expansion_paths("supporter", "subtransaction.payments", "transaction_assignments", "payments")
    @transactions = current_nonprofit.transactions.order("updated_at DESC").page(params[:page]).per(params[:per])
  end

  # Gets the a single nonprofit supporter
  # If not logged in, causes a 401 error
  def show
    set_json_expansion_paths("supporter", "subtransaction.payments", "transaction_assignments", "payments")
    @transaction = current_transaction
  end
end
