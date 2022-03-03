# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module MockStripeHelper
  # wraps Stripe mocking for tests as well as creates stripe_test_helper 
  def with_mock_stripe(&block)
    stub_const("STRIPE_TEST_HELPER", StripeMock.create_test_helper)
    StripeMock.start
    block.call
    StripeMock.stop
  end
end
    