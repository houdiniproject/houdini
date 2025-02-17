# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
require "param_validation"
module CalculateFees
  BaseFeeRate = 0.022 # 2.2%
  PerTransaction = 30 # 30 cents

  def self.for_single_amount(amount, platform_fee = 0.0)
    ParamValidation.new({fee: platform_fee, amount: amount},
      amount: {min: 0, is_integer: true},
      fee: {min: 0.0, is_float: true})
    fee = BaseFeeRate + platform_fee
    (amount * fee).ceil.to_i + PerTransaction
  end
end
