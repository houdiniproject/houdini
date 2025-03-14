# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

describe QuerySupporters do

  let(:gift_level_one_time) { 1111 }
  let(:gift_level_recurring) { 5585 }
  let(:gift_level_changed_recurring) {5512 }
  let(:campaign_gift_option_name) { "theowthoinv" }

  
  let(:np) { force_create(:nonprofit)}
  let(:supporter1) { force_create(:supporter, nonprofit: np, name: 'Cacau')}
  let(:supporter2) { force_create(:supporter, nonprofit: np, name: 'Penelope')}
  let(:campaign) { force_create(:campaign, nonprofit: np, slug: "slug stuff")}
  let(:campaign_gift_option) { force_create(:campaign_gift_option, campaign: campaign, name: campaign_gift_option_name, amount_one_time: gift_level_one_time, amount_recurring: gift_level_recurring)}
  let(:campaign_gift1) { force_create(:campaign_gift, campaign_gift_option: campaign_gift_option, donation: donation1)}

  let(:payment_utc_time) { Time.new(2021, 10, 10, 1, 1, 0, "+00:00") }
  let(:payment2_utc_time) { Time.new(2021, 1, 1, 1, 1, 0, "+00:00") }

  let(:donation1) { force_create(:donation, amount: gift_level_one_time, campaign: campaign, supporter:supporter1, date: payment_utc_time)}
  let(:donation4) { force_create(:donation, amount: gift_level_one_time, campaign: campaign, supporter:supporter1, date: payment2_utc_time)}
  let(:donation5) { force_create(:donation, amount: gift_level_one_time, campaign: campaign, supporter:supporter2, date: payment2_utc_time)}

  let(:payment1) {force_create(:payment, gross_amount: gift_level_one_time, donation: donation1, date: payment_utc_time, nonprofit: np)}

  let(:donation2)  {force_create(:donation, amount: gift_level_changed_recurring, campaign: campaign, supporter:supporter2)}
  let(:payment2) {force_create(:payment, gross_amount: gift_level_recurring, donation: donation2, nonprofit: np)}
  let(:payment4) {force_create(:payment, gross_amount: gift_level_one_time, donation: donation4, date: payment2_utc_time,  nonprofit: np)}
  let(:payment5) {force_create(:payment, gross_amount: gift_level_one_time, donation: donation5, date: payment2_utc_time, nonprofit: np)}

  let(:payment3) {force_create(:payment, gross_amount: gift_level_changed_recurring, donation: donation2)}
  let(:campaign_gift2) { force_create(:campaign_gift, campaign_gift_option: campaign_gift_option, donation: donation2)}
  let(:recurring) {force_create(:recurring_donation, donation: donation2, amount: gift_level_changed_recurring)}

  let(:note_content_1) do
    "CONTENT1"
  end

  let(:note_content_2) do
    "CONTENT2"
  end

  let(:note_content_3) do
    "CONTENT3"
  end

  let(:supporter_note_for_s1) do
    force_create(:supporter_note, supporter: supporter1, created_at: DateTime.new(2018,1,5), content: note_content_1)
  end

  let(:supporter_note_1_for_s2) do
    force_create(:supporter_note, supporter: supporter2, created_at: DateTime.new(2018,2,5), content: note_content_2)
  end

  let(:supporter_note_2_for_s2) do
    force_create(:supporter_note, supporter: supporter2, created_at: DateTime.new(2020,4, 5),  content: note_content_3)
  end

  let(:note_content_1) do
    "CONTENT1"
  end

  let(:note_content_2) do
    "CONTENT2"
  end

  let(:note_content_3) do
    "CONTENT3"
  end

  let(:supporter_note_for_s1) do
    force_create(:supporter_note, supporter: supporter1, created_at: DateTime.new(2018,1,5), content: note_content_1)
  end

  let(:supporter_note_1_for_s2) do
    force_create(:supporter_note, supporter: supporter2, created_at: DateTime.new(2018,2,5), content: note_content_2)
  end

  let(:supporter_note_2_for_s2) do
    force_create(:supporter_note, supporter: supporter2, created_at: DateTime.new(2020,4, 5),  content: note_content_3)
  end


  let(:init_all) {
    np
    supporter1
    supporter2
    campaign_gift1
    campaign_gift2
    recurring
    payment1
    payment2
    payment3
  }

  let(:campaign_list) {

    QuerySupporters.campaign_list(np.id, campaign.id, {page: 0})
  }

  it 'counts gift donations properly' do
    init_all
    glm = campaign_list

    data = glm[:data]

    expect(data.map{|i| i['total_raised']}).to match_array([gift_level_one_time, gift_level_recurring])

  end

  describe '.supporter_note_export_enumerable' do 
    let(:lazy_enumerable) do
      supporter_note_for_s1
      supporter_note_1_for_s2
      supporter_note_2_for_s2
      QuerySupporters.supporter_note_export_enumerable(np.id, {})
    end

    it 'is a lazy enumerable' do
      expect(lazy_enumerable).to be_a Enumerator::Lazy
    end

    it 'is three items long' do
      expect(lazy_enumerable.to_a.count).to eq 4
    end

    it 'has correct headers' do
      expect(lazy_enumerable.to_a.first).to eq ['Id', 'Email', 'Note Created At', 'Note Contents']
    end
  end

  describe '.full_search' do
    before do
      supporter1.payments = [payment1, payment4]
      supporter2.payments = [payment5]
    end
    it 'returns the UTC date when the timezone is not specified' do
      result = QuerySupporters.full_search(np.id, { search: 'Cacau' })
      expect(result[:data].first["last_contribution"]).to eq(payment_utc_time.strftime('%m/%d/%y'))
    end

    it 'returns the converted date when the timezone is specified' do
      np.update_attributes(timezone: 'America/New_York')
      result = QuerySupporters.full_search(np.id, { search: 'Cacau' })
      expect(result[:data].first["last_contribution"]).to eq((payment_utc_time - 1.day).strftime('%m/%d/%y'))
    end

    it 'finds the payments on dates after the specified dates' do
      np.update_attributes(timezone: 'America/New_York')
      result = QuerySupporters.full_search(np.id, { last_payment_after: (payment2_utc_time + 1.day).to_s })
      expect(result[:data].count).to eq 1
    end

    it 'finds the payments on dates before the specified dates' do
      np.update_attributes(timezone: 'America/New_York')
      result = QuerySupporters.full_search(np.id, { last_payment_before: payment_utc_time.to_s })
      expect(result[:data].count).to eq 2
    end

    context 'when searching by "at least" contributed' do
      it 'finds the supporter who raised exactly what was being looked for' do
        result = QuerySupporters.full_search(np.id, { total_raised_greater_than_or_equal: "22.22"})
        expect(result[:data].count).to eq 1
      end

      it "finds the supporter who raised $22.22 when they enter characters other than a number and a period" do
        result = QuerySupporters.full_search(np.id, { total_raised_greater_than_or_equal: "$22,.22"})
        expect(result[:data].count).to eq 1
      end
    end

    context 'when searching by "less than" contributed' do
      it 'finds the supporter who raised exactly what was being looked for' do
        result = QuerySupporters.full_search(np.id, { total_raised_less_than: "22.22"})
        expect(result[:data].count).to eq 1
      end

      it "finds the supporter who raised $22.22 when they enter characters other than a number and a period" do
        result = QuerySupporters.full_search(np.id, { total_raised_less_than: "$22,.22"})
        expect(result[:data].count).to eq 1
      end
    end

    context 'when looking for a phone number' do
      before(:each) {
        supporter1.phone = "+1 (920) 915-4980"
        supporter1.save!
      }

      it 'finds when using character filled phone number' do
        result = QuerySupporters.full_search(np.id, { search: "+1(920) 915*4980a" })
        expect(result[:data][0]['id']).to eq supporter1.id
      end

      it 'finds when using spaced phone number' do 
        result = QuerySupporters.full_search(np.id, { search: "1 920 915 4980" })
        expect(result[:data][0]['id']).to eq supporter1.id
      end

      it 'finds when using nonspaced phone number' do 
        result = QuerySupporters.full_search(np.id, { search: "19209154980" })
        expect(result[:data][0]['id']).to eq supporter1.id
      end

      it 'does not find based on partial phone number' do 
        result = QuerySupporters.full_search(np.id, { search: "9209154980" })
        expect(result[:data].count).to eq 0 # just the headers
      end
    end

    context 'when looking for a blank phone number' do
      before(:each) {
        supporter1.phone = " "
        supporter1.save!
      }

      it 'finds when using character filled phone number' do 
        result = QuerySupporters.full_search(np.id, { search: "A search term" })
        expect(result[:data].count).to eq 0
      end
    end

    context 'when filtering by campaign' do
      it "finds one supporter" do
        donation1
        donation4 # this is the second for one of the supporters. This verifies we only get a single supporter no matter how many donations they have
        result = QuerySupporters.full_search(np.id, { campaign_id: campaign.id.to_s})
        expect(result[:data].count).to eq 2
      end
    end
  end

  describe '.dupes_on_name_and_phone' do
    subject { QuerySupporters.dupes_on_name_and_phone(np.id) }

    it 'finds supporters with the same name and phone' do
      supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890')
      supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '(123) 456-7890')

      expect(subject).to eq([[supporter_1.id, supporter_2.id]])
    end

    context 'when different names' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', phone: '(123) 456-7890')

        expect(subject).to match_array([])
      end
    end

    context 'when different phones' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567891')

        expect(subject).to match_array([])
      end
    end

    context 'when the name is empty' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: '', phone: '1234567890')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: '', phone: '(123) 456-7890')

        expect(subject).to eq([])
      end
    end

    context 'when the name is nil' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: nil, phone: '1234567890')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: nil, phone: '(123) 456-7890')

        expect(subject).to eq([])
      end
    end

    context 'when not on strict mode' do
      subject { QuerySupporters.dupes_on_name_and_phone(np.id, false) }
      context 'when names are the same but with different casing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau', phone: '1234567890')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'CACAU', phone: '(123)4567890')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when names are the same but with different spacing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau borges', phone: '1234567890')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', phone: '(123)4567890')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when names are the same but with special characters' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau-borges', phone: '1234567890')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau.Borges', phone: '(123)4567890')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when the names are not the same' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau', phone: '1234567890')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau borges', phone: '(123)4567890')

          expect(subject).to match_array([])
        end
      end
    end
  end

  describe '.dupes_on_name_and_address' do
    subject { QuerySupporters.dupes_on_name_and_address(np.id) }

    it 'finds supporters with the same name and address' do
      supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue')
      supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue')

      expect(subject).to eq([[supporter_1.id, supporter_2.id]])
    end

    context 'when different names' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: 'Clear Waters Avenue')

        expect(subject).to match_array([])
      end
    end

    context 'when different addresses' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear.Waters.Avenue')

        expect(subject).to match_array([])
      end
    end

    context 'when the name is empty' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: '', address: 'Clear Waters Avenue')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: '', address: 'Clear Waters Avenue')

        expect(subject).to eq([])
      end
    end

    context 'when the name is nil' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: nil, address: 'Clear Waters Avenue')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: nil, address: 'Clear Waters Avenue')

        expect(subject).to eq([])
      end
    end

    context 'when not on strict mode' do
      subject { QuerySupporters.dupes_on_name_and_address(np.id, false) }
      context 'when names are the same but with different casing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau', address: 'Clear Waters Avenue')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'CACAU', address: 'Clear Waters Avenue')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when names are the same but with different spacing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'cacauborges', address: 'Clear Waters Avenue')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters Avenue')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when names are the same but with special characters' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau-borges', address: 'Clear Waters Avenue')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau.Borges', address: 'Clear Waters Avenue')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when the names are not the same' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau', address: 'Clear Waters Avenue')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau borges', address: 'Clear Waters Avenue')

          expect(subject).to match_array([])
        end
      end

      context 'when the name is empty' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: '', address: 'Clear Waters Avenue')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: '', address: 'Clear Waters Avenue')

          expect(subject).to eq([])
        end
      end

      context 'when the name is nil' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: nil, address: 'Clear Waters Avenue')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: nil, address: 'Clear Waters Avenue')

          expect(subject).to eq([])
        end
      end

      context 'when addresses are the same but with different casing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters Avenue')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'clear waters avenue')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when addresses are the same but with different spacing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters Avenue')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'ClearWatersAvenue')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when addresses are the same but with special characters' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters . Avenue')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters - Avenue')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when the addresses are not the same' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters Avenue')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Avenue, Clear Waters')

          expect(subject).to match_array([])
        end
      end
    end
  end

  describe '.dupes_on_last_name_and_address_and_email' do
    subject { QuerySupporters.dupes_on_last_name_and_address_and_email(np.id) }

    it 'finds supporters with the same last name and address and email' do
      supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters Avenue', email: "email@example.com")
      supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope Borges', address: 'Clear Waters Avenue', email: "email@example.com")
      supporter_3 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope Schultz', address: 'Clear Waters Avenue', email: "email@example.com")
 
      expect(subject).to eq([[supporter_1.id, supporter_2.id]])
    end

    context 'when different names' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters Avenue', email: "email@example.com")
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope Schultz', address: 'Clear Waters Avenue', email: "email@example.com")

        expect(subject).to match_array([])
      end
    end

    context 'when different addresses' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue', email: "email@example.com")
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear.Waters.Avenue')

        expect(subject).to match_array([])
      end
    end

    context 'when the name is empty' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: '', address: 'Clear Waters Avenue', email: "email@example.com")
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: '', address: 'Clear Waters Avenue', email: "email@example.com")

        expect(subject).to eq([])
      end
    end

    context 'when the name is nil' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: nil, address: 'Clear Waters Avenue', email: "email@example.com")
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: nil, address: 'Clear Waters Avenue', email: "email@example.com")

        expect(subject).to eq([])
      end
    end

    context 'when the email is nil' do
      it 'finds' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue', email: nil)
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue', email: nil)

        expect(subject).to eq([[supporter_1.id, supporter_2.id]])
      end
    end

    context 'when not on strict mode' do
      subject { QuerySupporters.dupes_on_name_and_address(np.id, false) }
      context 'when names are the same but with different casing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau', address: 'Clear Waters Avenue', email: "email@example.com")
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'CACAU', address: 'Clear Waters Avenue', email: "email@example.com")

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when names are the same but with different spacing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'cacauborges', address: 'Clear Waters Avenue', email: "email@example.com")
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters Avenue', email: "email@example.com")

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when names are the same but with special characters' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau-borges', address: 'Clear Waters Avenue', email: "email@example.com")
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau.Borges', address: 'Clear Waters Avenue', email: "email@example.com")

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when the names are not the same' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau', address: 'Clear Waters Avenue', email: "email@example.com")
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau borges', address: 'Clear Waters Avenue', email: "email@example.com")

          expect(subject).to match_array([])
        end
      end

      context 'when the name is empty' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: '', address: 'Clear Waters Avenue', email: "email@example.com")
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: '', address: 'Clear Waters Avenue', email: "email@example.com")

          expect(subject).to eq([])
        end
      end

      context 'when the name is nil' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: nil, address: 'Clear Waters Avenue', email: "email@example.com")
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: nil, address: 'Clear Waters Avenue', email: "email@example.com")

          expect(subject).to eq([])
        end
      end

      context 'when addresses are the same but with different casing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters Avenue', email: "email@example.com")
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'clear waters avenue', email: "email@example.com")

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when addresses are the same but with different spacing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters Avenue', email: "email@example.com")
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'ClearWatersAvenue', email: "email@example.com")

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when addresses are the same but with special characters' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters . Avenue', email: "email@example.com")
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters - Avenue', email: "email@example.com")

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when the addresses are not the same' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Clear Waters Avenue', email: "email@example.com")
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', address: 'Avenue, Clear Waters', email: "email@example.com")

          expect(subject).to match_array([])
        end
      end
    end
  end

  describe '.dupes_on_phone_and_email' do
    subject { QuerySupporters.dupes_on_phone_and_email(np.id) }

    it 'finds supporters with the same phone and email' do
      supporter_1 = force_create(:supporter, nonprofit_id: np.id, phone: '123456789', email: 'cacau@cacau.com')
      supporter_2 = force_create(:supporter, nonprofit_id: np.id, phone: '123456789', email: 'cacau@cacau.com')

      expect(subject).to eq([[supporter_1.id, supporter_2.id]])
    end

    context 'when different phones' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, phone: '123456789', email: 'cacau@cacau.com')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, phone: '1234567890', email: 'cacau@cacau.com')

        expect(subject).to match_array([])
      end
    end

    context 'when different emails' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, phone: '123456789', email: 'cacau@cacau.com')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, phone: '123456789', email: 'cacau@gmail.com')

        expect(subject).to match_array([])
      end
    end

    context 'when the phone is empty' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, phone: '', email: 'cacau@cacau.com')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, phone: '', email: 'cacau@cacau.com')

        expect(subject).to eq([])
      end
    end

    context 'when the phone is nil' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, phone: nil, email: 'cacau@cacau.com')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, phone: nil, email: 'cacau@cacau.com')

        expect(subject).to eq([])
      end
    end

    context 'when the email is empty' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, email: '', phone: '123456789')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, email: '', phone: '123456789')

        expect(subject).to eq([])
      end
    end

    context 'when the email is nil' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, email: nil, phone: '123456789')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, email: nil, phone: '123456789')

        expect(subject).to eq([])
      end
    end

    context 'when not on strict mode' do
      subject { QuerySupporters.dupes_on_phone_and_email(np.id, false) }
      context 'when emails are the same but with different casing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, phone: '123456789', email: 'Cacau@Cacau.com')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, phone: '123456789', email: 'cacau@cacau.com')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when emails are the same but with different spacing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, phone: '123456789', email: 'cacau@cacau.com')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, phone: '123456789', email: 'cacau@cacau.com ')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when the emails are not the same' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, phone: '123456789', email: 'cacau@gmail.com')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, phone: '123456789', email: 'cacau@cacau.com ')

          expect(subject).to match_array([])
        end
      end

      context 'when the email is empty' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, email: '', phone: '123456789')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, email: '', phone: '123456789')

          expect(subject).to eq([])
        end
      end

      context 'when the email is nil' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, email: nil, phone: '123456789')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, email: nil, phone: '123456789')

          expect(subject).to eq([])
        end
      end
    end
  end

  describe '.dupes_on_name_and_email' do
    subject { QuerySupporters.dupes_on_name_and_email(np.id) }
    it 'finds supporters with the same name and email' do
      supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@cacau.com')
      supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@cacau.com')

      expect(subject).to eq([[supporter_1.id, supporter_2.id]])
    end

    context 'when different names' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@cacau.com')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', email: 'cacau@cacau.com')

        expect(subject).to match_array([])
      end
    end

    context 'when different emails' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@cacau.com')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@gmail.com')

        expect(subject).to match_array([])
      end
    end

    context 'when the name is empty' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: '', email: 'cacau@cacau.com')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: '', email: 'cacau@cacau.com')

        expect(subject).to eq([])
      end
    end

    context 'when the name is nil' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: nil, email: 'cacau@cacau.com')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: nil, email: 'cacau@cacau.com')

        expect(subject).to eq([])
      end
    end

    context 'when the email is empty' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, email: '', name: 'Cacau Borges')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, email: '', name: 'Cacau Borges')

        expect(subject).to eq([])
      end
    end

    context 'when the email is nil' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, email: nil, name: 'Cacau Borges')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, email: nil, name: 'Cacau Borges')

        expect(subject).to eq([])
      end
    end

    context 'when not on strict mode' do
      subject { QuerySupporters.dupes_on_name_and_email(np.id, false) }
      context 'when emails are the same but with different casing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'Cacau@Cacau.com')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@cacau.com')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when emails are the same but with different spacing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@cacau.com')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@cacau.com ')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when the emails are not the same' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@gmail.com')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@cacau.com ')

          expect(subject).to match_array([])
        end
      end

      context 'when the email is empty' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, email: '', name: 'Cacau Borges')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, email: '', name: 'Cacau Borges')

          expect(subject).to eq([])
        end
      end

      context 'when the email is nil' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, email: nil, name: 'Cacau Borges')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, email: nil, name: 'Cacau Borges')

          expect(subject).to eq([])
        end
      end

      context 'when names are the same but with different casing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@gmail.com')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'cacau borges', email: 'cacau@gmail.com')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when names are the same but with different spacing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@cacau.com')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'CacauBorges', email: 'cacau@cacau.com')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when the names are not the same' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau Borges', email: 'cacau@gmail.com')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', email: 'cacau@cacau.com ')

          expect(subject).to match_array([])
        end
      end

      context 'when the name is empty' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, email: 'cacau@gmail.com', name: '')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, email: 'cacau@gmail.com', name: '')

          expect(subject).to eq([])
        end
      end

      context 'when the name is nil' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, email: 'cacau@gmail.com', name: nil)
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, email: 'cacau@gmail.com', name: nil)

          expect(subject).to eq([])
        end
      end
    end
  end

  describe '.dupes_on_address' do
    subject { QuerySupporters.dupes_on_address(np.id) }

    it 'finds supporters with the same address' do
      supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue', zip_code: '32101')
      supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: 'Clear Waters Avenue', zip_code: '32101')

      expect(subject).to eq([[supporter_1.id, supporter_2.id]])
    end

    context 'when the address is empty' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: '', zip_code: '32101')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: '', zip_code: '32101')

        expect(subject).to eq([])
      end
    end

    context 'when the address is nil' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: nil, zip_code: '32101')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: nil, zip_code: '32101')

        expect(subject).to eq([])
      end
    end

    context 'when not on strict mode' do
      subject { QuerySupporters.dupes_on_address(np.id, false) }
      context 'when addresses are the same but with different casing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue', zip_code: '32101')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: 'clear waters avenue', zip_code: '32101')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when addresses are the same but with different spacing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue 106', zip_code: '32101')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: 'Clear WatersAvenue 106', zip_code: '32101')

          expect(subject.first).to match_array([supporter_1.id, supporter_2.id])
        end
      end

      context 'when addresses are the same but with special characters' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue 106', zip_code: '32101')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: 'Clear Waters Avenue - 106', zip_code: '32101')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when the addresses are not the same' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue', zip_code: '32101')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: 'Clear Waters Avenue 106', zip_code: '32101')

          expect(subject).to match_array([])
        end
      end
    end
  end

  describe '.dupes_on_address_without_zip_code' do
    subject { QuerySupporters.dupes_on_address_without_zip_code(np.id) }

    it 'finds supporters with the same address' do
      supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue')
      supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: 'Clear Waters Avenue')

      expect(subject).to eq([[supporter_1.id, supporter_2.id]])
    end

    context 'when the address is empty' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: '')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: '')

        expect(subject).to eq([])
      end
    end

    context 'when the address is nil' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: nil)
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: nil)

        expect(subject).to eq([])
      end
    end

    context 'when not on strict mode' do
      subject { QuerySupporters.dupes_on_address_without_zip_code(np.id, false) }
      context 'when addresses are the same but with different casing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: 'clear waters avenue')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when addresses are the same but with different spacing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue 106')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: 'Clear WatersAvenue 106')

          expect(subject.first).to match_array([supporter_1.id, supporter_2.id])
        end
      end

      context 'when addresses are the same but with special characters' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue 106')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: 'Clear Waters Avenue - 106')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when the addresses are not the same' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', address: 'Clear Waters Avenue')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', address: 'Clear Waters Avenue 106')

          expect(subject).to match_array([])
        end
      end
    end
  end

  describe '.dupes_on_phone_and_email_and_address' do
    subject { QuerySupporters.dupes_on_phone_and_email_and_address(np.id) }

    it 'finds supporters with the same phone, email, and address' do
      supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')
      supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')

      expect(subject).to eq([[supporter_1.id, supporter_2.id]])
    end

    context 'when different addresses' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Park Avenue', zip_code: '32101')

        expect(subject).to eq([])
      end
    end

    context 'when different emails' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'penelope@penelope.com', address: 'Clear Waters Avenue', zip_code: '32101')

        expect(subject).to eq([])
      end
    end

    context 'when different zip codes' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32102')

        expect(subject).to eq([])
      end
    end

    context 'when different phones' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567891', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')

        expect(subject).to eq([])
      end
    end

    context 'when the phone is empty' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', phone: '', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')

        expect(subject).to eq([])
      end
    end

    context 'when the phone is nil' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')

        expect(subject).to eq([])
      end
    end

    context 'when the email is empty' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: '', address: 'Clear Waters Avenue', zip_code: '32101')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', phone: '1234567890', email: '', address: 'Clear Waters Avenue', zip_code: '32101')

        expect(subject).to eq([])
      end
    end

    context 'when the email is nil' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', address: 'Clear Waters Avenue', zip_code: '32101')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', phone: '1234567890', address: 'Clear Waters Avenue', zip_code: '32101')

        expect(subject).to eq([])
      end
    end

    context 'when the address is empty' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', address: '', zip_code: '32101')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', phone: '1234567890', email: 'cacau@cacau.com', address: '', zip_code: '32101')

        expect(subject).to eq([])
      end
    end

    context 'when the address is nil' do
      it 'does not find' do
        supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', zip_code: '32101')
        supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', phone: '1234567890', email: 'cacau@cacau.com', zip_code: '32101')

        expect(subject).to eq([])
      end
    end

    context 'when not on strict mode' do
      subject { QuerySupporters.dupes_on_phone_and_email_and_address(np.id, false) }
      context 'when addresses are the same but with different casing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', address: 'clear waters avenue', zip_code: '32101')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when names are the same but with different spacing' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue 106', zip_code: '32101')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear WatersAvenue 106', zip_code: '32101')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when names are the same but with special characters' do
        it 'finds' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue 106', zip_code: '32101')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue - 106', zip_code: '32101')

          expect(subject).to eq([[supporter_1.id, supporter_2.id]])
        end
      end

      context 'when the addresses are not the same' do
        it 'does not find' do
          supporter_1 = force_create(:supporter, nonprofit_id: np.id, name: 'Cacau', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue', zip_code: '32101')
          supporter_2 = force_create(:supporter, nonprofit_id: np.id, name: 'Penelope', phone: '1234567890', email: 'cacau@cacau.com', address: 'Clear Waters Avenue - 106', zip_code: '32101')

          expect(subject).to eq([])
        end
      end
    end
  end

  describe '.for_export_enumerable' do
    describe 'Just first name field' do
      it 'when supporter has no name, just first name is blank' do
        s = create(:supporter, name: '')
        supporters = QuerySupporters.for_export_enumerable(s.nonprofit.id, {}).to_a
        expect(supporters[1][2]).to be_blank
      end

      it 'when supporter has single name, just first name is filled' do
        s = create(:supporter, name: 'Penelope')
        supporters = QuerySupporters.for_export_enumerable(s.nonprofit.id, {}).to_a
        expect(supporters[1][2]).to eq 'Penelope'
      end

      it 'when supporter has a two word name, just first name is filled' do
        s = create(:supporter, name: 'Penelope Rebecca')
        supporters = QuerySupporters.for_export_enumerable(s.nonprofit.id, {}).to_a
        expect(supporters[1][2]).to eq 'Penelope'
      end

      it 'when supporter has a three word name, just first name is filled' do
        s = create(:supporter, name: 'Penelope Rebecca Schultz')
        supporters = QuerySupporters.for_export_enumerable(s.nonprofit.id, {}).to_a
        expect(supporters[1][2]).to eq 'Penelope'
      end
    end
  end
end
