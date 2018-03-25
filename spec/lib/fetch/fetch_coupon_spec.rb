require 'spec_helper'
require 'fetch/fetch_coupon'

describe FetchCoupon do

	context '.page' do
		let!(:params) { {name: 'refer-a-friend'} }

		it "retrieves the correct coupon partial" do
			expect(FetchCoupon.page(params)).to eq('refer_a_friend')
		end
	end
end
