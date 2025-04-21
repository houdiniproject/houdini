# frozen_string_literal: true

#
# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
#
# NOTE: this should be moved to bess when Nonprofit and wiki is
class NonprofitCreation
  def initialize(result, options = {})
    result = sanitize_optional_fields(result)
    @nonprofit = ::Nonprofit.new(result[:nonprofit].merge({register_np_only: true}))
    @user = User.new(result[:user])
    @options = options
  end

  def call
    result = {}
    ActiveRecord::Base.transaction do
      result = if @user.save && @nonprofit.save && roles.each(&:save)
        @user.confirm if @options[:confirm_admin]
        {success: true, messages: ["Nonprofit #{@nonprofit.id} successfully created."]}
      else
        retrieve_error_messages
      end
    end
    result
  end

  private

  def retrieve_error_messages
    result = {success: false, messages: []}
    result = retrieve_user_error_messages(result)
    result = retrieve_nonprofit_error_messages(result)
    retrieve_roles_error_messages(result)
  end

  def retrieve_user_error_messages(result)
    @user.errors.full_messages.each { |i| result[:messages] << "Error creating user: #{i}" }
    result
  end

  def retrieve_nonprofit_error_messages(result)
    @nonprofit.errors.full_messages.each { |i| result[:messages] << "Error creating nonprofit: #{i}" }
    result
  end

  def retrieve_roles_error_messages(result)
    roles.each { |role| role.errors.full_messages.each { |i| result[:messages] << "Error creating role: #{i}" } }
    result
  end

  def roles
    roles = [Role.new(host: @nonprofit, name: "nonprofit_admin", user: @user)]
    roles << Role.new(host: @nonprofit, name: "super_admin", user: @user) if @options[:super_admin]
    roles
  end

  def sanitize_optional_fields(result)
    result.transform_values! { |keys| keys.transform_values! { |value| value&.empty? ? nil : value } }
  end
end
