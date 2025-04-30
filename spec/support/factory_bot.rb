# License: AGPL-3.0-or-later WITH Web-Template-Output-Additional-Permission-3.0-or-later
module FactoryBotExtensions
  def force_create(name, *array_args, **args)
    v = build(name, *array_args, **args)
    v.save(validate: false)
    v
  end
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include FactoryBotExtensions
end
