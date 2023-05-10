# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require 'rails_helper'

RSpec.describe User, :type => :model do

  it {is_expected.to have_db_column(:locked_at).of_type(:datetime)}
  it {is_expected.to have_db_column(:unlock_token).of_type(:string)}
  it {is_expected.to have_db_column(:failed_attempts).of_type(:integer).with_options(default:0, null:false)}

  it 'locks correctly after 10 attempts' do
    user = create(:user)
    user.confirm
    
    10.times { user.valid_for_authentication?{ false } }
    assert user.reload.access_locked?
  end

  describe '.send_reset_password_instructions' do

    context 'with a valid email address' do

      context 'when the user hasn\'t requested a reset password token before' do
        it 'returns a User' do
          create(:user, email: 'evil_hacker@netflix.io')
          expect(User.send_reset_password_instructions(attributes={email: 'evil_hacker@netflix.io'})).to be_a User
        end

        it 'returns the correct user' do
          user = create(:user, email: 'sneaky_scammer@fb.net')
          expect(User.send_reset_password_instructions(attributes={email: 'sneaky_scammer@fb.net'})).to eq(user)
        end

        it 'returns an object with no errors' do
          create(:user, email: 'gone_phishing@twtr.gov')
          expect(User.send_reset_password_instructions(attributes={email: 'gone_phishing@twtr.gov'}).errors.messages).to eq({})
        end
      end

      context 'when a user has requested a reset password token recently (< 5 min ago)' do
        it 'returns the correct user' do
          user = create(:user, email: 'fraud_fool@insta.org')
          User.send_reset_password_instructions(attributes={email: 'fraud_fool@insta.org'})
          expect(User.send_reset_password_instructions(attributes={email: 'fraud_fool@insta.org'})).to eq(user)
        end

        it 'adds "can\'t reset password because a request was just sent" error to returned user' do
          create(:user, email: 'perilous_programmer@snap.com')
          User.send_reset_password_instructions(attributes={email: 'perilous_programmer@snap.com'})
          expect(
            User.send_reset_password_instructions(attributes={email: 'perilous_programmer@snap.com'}).errors.messages[:base]
          ).to eq(["can't reset password because a request was just sent"])
        end
      end
    end

    context 'with an invalid email address' do
      it 'returns a User' do
        expect(
          User.send_reset_password_instructions(attributes={email: 'unknown_goose@domain.net'})
        ).to be_a User
      end

      it 'returns a blank User' do
        expect(
          User.send_reset_password_instructions(attributes={email: 'unknown_panda@domain.net'}).id
        ).to be_nil
      end

      it 'adds "not found" errors to email' do
        expect(
          User.send_reset_password_instructions(attributes={email: 'unknown_lizard@domain.net'}).errors.messages[:email]
        ).to eq(["not found"])
      end
    end
  end
end
