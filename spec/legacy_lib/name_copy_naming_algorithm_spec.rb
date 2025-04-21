# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

describe NameCopyNamingAlgorithm do
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

    let(:short_name) { "short name" }
    let(:short_name_copy_today) { "short name (2020-05-04 copy) 00" }
    let(:short_name_copy_today_plus_1) { "short name (2020-05-04 copy) 01" }
    let(:short_name_copy_yesterday) { "short name (2020-05-03 copy) 00" }
    let(:short_name_copy_today_base) { "short name (2020-05-04 copy)" }

    let(:long_name) { "campaign_name is so long that it must be shortened down" }
    let(:long_name_copy_today) { "#{long_name_copy_today_base} 00" }
    let(:long_name_copy_today_plus_1) { "#{long_name_copy_today_base} 01" }
    let(:long_name_copy_yesterday) { "campaign_name is so long that it must b (2020-05-03 copy) 00" }
    let(:long_name_copy_today_base) { "campaign_name is so long that it must b (2020-05-04 copy)" }
    let(:nonprofit) { force_create(:nm_justice) }

    describe "events" do
      let(:event) { force_create(:event, name: @name, nonprofit: nonprofit) }
      let(:event2) { force_create(:event, name: @name2, nonprofit: nonprofit) }
      let(:events_at_max_copies) do
        (0..30).collect do |i|
          force_create(:event, name: "#{@copy_base} #{format("%02d", i)}", nonprofit: nonprofit)
        end
      end
      let(:algo) { NameCopyNamingAlgorithm.new(Event, nonprofit.id) }

      describe "short event names" do
        it "not a copy" do
          @name = short_name
          event
          expect(algo.create_copy_name(@name)).to eq short_name_copy_today
        end
        it "one copy exists" do
          @name = short_name
          @name2 = short_name_copy_today
          event
          event2
          expect(algo.create_copy_name(@name)).to eq short_name_copy_today_plus_1
          expect(algo.create_copy_name(@name2)).to eq short_name_copy_today_plus_1
        end

        it "one copy yesterday exists" do
          @name = short_name_copy_yesterday
          @name2 = short_name
          event
          event2

          expect(algo.create_copy_name(@name2)).to eq short_name_copy_today
        end

        it "has 30 as max copies" do
          expect(algo.max_copies).to eq 30
        end
      end

      describe "long event names" do
        it "not a copy" do
          @name = long_name
          event
          expect(algo.create_copy_name(@name)).to eq long_name_copy_today
        end
        it "one copy exists" do
          @name = long_name
          @name2 = long_name_copy_today
          event
          event2
          expect(algo.create_copy_name(@name)).to eq long_name_copy_today_plus_1
          expect(algo.create_copy_name(@name2)).to eq long_name_copy_today_plus_1
        end

        it "one copy yesterday exists" do
          @name = long_name_copy_yesterday
          @name2 = long_name
          event
          event2

          expect(algo.create_copy_name(@name2)).to eq long_name_copy_today
        end

        it "has 30 as max copies" do
          expect(algo.max_copies).to eq 30
        end
      end
    end

    describe "campaigns" do
      let(:campaign) { force_create(:campaign, name: @name, nonprofit: nonprofit) }
      let(:campaign2) { force_create(:campaign, name: @name2, nonprofit: nonprofit) }
      let(:algo) { NameCopyNamingAlgorithm.new(Campaign, nonprofit.id) }

      describe "short campaign names" do
        it "not a copy" do
          @name = short_name
          campaign
          expect(algo.create_copy_name(@name)).to eq short_name_copy_today
        end
        it "one copy exists" do
          @name = short_name
          @name2 = short_name_copy_today
          campaign
          campaign2
          expect(algo.create_copy_name(@name)).to eq short_name_copy_today_plus_1
          expect(algo.create_copy_name(@name2)).to eq short_name_copy_today_plus_1
        end

        it "one copy yesterday exists" do
          @name = short_name_copy_yesterday
          @name2 = short_name
          campaign
          campaign2

          expect(algo.create_copy_name(@name2)).to eq short_name_copy_today
        end
      end

      describe "long campaign names" do
        it "not a copy" do
          @name = long_name
          campaign
          expect(algo.create_copy_name(@name)).to eq long_name_copy_today
        end
        it "one copy exists" do
          @name = long_name
          @name2 = long_name_copy_today
          campaign
          campaign2
          expect(algo.create_copy_name(@name)).to eq long_name_copy_today_plus_1
          expect(algo.create_copy_name(@name2)).to eq long_name_copy_today_plus_1
        end

        it "one copy yesterday exists" do
          @name = long_name_copy_yesterday
          @name2 = long_name
          campaign
          campaign2

          expect(algo.create_copy_name(@name2)).to eq long_name_copy_today
        end
      end
    end
  end
end
