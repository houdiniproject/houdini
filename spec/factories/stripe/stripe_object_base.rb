# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
FactoryBot.define do
  trait :stripe_object_base do
    before(:create) do
      StripeMockHelper.start
    end

    # with most Stripe::StripeObjects you can just run .save to create the object on the StripeMock.instance
    to_create do |instance|
      instance.save
    end
  end
end
