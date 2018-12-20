# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module CalculateDefaultAddressStrategy

  # @param [Symbol] strategy_key
  # @return [DefaultAddressStrategy::Strategy]
  # @raise ArgumentError strategy_key is invalid
  def self.find_strategy(strategy_key=:manual)
    case strategy_key
    when :manual
      return DefaultAddressStrategies::ManualStrategy
    when :always_first
      return DefaultAddressStrategies::AlwaysFirstStrategy
    when :always_last
      return DefaultAddressStrategies::AlwaysLastStrategy
    else
      raise ArgumentError
    end
  end
end