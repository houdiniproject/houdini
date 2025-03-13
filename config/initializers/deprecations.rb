if Rails.env.test?
  
  # want to catch this deprecation:
  # DEPRECATION WARNING: Using `return`, `break` or `throw` to exit a transaction block is
  # deprecated without replacement. If the `throw` came from
  # `Timeout.timeout(duration)`, pass an exception class as a second
  # argument so it doesn't use `throw` to abort its block. This results
  # in the transaction being committed, but in the next release of Rails
  # it will rollback.

  ActiveSupport::Deprecation.behavior = ->(message, callstack, deprecation_horizon, gem_name) {
    if message =~ /.*to exit a transaction block is deprecated without replacement.*/
      raise ActiveSupport::DeprecationException, message, callstack
    end
  }
end