# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later

module CalculateSuggestedAmounts
  require_relative "numeric" # this is loading the local numeric

  MIN = 25
  MAX = 100000000
  BRACKETS = [{range: MIN...1000, delta: 100},
    {range: 1000...5000, delta: 500},
    {range: 5000...MAX, delta: 2500}]

  # Calculates a set of suggested donation amounts based upon our internal special algorithm
  # This is most useful for suggesting amounts a recurring donor could change to
  # @return [Array<Integer>] suggested amounts for your donation
  # @param [Number] amount the amount in cents to start from
  def self.calculate(amount)
    ParamValidation.new({amount: amount}, amount: {required: true, is_a: Numeric, min: MIN, max: MAX})
    result = []

    step_down_val = step_down_value(amount)
    unless step_down_val.nil?
      result.push(step_down_val)
    end

    higher_amounts = []
    while higher_amounts.empty? || (higher_amounts.length < 3 && !higher_amounts.last.nil?)
      if higher_amounts.empty?
        higher_amounts.push(step_up_value(amount))
      else
        higher_amounts.push(step_up_value(higher_amounts.last))
      end
    end
    result.concat(higher_amounts.reject { |i| i.nil? })
  end

  def self.step_down_value(amount)
    initial_bracket = get_bracket_by_amount(amount)

    # check_floor_for_delta
    delta_floor = amount.floor_for_delta(initial_bracket[:delta])

    # not on a delta, just send a floor
    if delta_floor != amount
      return (delta_floor < MIN) ? nil : delta_floor
    end

    potential_lower_amount = amount - initial_bracket[:delta]

    # is potential_lower_amount < our MIN? if so, return nil
    return nil if potential_lower_amount < MIN

    new_bracket = get_bracket_by_amount(potential_lower_amount)

    # if in same bracket, potential_lower_amount is our step_down_value

    if initial_bracket == new_bracket
      return potential_lower_amount
    end

    # we're going to step down by our new bracket value then
    amount - new_bracket[:delta]
  end

  def self.step_up_value(amount)
    bracket = get_bracket_by_amount(amount)

    # check_ceil_for_delta
    delta_ceil = amount.ceil_for_delta(bracket[:delta])

    # not on a delta, just send a ceil
    if delta_ceil != amount
      return (delta_ceil >= MAX) ? nil : delta_ceil
    end

    potential_higher_amount = amount + bracket[:delta]

    # is potential_higher_amount >= our MAX? if so, return nil
    return nil if potential_higher_amount >= MAX

    potential_higher_amount
  end

  def self.get_bracket_by_amount(amount)
    BRACKETS.select { |i| i[:range].cover?(amount) }.first
  end
end
