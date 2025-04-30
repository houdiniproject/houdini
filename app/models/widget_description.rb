# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
class WidgetDescription < ApplicationRecord
  setup_houid :wdgtdesc, :houid

  has_many :campaigns

  validate :is_postfix_element_a_hash, :is_postfix_element_correct

  validates :custom_amounts, length: {minimum: 1, allow_nil: true}

  validate :are_custom_amounts_correct

  def to_json_safe_keys
    attributes.slice("custom_amounts", "postfix_element", "custom_recurring_donation_phrase")
  end

  private

  def are_custom_amounts_correct
    unless custom_amounts.nil?
      custom_amounts.each_with_index do |amount, index|
        if amount.is_a? Hash
          unless amount.has_key?("amount") && amount["amount"].is_a?(Integer)
            errors.add(:custom_amounts, "has an invalid amount #{amount} at index #{index}")
          end

        elsif !amount.is_a? Integer
          errors.add(:custom_amounts, "has an invalid amount #{amount} at index #{index}")
        end
      end
    end
  end

  def is_postfix_element_a_hash
    errors.add(:postfix_element, "must be a hash or nil") unless postfix_element.nil? || postfix_element.is_a?(Hash)
  end

  def is_postfix_element_correct
    if postfix_element.is_a? Hash
      if !postfix_element.has_key?("type") || postfix_element["type"] != "info" || !postfix_element.has_key?("html_content")
        errors.add(:postfix_element, "has invalid contents")
      end
    end
  end
end
