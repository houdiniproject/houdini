# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
# Preview all emails at http://localhost:5000/rails/mailers/tax_mailer
class TaxMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods
  # Preview this email at http://localhost:5000/rails/mailers/tax_mailer/annual_receipt
  def annual_receipt
    tax_id = "12-3456789"
    supporter = create(:supporter_generator, nonprofit: build(:nonprofit_base, ein: tax_id))

    tax_year = 2023
    payments = create_list(:donation_payment_generator, Random.rand(5) + 1,
        supporter: supporter,
        nonprofit: supporter.nonprofit
    )

    nonprofit_text = "<p>#{Faker::Lorem.paragraph(sentence_count: 5)}</p>" + "<p>#{Faker::Lorem.paragraph(sentence_count:3)}</p>"
    TaxMailer.annual_receipt(year: tax_year, supporter: supporter, nonprofit_text: nonprofit_text, donation_payments: payments)
  end

end
