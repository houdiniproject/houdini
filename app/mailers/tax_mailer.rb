# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class TaxMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.tax_mailer.annual_receipt.subject
  #
  def annual_receipt(supporter:, year:, nonprofit_text:, donation_payments: [], refund_payments: [], dispute_payments: [], dispute_reversal_payments: [])
    @supporter = supporter
    @nonprofit = supporter.nonprofit
    @year = year

    @total = get_payment_sum(donation_payments, refund_payments, dispute_payments, dispute_reversal_payments)
    @donation_payments = donation_payments.sort_by(&:date)
    @refund_payments = refund_payments.sort_by(&:date)
    @dispute_payments = dispute_payments.sort_by(&:date)
    @dispute_reversal_payments = dispute_reversal_payments.sort_by(&:date)
    @tax_id = supporter.nonprofit.ein

    dict = SupporterInterpolationDictionary.new("NAME" => "Supporter", "FIRSTNAME" => "Supporter")
    dict.set_supporter(supporter)

    @nonprofit_text = dict.interpolate(nonprofit_text)

    mail(to: @supporter.email, subject: "#{@year} Tax Receipt from #{@nonprofit.name}")
  end

  private

  def get_payment_sum(*payments)
    payments.flatten.sum(&:gross_amount)
  end
end
