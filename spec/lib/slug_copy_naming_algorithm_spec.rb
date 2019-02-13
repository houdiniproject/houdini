# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe SlugCopyNamingAlgorithm do
  describe '.create_copy_name' do
    before(:all) {
        Timecop.freeze(2020,5,4)
    }
    after(:all) {
        Timecop.return
    }

    def set_name(name)
      @name = name
    end

    let(:short_slug) { "slug_name"}
    let(:short_slug_copy_today) { "slug_name_copy_00"}
    let(:short_slug_copy_today_plus_1) { "slug_name_copy_01"}
    let(:copy_base) {"slug_name_copy"}


    let(:nonprofit) {force_create(:nonprofit)}


    describe 'events' do

      let(:event) {force_create(:event, :slug => @name, nonprofit: nonprofit)}
      let(:event2) {force_create(:event, :slug => @name2, nonprofit:nonprofit)}
      let(:events_at_max_copies) { (0..30).collect{|i|
        force_create(:event, slug: "#{@copy_base}_#{"%02d" % i}", nonprofit:nonprofit)
      }}
      let(:algo) {SlugCopyNamingAlgorithm.new(Event, nonprofit.id)}
      describe 'event slugs' do

        it 'not a copy' do
          @name = short_slug
          event
          expect(algo.create_copy_name(@name)).to eq short_slug_copy_today
        end
        it 'one copy exists' do
          @name = short_slug
          @name2 = short_slug_copy_today
          event
          event2
          expect(algo.create_copy_name(@name)).to eq short_slug_copy_today_plus_1
          expect(algo.create_copy_name(@name2)).to eq short_slug_copy_today_plus_1
        end

        it 'has 30 as max copies' do
          expect(algo.max_copies).to eq 30
        end

      end


    end

    describe 'campaigns' do
      let(:campaign) {force_create(:campaign, :slug => @name, nonprofit: nonprofit)}
      let(:campaign2) {force_create(:campaign, :slug => @name2, nonprofit:nonprofit)}
      let(:campaigns_at_max_copies) { (0..30).collect{|i|
        force_create(:campaign, slug: "#{@copy_base}_#{"%02d" % i}", nonprofit:nonprofit)
      }}
      let(:algo) {SlugCopyNamingAlgorithm.new(Campaign, nonprofit.id)}
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

        it 'has 30 as max copies' do
          expect(algo.max_copies).to eq 30
        end


      end
    end
  end
end

