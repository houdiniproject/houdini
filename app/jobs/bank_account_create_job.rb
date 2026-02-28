class BankAccountCreateJob < EmailJob
  def perform(bank_account)
    NonprofitMailer.new_bank_account_notification(bank_account).deliver_now
  end
end
