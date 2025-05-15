# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Preview all emails at http://localhost:5000/rails/mailers/tax_mailer
class TaxMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods
  # Preview this email at http://localhost:5000/rails/mailers/tax_mailer/annual_receipt
  def annual_receipt
    payments = build_list(:donation_payment_generator, Random.rand(1..5),
      supporter: supporter,
      nonprofit: supporter.nonprofit)
    TaxMailer.annual_receipt(year: tax_year, supporter: supporter, nonprofit_text: nonprofit_text, donation_payments: payments)
  end

  # Preview this email at http://localhost:5000/rails/mailers/tax_mailer/annual_receipt_with_refunds
  def annual_receipt_with_refunds
    payments = build_list(:donation_payment_generator, Random.rand(1..5),
      supporter: supporter,
      nonprofit: supporter.nonprofit)

    refund_payments = build_list(:refund_payment_generator, Random.rand(1..5),
      supporter: supporter,
      nonprofit: supporter.nonprofit)
    TaxMailer.annual_receipt(year: tax_year, supporter: supporter, nonprofit_text: nonprofit_text, donation_payments: payments, refund_payments: refund_payments)
  end

  # Preview this email at http://localhost:5000/rails/mailers/tax_mailer/annual_receipt_with_disputes
  def annual_receipt_with_disputes
    payments = build_list(:donation_payment_generator, Random.rand(1..5),
      supporter: supporter,
      nonprofit: supporter.nonprofit)

    dispute_payments = build_list(:dispute_payment_generator, Random.rand(1..5),
      supporter: supporter,
      nonprofit: supporter.nonprofit)

    dispute_reversal_payments = build_list(:dispute_reversal_payment_generator, Random.rand(0..4),
      supporter: supporter,
      nonprofit: supporter.nonprofit)
    TaxMailer.annual_receipt(year: tax_year, supporter: supporter, nonprofit_text: nonprofit_text, donation_payments: payments, dispute_payments: dispute_payments, dispute_reversal_payments: dispute_reversal_payments)
  end

  private

  def nonprofit
    @nonprofit ||= Nonprofit.find(3693)
  end

  def nonprofit_text
    @nonprofit_text ||= nonprofit.email_customizations.where(name: "2023 Tax Receipt").first&.contents
  end

  def supporter
    @supporter ||= build(:supporter_generator, nonprofit: nonprofit)
  end

  def tax_year
    2023
  end
end
