# backport fix for cve-2022-44566
# from  https://github.com/rails/rails/blob/1b22647c4bfefce63e07661b8aad5b3003118321/activerecord/lib/active_record/connection_adapters/postgresql/quoting.rb

if Rails.version < '5'
  module ActiveRecord
    module ConnectionAdapters
      module PostgreSQL
        module Quoting
          class IntegerOutOf64BitRange < StandardError
            def initialize(msg)
              super(msg)
            end
          end

          private

          def check_int_in_range(value)
            if value.to_int > 9223372036854775807 || value.to_int < -9223372036854775808
              exception = <<~ERROR
                Provided value outside of the range of a signed 64bit integer.

                PostgreSQL will treat the column type in question as a numeric.
                This may result in a slow sequential scan due to a comparison
                being performed between an integer or bigint value and a numeric value.

                To allow for this potentially unwanted behavior, set
                ActiveRecord::Base.raise_int_wider_than_64bit to false.
              ERROR
              raise IntegerOutOf64BitRange.new exception
            end
          end

          def _quote(value)
            if ActiveRecord::Base.raise_int_wider_than_64bit && value.is_a?(Integer)
              check_int_in_range(value)
            end
            case value
            when Type::Binary::Data
              "'#{escape_bytea(value.to_s)}'"
            when OID::Xml::Data
              "xml '#{quote_string(value.to_s)}'"
            when OID::Bit::Data
              if value.binary?
                "B'#{value}'"
              elsif value.hex?
                "X'#{value}'"
              end
            when Float
              if value.infinite? || value.nan?
                "'#{value}'"
              else
                super
              end
            else
              super
            end
          end
  
        end
      end
    end
  
    # backport from https://github.com/rails/rails/blob/daa00c8357dc12ce24f89d92e4ceeabebb3af3d1/activerecord/lib/active_record/core.rb
    module CoreExtension
      extend ActiveSupport::Concern
      included do
        ##
        # :singleton-method:
        # Application configurable boolean that denotes whether or not to raise
        # an exception when the PostgreSQLAdapter is provided with an integer that is
        # wider than signed 64bit representation
        mattr_accessor :raise_int_wider_than_64bit, instance_writer: false do 
           true
        end
      end
    end
  end

  ActiveRecord::Base.send(:include, ActiveRecord::CoreExtension)
else
  raise "monkeypatch needs to be evaluated as it was built for Rails 4.2"
end