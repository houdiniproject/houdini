# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

# StripeMockHelper wraps the StripeMock to simplify creating a single test helper as part of
# a test session. Generally, you can use StripeMockHelper like StripeMock except it adds a "default_helper"
# to get the StripeTestHelper for the session.
# @see StripeMock
StripeMockHelper = Class.new do
  delegate_missing_to :StripeMock

  # Most StripeMock sessions only need a single test helper so you can get it here
  # @return a Stripe test helper or nil if none is set
  def default_helper
    @default_helper if defined? @default_helper
  end

  alias_method :stripe_helper, :default_helper

  # sets up a StripeMock session and sets up StripeMock::default_helper
  # note: Rspec is set up to autostop a StripeMock session when an example finishes
  def start
    return if default_helper

    StripeMock.start
    create_default_helper
  end

  # stops a StripeMock session and clears StripeMock::default_helper
  def stop
    clear_default_helper
    StripeMock.stop
  end

  # wraps a block in a StripeMock session and sets up StripeMock::default_helper
  def mock(&block)
    start

    block.call

    stop
  end

  private

  # Clears the default test helper for the current StripeMock session
  def clear_default_helper
    remove_instance_variable :@default_helper if defined? @default_helper
  end

  # Creates a default test helper for the current StripeMock session
  def create_default_helper
    @default_helper ||= StripeMock.create_test_helper  # rubocop:disable Naming/MemoizedInstanceVariableName
  end
end.new
