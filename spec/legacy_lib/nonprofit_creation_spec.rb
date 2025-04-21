# frozen_string_literal: true

#
# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "rails_helper"

RSpec.describe NonprofitCreation do
  subject { described_class.new(result, options).call }

  let(:result) do
    {
      nonprofit: {
        name: "My Nonprofit",
        state_code: "IN",
        city: "\tIndianapolis",
        website: "https://www.mynonprofit.org",
        email: "mynonprofit@email.com",
        phone: "5561999999999"
      },
      user: {
        name: "User Name",
        email: "username@email.com",
        password: "P@ssw0rd!"
      }
    }
  end
  let(:options) { {confirm_admin: true} }

  describe "command side effects" do
    it { is_expected.to include(success: true, messages: ["Nonprofit #{Nonprofit.last.id} successfully created."]) }
  end

  describe "created nonprofit" do
    subject do
      super()
      Nonprofit.find_by(name: "My Nonprofit")
    end

    let(:expected_attributes) do
      {
        state_code: "IN",
        city: "\tIndianapolis",
        website: "https://www.mynonprofit.org",
        email: "mynonprofit@email.com",
        phone: "5561999999999"
      }
    end

    it { is_expected.to have_attributes(expected_attributes) }
  end

  describe "created user" do
    subject do
      super()
      User.find_by(email: "username@email.com")
    end

    it { is_expected.to_not be_super_admin }
    it { is_expected.to be_confirmed }

    it { is_expected.to have_attributes(name: "User Name") }
  end

  describe "super_admin_option" do
    subject do
      super()
      User.find_by(email: "anotherusername@email.com")
    end

    before do
      result[:user][:email] = "anotherusername@email.com"
    end

    let(:options) { {super_admin: true, confirm_user: false} }

    it { is_expected.to be_super_admin }
    it { is_expected.to_not be_confirmed }
  end

  context "when nonprofit can not be saved" do
    before do
      result[:user][:email] = nil
    end

    let(:expected_error_result) do
      {
        success: false,
        messages: [
          "Error creating user: Email can't be blank",
          "Error creating user: Email is invalid"
        ]
      }
    end

    it { is_expected.to eq(expected_error_result) }
  end

  context "when nonprofit state is not in the US" do
    before do
      result[:nonprofit][:state_code] = "KK"
    end

    let(:expected_error_result) do
      {
        success: false,
        messages: [
          "Error creating nonprofit: State code must be a US two-letter state code"
        ]
      }
    end

    it { is_expected.to eq(expected_error_result) }
  end
end
