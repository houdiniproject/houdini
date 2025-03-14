# frozen_string_literal: true

FactoryBot.define do
  factory :supporter_note do
    factory :supporter_note_with_fv_poverty do
      supporter { create(:supporter_with_fv_poverty) }
      content { "Some content in our note" }
      factory :supporter_note_with_fv_poverty_with_user do
        user { create(:user) }
      end
    end
  end
end
