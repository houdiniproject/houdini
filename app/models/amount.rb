# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE

# a simple object for storing values. Likely will be replaced with Money from ruby-money
# in future
Amount = Struct.new(:cents, :currency)
