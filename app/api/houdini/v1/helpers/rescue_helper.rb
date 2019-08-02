# frozen_string_literal: true

module Houdini::V1::Helpers::RescueHelper
  require 'active_support/concern'

  extend ActiveSupport::Concern
  include Grape::DSL::Configuration
  module ClassMethods
    def rescue_ar_invalid(*class_to_hash)
      rescue_with ActiveRecord::RecordInvalid do |error|
        output = []
        error.record.errors do |attr, message|
          output.push(params: "#{class_to_hash[error.record.class]}['#{attr}']",
                      message: message)
        end
        raise Grape::Exceptions::ValidationErrors, output
      end
  end
  end
end
