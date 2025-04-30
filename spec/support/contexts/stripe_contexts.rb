RSpec.shared_context "Stripe::Source doubles" do
  let(:source_from_us) { double("A US based VISA card", country: "US", brand: "Visa") }
  let(:visa_card) { source_from_us }
  let(:uk_visa_card) { double("A UK based VISA card", country: "UK", brand: "Visa") }
  let(:source_from_uk) { double("A UK based American Express card", country: "UK", brand: "American Express") }
  let(:amex_card) { source_from_uk }
  let(:source_from_ru) { double("A Russian based Discover card", country: "RU", brand: "Discover") }
  let(:ru_discover_card) { source_from_ru }
  let(:discover_card) { double("A US based Discover card", country: "US", brand: "Discover") }
end
