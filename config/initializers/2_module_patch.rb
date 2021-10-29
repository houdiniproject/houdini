# frozen_string_literal: true
# this is available in newer versions of rails that we aren't running
if Rails.version < '5.1'
  class Module
    # When building decorators, a common pattern may emerge:
    #
    #   class Partition
    #     def initialize(event)
    #       @event = event
    #     end
    #
    #     def person
    #       detail.person || creator
    #     end
    #
    #     private
    #       def respond_to_missing?(name, include_private = false)
    #         @event.respond_to?(name, include_private)
    #       end
    #
    #       def method_missing(method, *args, &block)
    #         @event.send(method, *args, &block)
    #       end
    #   end
    #
    # With <tt>Module#delegate_missing_to</tt>, the above is condensed to:
    #
    #   class Partition
    #     delegate_missing_to :@event
    #
    #     def initialize(event)
    #       @event = event
    #     end
    #
    #     def person
    #       detail.person || creator
    #     end
    #   end
    #
    # The target can be anything callable within the object, e.g. instance
    # variables, methods, constants, etc.
    #
    # The delegated method must be public on the target, otherwise it will
    # raise +DelegationError+. If you wish to instead return +nil+,
    # use the <tt>:allow_nil</tt> option.
    #
    # The <tt>marshal_dump</tt> and <tt>_dump</tt> methods are exempt from
    # delegation due to possible interference when calling
    # <tt>Marshal.dump(object)</tt>, should the delegation target method
    # of <tt>object</tt> add or remove instance variables.
    def delegate_missing_to(target, allow_nil: nil)
      target = target.to_s
      target = "self.#{target}" if DELEGATION_RESERVED_METHOD_NAMES.include?(target)

      module_eval <<-RUBY, __FILE__, __LINE__ + 1
        def respond_to_missing?(name, include_private = false)
          # It may look like an oversight, but we deliberately do not pass
          # +include_private+, because they do not get delegated.
          return false if name == :marshal_dump || name == :_dump
          #{target}.respond_to?(name) || super
        end
        def method_missing(method, *args, &block)
          if #{target}.respond_to?(method)
            #{target}.public_send(method, *args, &block)
          else
            begin
              super
            rescue NoMethodError
              if #{target}.nil?
                if #{allow_nil == true}
                  nil
                else
                  raise DelegationError, "\#{method} delegated to #{target}, but #{target} is nil"
                end
              else
                raise
              end
            end
          end
        end
        ruby2_keywords(:method_missing)
      RUBY
    end
  end
else
  puts "Monkeypatch for Module#delegate_missing_to no longer needed"
end