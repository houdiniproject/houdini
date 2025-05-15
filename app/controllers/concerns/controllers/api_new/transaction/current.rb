# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module Controllers::ApiNew::Transaction::Current
  extend ActiveSupport::Concern
  include Controllers::ApiNew::Nonprofit::Current

  included do
    private

    def current_transaction
      result = @current_transaction
      if result.nil?
        result = current_nonprofit.transactions.find_by!(houid: params[:transaction_id] || params[:id])
      end
      @current_transaction = result
    end
  end
end
