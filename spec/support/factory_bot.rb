# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/main/LICENSE
module FactoryBotExtensions
  def force_create(name, args = {})
    v = build(name, args)
    v.save(validate: false)
    v
  end
end

RSpec.configure do |config|
  # require 'factorybot_rails'
  # FactoryBot.find_definitions
  # config.before(:suite) { FactoryBot.reload }
  config.include FactoryBot::Syntax::Methods
  config.include FactoryBotExtensions
end
