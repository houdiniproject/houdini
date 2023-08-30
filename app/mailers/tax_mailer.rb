# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class TaxMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.tax_mailer.annual_receipt.subject
  #
  def annual_receipt(supporter:, payments:, year:, tax_id:, nonprofit_text:)
    @supporter = supporter
    @nonprofit = supporter.nonprofit
    @payments = payments
    @year = year
    @tax_id = tax_id
    @nonprofit_text = nonprofit_text

    mail(to: @supporter.email, subject: "#{@year} Tax Receipt from #{@nonprofit.name}")
  end
end
