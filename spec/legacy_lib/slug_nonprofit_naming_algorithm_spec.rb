# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe SlugNonprofitNamingAlgorithm do
  describe ".create_copy_name" do
    before(:all) do
      Timecop.freeze(2020, 5, 4)
    end

    after(:all) do
      Timecop.return
    end

    def set_name(name)
      @name = name
    end

    let(:short_slug) { "slug_name" }
    let(:short_slug_copy_today) { "slug_name-00" }
    let(:short_slug_copy_today_plus_1) { "slug_name-01" }
    let(:copy_base) { "slug_name" }

    let(:state_slug) { "state_slug" }
    let(:city_slug) { "city_slug" }
    let(:not_our_state_slug) { "not_our_state_slug" }
    let(:not_our_city_slug) { "not_our_city_slug" }

    describe "nonprofits" do
      let(:nonprofit) { force_create(:nm_justice, slug: @name, state_code_slug: state_slug, city_slug: city_slug) }
      let(:nonprofit2) { force_create(:fv_poverty, slug: @name2, state_code_slug: state_slug, city_slug: city_slug) }
      let(:nonprofit_in_other_city) { force_create(:nm_justice, slug: @name, state_code_slug: state_slug, city_slug: not_our_city_slug, id: 523950250) }
      let(:nonprofit_in_other_state) { force_create(:fv_poverty, slug: @name, state_code_slug: not_our_state_slug, city_slug: city_slug, id: 5239502) }
      let(:nonprofit_at_max_copies) do
        (0..99).collect do |i|
          force_create(:nonprofit, slug: "#{@copy_base}-#{format("%02d", i)}", state_code_slug: state_slug, city_slug: city_slug)
        end
      end
      let(:algo) { SlugNonprofitNamingAlgorithm.new(state_slug, city_slug) }

      describe "nonprofit slugs" do
        it "not a copy" do
          @name = short_slug
          nonprofit
          expect(algo.create_copy_name(@name)).to eq short_slug_copy_today
        end
        it "one copy exists" do
          @name = short_slug
          @name2 = short_slug_copy_today
          nonprofit
          nonprofit2
          nonprofit_in_other_city
          nonprofit_in_other_state
          expect(algo.create_copy_name(@name)).to eq short_slug_copy_today_plus_1
          expect(algo.create_copy_name(@name2)).to eq short_slug_copy_today_plus_1
        end

        it "it has 99 as max copies" do
          expect(algo.max_copies).to eq 99
        end
      end
    end
  end
end
