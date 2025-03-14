# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Controllers::Api::Transaction::Current
  extend ActiveSupport::Concern
  include Controllers::Nonprofit::Current

  included do
    private

    def current_transaction
      @current_transaction ||= current_nonprofit.transactions.find(params[:transaction_id] || params[:id])
    end
  end
end
