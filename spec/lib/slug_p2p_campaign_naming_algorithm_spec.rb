# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'

describe SlugP2pCampaignNamingAlgorithm do
  describe '.create_copy_name' do
    before(:all) do
      Timecop.freeze(2020, 5, 4)
    end
    after(:all) do
      Timecop.return
    end

    def set_name(name)
      @name = name
    end

    let(:short_slug) { 'slug_name' }
    let(:short_slug_copy_today) { 'slug_name_000' }
    let(:short_slug_copy_today_plus_1) { 'slug_name_001' }
    let(:copy_base) { 'slug_name' }

    let(:nonprofit) { force_create(:nm_justice) }

    describe 'campaigns' do
      let(:campaign) { force_create(:campaign, slug: @name, nonprofit: nonprofit, deleted: true) }
      let(:campaign2) { force_create(:campaign, slug: @name2, nonprofit: nonprofit) }
      let(:campaigns_at_max_copies) do
        (0..999).collect do |i|
          force_create(:campaign, slug: "#{@copy_base}_#{format('%03d', i)}", nonprofit: nonprofit)
        end
      end
      let(:algo) { SlugP2pCampaignNamingAlgorithm.new(nonprofit.id) }
      describe 'campaign slugs' do
        it 'not a copy' do
          @name = short_slug
          campaign
          expect(algo.create_copy_name(@name)).to eq short_slug_copy_today
        end
        it 'one copy exists' do
          @name = short_slug
          @name2 = short_slug_copy_today
          campaign
          campaign2
          expect(algo.create_copy_name(@name)).to eq short_slug_copy_today_plus_1
          expect(algo.create_copy_name(@name2)).to eq short_slug_copy_today_plus_1
        end

        it 'has 999 as the max_copies' do
          expect(algo.max_copies).to eq 999
        end
      end
    end
  end
end
