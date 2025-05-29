# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
#
# this code is used for importing records from stripe billing into recurring donations
# Once you create this object, you'll have an array of ImportStripe::SubscriptionToCard records. You can loop through
# them and call `#insert_donation` to load all of the subscriptions
#
# note: even after import, you need to cancel the billing subscriptions on the original stripe account
# @example
# import = ImportStripe.new(Nonprofit.find(1234), subscription_file: "./subscriptions.csv", copy_file: "./copy.csv")
#
# import.each do |i|
#   i.insert_donation
# end
class ImportStripe < Array
  attr_reader :nonprofit

  # @param  nonprofit [Nonprofit] The nonprofit the subscription should be added from
  # @param  subscription_file [string] path to the csv export of the active Stripe billling subscriptions (from https://dashboard.stripe.com/subscriptions?status=active)
  # @param  copy_file [string] path to the csv export of the copy file from copying the customers into our Stripe account (from: https://dashboard.stripe.com/settings/documents)
  def initialize(nonprofit, subscription_file:, copy_file:)
    @nonprofit = nonprofit
    @subscriptions = CSV.table(subscription_file).each.to_a
    @copies = CSV.table(copy_file).each.to_a
    associate_subscriptions_with_cards
  end

  private

  def associate_subscriptions_with_cards
    concat(@subscriptions.map do |row|
      ImportStripe::SubscriptionToCard.new(nonprofit:, row: row, copy_row: @copies.find { |c_row| c_row[:customer_id_new] == row[:customer_id] })
    end)
  end
end
