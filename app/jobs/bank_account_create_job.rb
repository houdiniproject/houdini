class BankAccountCreateJob < ApplicationJob
  queue_as :default

  def perform(bank_account)
    NonprofitMailer.new_bank_account_notification(bank_account).deliver
  end
end
