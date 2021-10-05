# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require 'rails_helper'

RSpec.describe '/api/campaign_gift_options/index.json.jbuilder', type: :view do
	subject(:json) do
		assign(:campaign_gift_options, [
										campaign_gift_option_with_campaign_with_one_time_amount,
										campaign_gift_option_with_campaign_with_recurring_amount,
										campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount
									])
		render
		JSON.parse(rendered)
	end

	let(:campaign_gift_option_with_campaign_with_one_time_amount) do
		create(:campaign_gift_option_with_campaign_with_one_time_amount)
	end
	let(:campaign_gift_option_with_campaign_with_recurring_amount) do
		create(:campaign_gift_option_with_campaign_with_recurring_amount,
									campaign: campaign_gift_option_with_campaign_with_one_time_amount.campaign)
	end
	let(:campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount) do
		create(:campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount,
									campaign: campaign_gift_option_with_campaign_with_one_time_amount.campaign)
	end

	def base_path(nonprofit_id, campaign_id, campaign_gift_option_id)
		"/api/nonprofits/#{nonprofit_id}/campaigns/#{campaign_id}/campaign_gift_options/#{campaign_gift_option_id}"
	end

	def base_url(nonprofit_id, campaign_id, campaign_gift_option_id)
		"http://test.host#{base_path(nonprofit_id, campaign_id, campaign_gift_option_id)}"
	end

	it { expect(json.count).to eq 3 }

	describe 'details of the campaign_gift_option_with_campaign_with_one_time_amount' do
		subject(:first) do
			json[0]
		end

		let(:campaign_gift_option) { campaign_gift_option_with_campaign_with_one_time_amount }

		let(:campaign) { campaign_gift_option.campaign }
		let(:nonprofit) { campaign_gift_option.nonprofit }

		it {
			is_expected.to include('object' => 'campaign_gift_option')
		}

		it {
			is_expected.to include('id' => campaign_gift_option.id)
		}

		it {
			is_expected.to include('name' => 'has one time amount')
		}

		it {
			is_expected.to include('nonprofit' => nonprofit.id)
		}

		it {
			is_expected.to include('deleted' => false)
		}

		it {
			is_expected.to include('campaign' => campaign.id)
		}

		it {
			is_expected.to include('description' => 'one time description')
		}

		it {
			is_expected.to include('hide_contributions' => false)
		}

		it {
			is_expected.to include('order' => nil)
		}

		it {
			is_expected.to include('to_ship' => false)
		}

		it {
			is_expected.to include('quantity' => nil)
		}

		it {
			is_expected.to include('gift_option_amount' => match_array(
				[{
					'amount' => { 'cents' => 200, 'currency' => nonprofit.currency },
					'recurrence' => nil
				}]
			))
		}

		it {
			is_expected.to include('url' =>
					base_url(nonprofit.id, campaign.id, campaign_gift_option.id))
		}
	end

	describe 'details of the campaign_gift_option_with_campaign_with_recurring_amount' do
		subject(:second) do
			json[1]
		end

		let(:campaign_gift_option) { campaign_gift_option_with_campaign_with_recurring_amount }

		let(:campaign) { campaign_gift_option.campaign }
		let(:nonprofit) { campaign_gift_option.nonprofit }

		it {
			is_expected.to include('object' => 'campaign_gift_option')
		}

		it {
			is_expected.to include('id' => campaign_gift_option.id)
		}

		it {
			is_expected.to include('name' => 'has recurring amount')
		}

		it {
			is_expected.to include('nonprofit' => nonprofit.id)
		}

		it {
			is_expected.to include('deleted' => false)
		}

		it {
			is_expected.to include('campaign' => campaign.id)
		}

		it {
			is_expected.to include('description' => 'a recurring description!')
		}

		it {
			is_expected.to include('hide_contributions' => false)
		}

		it {
			is_expected.to include('order' => nil)
		}

		it {
			is_expected.to include('to_ship' => false)
		}

		it {
			is_expected.to include('quantity' => 4)
		}

		it {
			is_expected.to include('gift_option_amount' => match_array(
				[{
					'amount' => { 'cents' => 400, 'currency' => nonprofit.currency },
					'recurrence' => { 'interval' => 1, 'type' => 'monthly' }
				}]
			))
		}

		it {
			is_expected.to include('url' =>
			base_url(nonprofit.id, campaign.id, campaign_gift_option.id))
		}
	end

	describe 'details of the campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount' do
		subject(:third) do
			json[2]
		end

		let(:campaign_gift_option) { campaign_gift_option_with_campaign_with_both_one_time_and_recurring_amount }

		let(:campaign) { campaign_gift_option.campaign }
		let(:nonprofit) { campaign_gift_option.nonprofit }

		it {
			is_expected.to include('object' => 'campaign_gift_option')
		}

		it {
			is_expected.to include('id' => campaign_gift_option.id)
		}

		it {
			is_expected.to include('name' => 'has both one time and recurring amount')
		}

		it {
			is_expected.to include('nonprofit' => nonprofit.id)
		}

		it {
			is_expected.to include('deleted' => false)
		}

		it {
			is_expected.to include('campaign' => campaign.id)
		}

		it {
			is_expected.to include('description' => 'one time AND recurring')
		}

		it {
			is_expected.to include('hide_contributions' => true)
		}

		it {
			is_expected.to include('order' => 5)
		}

		it {
			is_expected.to include('to_ship' => true)
		}

		it {
			is_expected.to include('quantity' => 50)
		}

		it {
			is_expected.to include('gift_option_amount' => match_array(
				[
					{
						'amount' => { 'cents' => 500, 'currency' => nonprofit.currency },
						'recurrence' => { 'interval' => 1, 'type' => 'monthly' }
					},
					{
						'amount' => { 'cents' => 300, 'currency' => nonprofit.currency },
						'recurrence' => nil
					}

				]
			))
		}

		it {
			is_expected.to include('url' =>
			base_url(nonprofit.id, campaign.id, campaign_gift_option.id))
		}
	end
end
