# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
class CopyNamingAlgorithm
  DEFAULT_MAX_LENGTH = 255
  DEFAULT_MAX_COPIES = 255
  DEFAULT_SEPARATOR_BEFORE_COPY_NUMBER = "_"

  def copy_addition
    raise NotImplementedError
  end

  def separator_before_copy_number
    DEFAULT_SEPARATOR_BEFORE_COPY_NUMBER
  end

  def max_length
    DEFAULT_MAX_LENGTH
  end

  def max_copies
    DEFAULT_MAX_COPIES
  end

  def get_already_used_name_entities(base_name)
    raise NotImplementedError
  end

  def get_name_for_entity(name_entity)
    name_entity
  end

  def create_copy_name(name_to_copy)
    # remove copy addition and number
    base_name = name_to_copy.gsub(/#{Regexp.quote(copy_addition)}(#{Regexp.quote(separator_before_copy_number)}\d+)?\z/, "")
    name_entities_to_check_against = get_already_used_name_entities(base_name).collect { |entity| get_name_for_entity(entity) }.to_a
    (0..max_copies - 1).each { |copy_num|
      name_to_test = generate_name(base_name, copy_num)
      if name_entities_to_check_against.none? { |entity_name| entity_name == name_to_test }
        return name_to_test
      end
    }

    raise UnableToCreateNameCopyError.new("It's not possible to generate a UNIQUE name using name_to_copy: #{name_to_copy} copy_addition: #{copy_addition} separator_before_copy_number: #{separator_before_copy_number} max_copy_num: #{max_copies}  max_length: #{max_length}")
  end

  def generate_name(name_to_copy, copy_num)
    what_to_add = copy_addition + separator_before_copy_number + generate_copy_number(copy_num)

    # is what_to_add longer than max length? If so, it's not possible to create a copy
    if what_to_add.length > max_length
      raise UnableToCreateNameCopyError.new("It's not possible to generate a name using name_to_copy: #{name_to_copy} copy_addition: #{copy_addition} separator_before_copy_number: #{separator_before_copy_number} copy_num: #{copy_num} max_length: #{max_length}")
    end
    max_length_for_name_to_copy = max_length - what_to_add.length
    name_to_copy[0..max_length_for_name_to_copy - 1] + what_to_add
  end

  def generate_copy_number(unprefixed_copy_number)
    number_of_digits = Math.log10(max_copies).floor + 1
    "%0#{number_of_digits}d" % unprefixed_copy_number
  end
end

class UnableToCreateNameCopyError < ArgumentError
end
