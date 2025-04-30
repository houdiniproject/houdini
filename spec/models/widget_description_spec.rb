require "rails_helper"

RSpec.describe WidgetDescription, type: :model do
  it_behaves_like "an houidable entity", :wdgtdesc

  it { is_expected.to have_many :campaigns }

  describe "#custom_amounts" do
    it { is_expected.to allow_values([31000]).for(:custom_amounts) }

    it { is_expected.to allow_values(nil).for(:custom_amounts) }

    it { is_expected.to allow_values([31000, {amount: 20000, postfix: true}]).for(:custom_amounts) }

    it { is_expected.to allow_values([31000, {amount: 20000}]).for(:custom_amounts) }

    it { is_expected.to_not allow_values({}).for(:custom_amounts) }

    it { is_expected.to_not allow_values([]).for(:custom_amounts) }
    it { is_expected.to_not allow_values([31000, {postfix: true}]).for(:custom_amounts) }

    it { is_expected.to_not allow_values([310.00]).for(:custom_amounts) }

    it { is_expected.to_not allow_values(["a string"]).for(:custom_amounts) }
  end

  describe "#custom_recurring_donation_phrase" do
    it { is_expected.to allow_value(nil).for(:custom_recurring_donation_phrase) }
    it { is_expected.to allow_value("Custom recurring donation phrase").for(:custom_recurring_donation_phrase) }
  end

  describe "#postfix_element" do
    it { is_expected.to allow_value(nil).for(:postfix_element) }
    it { is_expected.to allow_value({type: "info", html_content: "We are going to <br/> Something"}).for(:postfix_element) }

    it { is_expected.to_not allow_value({}).for(:postfix_element) }
    it { is_expected.to_not allow_value({type: "info"}).for(:postfix_element) }
    it { is_expected.to_not allow_value({html_content: "We are going to <br/> Something"}).for(:postfix_element) }
  end
end
