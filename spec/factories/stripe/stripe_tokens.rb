# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  factory :stripe_token, aliases: [:stripe_token_base], class: "Stripe::Token" do
    stripe_object_base

    to_create do |instance|
      new_token = StripeMockHelper.stripe_helper.generate_card_token(**instance)
      instance.update_attributes(Stripe::Token.retrieve(new_token))
    end
  end
end
