# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe SlugNonprofitNamingAlgorithm do
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
    let(:short_slug_copy_today) { "slug_name-00"}
    let(:short_slug_copy_today_plus_1) { "slug_name-01"}
    let(:copy_base) {"slug_name"}

    let(:state_slug) {'state_slug'}
    let(:city_slug) {'city_slug'}
    let(:not_our_state_slug) {'not_our_state_slug'}
    let(:not_our_city_slug) {'not_our_city_slug'}



    describe 'nonprofits' do
      let(:nonprofit) {force_create(:nonprofit, :slug => @name, state_code_slug: state_slug, city_slug: city_slug)}
      let(:nonprofit2) {force_create(:nonprofit, :slug => @name2, state_code_slug: state_slug, city_slug: city_slug)}
      let(:nonprofit_in_other_city) {force_create(:nonprofit, :slug => @name, state_code_slug: state_slug, city_slug: not_our_city_slug)}
      let(:nonprofit_in_other_state) {force_create(:nonprofit, :slug => @name, state_code_slug: not_our_state_slug, city_slug: city_slug)}
      let(:nonprofit_at_max_copies) { (0..99).collect{|i|
        force_create(:nonprofit, slug: "#{@copy_base}-#{"%02d" % i}", state_code_slug: state_slug, city_slug: city_slug)
      }}
      let(:algo) {SlugNonprofitNamingAlgorithm.new(state_slug,city_slug)}

      describe 'nonprofit slugs' do

        it 'not a copy' do
          @name = short_slug
          nonprofit
          expect(algo.create_copy_name(@name)).to eq short_slug_copy_today
        end
        it 'one copy exists' do
          @name = short_slug
          @name2 = short_slug_copy_today
          nonprofit
          nonprofit2
          nonprofit_in_other_city
          nonprofit_in_other_state
          expect(algo.create_copy_name(@name)).to eq short_slug_copy_today_plus_1
          expect(algo.create_copy_name(@name2)).to eq short_slug_copy_today_plus_1
        end

        it 'it has 99 as max copies' do
          expect(algo.max_copies).to eq 99
        end


      end
    end
  end
end

