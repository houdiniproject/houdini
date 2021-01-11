# frozen_string_literal: true

# License: AGPL-3.0-or-later WITH WTO-AP-3.0-or-later
# Full license explanation at https://github.com/houdiniproject/houdini/blob/master/LICENSE
require 'wisper'
require 'wisper/activejob'

###
# @description: An event publisher in Houdini for calling listening to async events or responding to them
# Normally, you would use `Houdini.event_publisher` to access the active event publisher after initialization
#
# If you want to add an event listener as part of initialization (which is normally what you want to do),
# you should push your listener class to Rails.application.config.houdini.listeners, which is an array.
#
# Example: Rails.application.config.houdini.listeners.push(PaymentCreationEventListener)
#
# Listener classes have the methods with the name of every event they want to listen to
# as class methods. As an example the if the listener class SupporterListener wanted to run
# some code when the `supporter_create`, or `supporter_merge` event was announced, 
# Supporter Listener would look like so:
#
#	class SupporterListener
# 	def self.supporter_create(supporter)
#   	# run some code
# 	end
#
#		def self.supporter_merge(*supporters)
#			# run some code
#		end
# end
# 
# Currently, all listeners are called asynchronously using ActiveJob. This may change soonish.
###
class Houdini::EventPublisher
	include Wisper::Publisher

	###
	# @description: announce a new event to all of the listeners listening for `event_type`
		# @param event_type {symbol}: the type of event being announced.
		# @param args {array}: the arguments to be passed to the event listeners.
	###
	def announce(event_type, *args)
		broadcast(event_type, *args)
	end

	###
	# @description: asynchronously listen for an event to occur
	# Normally, you don't call this directly, you'll push an listener class to the
	# Rails.application.config.houdini.listeners array in an initializer
	# @param listener {Class}: the listener class 
	###
	def subscribe_async(listener, options = {})
		subscribe(listener, options.merge(async: true))
	end

	###
	# @description: having an array of listeners
	# Normally, you don't call this directly, you'll push a set of listener classes
	# to Rails.application.config.houdini.listeners array in an initializer
	# @param listeners {Array}: an array of listener classes
	###
	def subscribe_all(listeners, options = {})
		listeners.each do |listener|
			subscribe(listener, options.merge(async: true))
		end
	end
end