# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class TaxMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.tax_mailer.annual_receipt.subject
  #
  def annual_receipt(supporter:, year:, nonprofit_text:, donation_payments: [], refund_payments:[], dispute_payments: [], dispute_reversal_payments: [])
    @supporter = supporter
    @nonprofit = supporter.nonprofit
    @year = year

    @donation_payments = donation_payments
    @refund_payments = refund_payments
    @dispute_payments = dispute_payments
    @dispute_reversal_payments = dispute_reversal_payments
    @tax_id = supporter.nonprofit.ein
    @nonprofit_text = nonprofit_text

    mail(to: @supporter.email, subject: "#{@year} Tax Receipt from #{@nonprofit.name}")
  end
end
