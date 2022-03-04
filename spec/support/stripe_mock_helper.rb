# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later


# StripeMockHelper adds some helper methods to RSpec. Additionally, it builds on
# the features in StripeMock by creating

module StripeMockHelper

  # Creates a default test helper for the current StripeMock session
  def self.create_default_helper
    @@default_helper ||= StripeMock.create_test_helper
  end

  # Most StripeMock sessions only need a single test helper so you can get it here
  # @return a Stripe test helper or nil if none is set
  def self.default_helper
    if defined? @@default_helper
      @@default_helper 
    else
      nil
    end
  end

  # Clears the default test helper for the current StripeMock session
  def self.clear_default_helper
    remove_class_variable :@@default_helper if defined? @@default_helper
  end

  
  # sets up a StripeMock session and sets up StripeMock::default_helper
  # note: Rspec is set up to autostop a StripeMock session when an example finishes
  def self.start
    unless default_helper
      StripeMock.start
      create_default_helper
    end
  end

  # stosp a StripeMock session and clears StripeMock::default_helper
  def self.stop
    clear_default_helper
    StripeMock.stop
  end

  # helper to get StripeMock::default_helper
  def self.stripe_helper
    default_helper
  end

  # wraps a block in a StripeMock session and sets up StripeMock::default_helper
  def self.mock(&block)
    start

    block.call
    
    stop
  end
end
    