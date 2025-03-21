# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
if Rails.version < '7'
  # want to catch this deprecation:
  # DEPRECATION WARNING: Using `return`, `break` or `throw` to exit a transaction block is
  # deprecated without replacement. If the `throw` came from
  # `Timeout.timeout(duration)`, pass an exception class as a second
  # argument so it doesn't use `throw` to abort its block. This results
  # in the transaction being committed, but in the next release of Rails
  # it will rollback.

  ActiveSupport::Deprecation.disallowed_warnings = [
    "to exit a transaction block"
  ]

else
  raise "remove unneeded deprecation for 'Using return, break or throw to exit a transaction block is deprecated without replacement'"
end