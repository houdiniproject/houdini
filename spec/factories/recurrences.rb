# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
FactoryBot.define do
  factory :recurrence do
    supporter { association :supporter_with_fv_poverty }
    recurring_donation do
      association(:rd_with_dedication_designation,
        nonprofit: supporter.nonprofit,
        supporter: supporter,
        donation: association(:donation_with_dedication_designation, nonprofit: supporter.nonprofit,
          supporter: supporter))
    end
    amount { 500 }

    factory :recurrence_with_paydate_earlier_in_month do
      recurring_donation do
        association(:rd_with_dedication_designation,
          nonprofit: supporter.nonprofit,
          supporter: supporter,
          donation: association(
            :donation_with_dedication_designation,
            nonprofit: supporter.nonprofit,
            supporter: supporter
          ),
          paydate: 3)
      end
    end

    factory :recurrence_with_paydate_later_in_month do
      recurring_donation do
        association(:rd_with_dedication_designation,
          nonprofit: supporter.nonprofit,
          supporter: supporter,
          donation: association(
            :donation_with_dedication_designation,
            nonprofit: supporter.nonprofit,
            supporter: supporter
          ),
          paydate: 5)
      end
    end
  end
end
