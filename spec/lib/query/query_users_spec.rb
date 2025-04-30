# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
require "rails_helper"

describe QueryUsers do
  describe ".nonprofit_user_emails", pending: true do
    before(:all) do
      # @np = Psql.execute(Qexpr.new.insert('nonprofits', [{name: 'xxyy'}])).first
      #
      # @users = Psql.execute(Qexpr.new.insert('users', [
      #   {email: "u1#{SecureRandom.uuid}@example.com"},
      #   {email: "u2#{SecureRandom.uuid}@example.com"},
      #   {email: "u3#{SecureRandom.uuid}@example.com"},
      #   {email: "u4#{SecureRandom.uuid}@example.com"},
      #   {email: "u5#{SecureRandom.uuid}@example.com"},
      #   {email: "u6#{SecureRandom.uuid}@example.com"}
      # ]).returning('email', 'id'))
      # @user_wrong_role = Psql.execute(Qexpr.new.insert('users', [{email: "u-wrong-role-#{SecureRandom.uuid}@example.com"}]).returning('email', 'id')).first
      # @user_no_settings = Psql.execute(Qexpr.new.insert('users', [{email: "u-no-role-#{SecureRandom.uuid}@example.com"}]).returning('email,' 'id')).first
      #
      # @roles = Psql.execute(Qexpr.new.insert('roles', [
      #   {user_id: @users[0]['id'], name: 'nonprofit_admin'},
      #   {user_id: @users[1]['id'], name: 'nonprofit_associate'},
      #   {user_id: @users[2]['id'], name: 'nonprofit_admin'},
      #   {user_id: @users[3]['id'], name: 'nonprofit_associate'},
      #   {user_id: @users[4]['id'], name: 'nonprofit_admin'},
      #   {user_id: @users[5]['id'], name: 'nonprofit_associate'},
      #   {user_id: @user_no_settings['id'], name: 'nonprofit_admin'}
      # ], {common_data: {host_id: @np['id'], host_type: 'Nonprofit'}}))
      #
      # @wrong_role = Psql.execute(Qexpr.new.insert('roles', [{host_type: 'Campaign', host_id: @np['id'], user_id: @user_wrong_role['id'], name: 'campaign_editor'}])).first
      # @wrong_role = Psql.execute(Qexpr.new.insert('roles', [{host_type: 'Campaign', host_id: @np['id'], user_id: @user_wrong_role['id'], name: 'campaign_editor'}])).first
      #
      # @email_settings = {notify_payments: true, notify_campaigns: true, notify_events: true, notify_payouts: true, notify_recurring_donations: true}
      #
      # @email_settings = Psql.execute(Qexpr.new.insert('email_settings', [
      #   @email_settings.merge({user_id: @users[0]['id']}),
      #   @email_settings.merge({user_id: @users[1]['id'], notify_payments: false}),
      #   @email_settings.merge({user_id: @users[2]['id'], notify_campaigns: false}),
      #   @email_settings.merge({user_id: @users[3]['id'], notify_events: false}),
      #   @email_settings.merge({user_id: @users[4]['id'], notify_payouts: false}),
      #   @email_settings.merge({user_id: @users[5]['id'], notify_recurring_donations: false}),
      # ], {common_data: {nonprofit_id: @np['id']}, no_timestamps: true}))
    end

    it "Returns all users who have the respective setting enabled (or no settings set), and does not return people without the right role" do
      expect(QueryUsers.nonprofit_user_emails(@np["id"], "notify_payments").sort).to eq([0, 2, 3, 4, 5].map { |id| @users[id]["email"] }.concat([@user_no_settings["email"]]).sort)
      expect(QueryUsers.nonprofit_user_emails(@np["id"], "notify_campaigns").sort).to eq([0, 1, 3, 4, 5].map { |id| @users[id]["email"] }.concat([@user_no_settings["email"]]).sort)
      expect(QueryUsers.nonprofit_user_emails(@np["id"], "notify_events").sort).to eq([0, 1, 2, 4, 5].map { |id| @users[id]["email"] }.concat([@user_no_settings["email"]]).sort)
      expect(QueryUsers.nonprofit_user_emails(@np["id"], "notify_payouts").sort).to eq([0, 1, 2, 3, 5].map { |id| @users[id]["email"] }.concat([@user_no_settings["email"]]).sort)
      expect(QueryUsers.nonprofit_user_emails(@np["id"], "notify_recurring_donations").sort).to eq([0, 1, 2, 3, 4].map { |id| @users[id]["email"] }.concat([@user_no_settings["email"]]).sort)
    end
  end
end
