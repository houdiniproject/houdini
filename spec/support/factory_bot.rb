module FactoryBotExtensions
	def force_create(name, args={})
		v = build(name, args)
		v.save(validate:false)
		v
	end
end

RSpec.configure do |config|
	config.include FactoryBot::Syntax::Methods
	config.include FactoryBotExtensions
end
