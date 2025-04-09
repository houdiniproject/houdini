# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"
describe :stripe_product do
  it 'provides a Stripe::Product' do
    product = create(:stripe_product)
    expect(product).to be_a Stripe::Product
  end

  it 'can be retrieved if requested' do
    product = create(:stripe_product)
    server_product = Stripe::Product.retrieve(product.id)
    expect(product).to eq server_product
  end
end