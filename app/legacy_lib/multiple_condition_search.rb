# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
#
# This class assists in searches where you know you want to try a search with list of conditions and stop when your query
# returns a single object.
# For example, let's say you want to search for a single Supporter by name and then, if you still have multiple records, then by name and email.
#
# Assumption: the searches start from the least complex and go up. Probably won't work another way.

# A multiple condition search like that can end in a few different ways:
# * we get to a condition and there are no records
# * we get to the last condition and there are mulitiple records left
# * we get to a condition where there is a single record (success!)

# @example Search for all supporters for a particular Nonprofit using name and then name and email
# search = MultipleConditionSearch.new([
#  ['name = ?', "Penelope Schultz"], # you can use any of the styles used by `#where`
#  {name: "Penelope Schultz", email: 'penelope@schultz.household'}
# ])
# result = search.find(Nonprofit.find(12356).supporters) # result is nil if there was an error otherwise, we get the result
#
# puts 'There were no records found' if search.error == :none
# puts 'There were multiple records on the last condition' if search.error == :multiple_values
#
# if search.error == :multiple_values
#   puts search.result.pluck(:id).join(',') # prints the ids of the records found by the last condition when multiple values were found
# end
#
# if result
#   puts result.id
# end
#

class MultipleConditionSearch
  @subconditions = []

  # @!attribute [r] error the error from getting to either, getting to a condition where no record can be found by the condition or
  #   we get to the last condition and there are still multiple records left
  # 	@return [Symbol,nil] nil if a single result was found at one point. :none if a condition returned no values, :multiple_values if
  #   we got to the last condition and there were multiple records
  attr_reader :error

  # @!attribute result the result of the last condition attempted in the find.
  # 	@return [nil,ActiveRecord::Base,ActiveRecord::Relation] nil if the last condition attempted returned no records,
  #     ActiveRecord::Base if the last query attempted had a single record and ActiveRecord::Relation if the last condition
  #     attempted had multiple records
  attr_reader :result

  # Important note: you MUST wrap all of your conditions into an array
  # @param [Array[string,Array,Hash]] args the subconditions attempted. Each of these correspond to the values you would pass into
  # the method of where. For example, you could

  def initialize(args = [])
    @subconditions = args
    @error = nil
    @result = nil
  end

  # @param [ActiveRecord::Relation] relation something to run these conditions against
  # @return [nil,ActiveRecord::Base] the single record returned from one of the conditions, otherwise nil
  def find(relation)
    @subconditions.each_with_index do |condition, index|
      temp_result = relation.where(condition)
      if temp_result.none?
        @error = :none
        return nil
      elsif temp_result.count == 1
        @result = temp_result.first
        return @result
      elsif index == @subconditions.count - 1 && temp_result.count > 1
        @error = :multiple_values
        @result = temp_result
        return nil
      end
    end
    raise "should never happen"
  end
end
