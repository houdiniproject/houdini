# Events

Houdini has a system for publishing, listening for, and responding to changes on
business objects. We call this the Event Publisher. The Event Publisher is
an `Houdini::EventPublisher` accessible for the `Houdini.event_publisher`.
Events are submitted to listeners when the `.announce` method
`Houdini::EventPublisher` is called. This an event announcement. Each
event announcement has an event_type and zero or more arguments. An event_type
is a Ruby symbol which is a key to listeners pick which event announcements to
listen for. The event announcements zero or more arguments are unique to the
event type.

Example:

```ruby
## in this example, the code is making an event announcement of `:custom_update_type`
## and passing a single argument of a CustomUpdate object. Listener classes
## listening for :custome_event_type announcements, need to make sure to handle
## a CustomUpdate object
Houdini.event_publisher.announce(:custom_update, CustomUpdate.new)
```

## Event Types
What arguments listeners of the event announcements for a given type and what
arguments should be sent as part of the event announcements should be agreed
upon and documented.

## Listener classes
Listener classes are classes which have class methods which are identical to the
event_types it is listening for. By convention, listener class names end with
`Listener`. Like any class As an example:

```ruby
## This listener class listens for the `custom_update` and `build_in_update`
## event announcements
class CustomEventListener
	def self.custom_update(obj)
		# handle the custom_update event announcement
	end

	def self.built_in_update(obj, *args)
	  # handle the build_in_update event announcement
	end
end
```


NOTE: the events discussed in this article ARE NOT the same as a nonprofit's
event, where they sell tickets. We're not great at naming things.

Unless there is a very good reason, the data necessary for handling the event
should be passed in as objects which won't change between when the event is
announced and when the event announcement is handled.

## Campaign
what is going in 

### Campaign created

- Nonprofit
- Campaign
- Campaign creator user
- Campaign creator profile
- campaign_url

### Campaign Modified

- Nonprofit
- Campaign
- Campaign creator user
- Campaign creator profile
- campaign_url

### Campaign Deleted

- Nonprofit
- Campaign
- Campaign creator user
- Campaign creator profile
- campaign_url

## Campaign Gift Option

## Disputes

## Donation

## Event

- Nonprofit
- Event
- Event creator user
- Event creator profile
- event_url

## Export

- Nonprofit
- Requestor
- Payments (when finished)
- Export

## Import

- Nonprofit
- Requestor
- Payments (when finished)
- Import

## Nonprofit

- Nonprofit

-

### Create

## Payout

- Nonprofit
- Bank Account
- Payout
- Payments related
- Supporters

(This one might be difficult to provide all information in message)

## Recurring Donation

- Donation
- Recurring Donation
- Payments for the donations
- Nonprofit
- Supporter
- Payment Method (card)

## Refund

- Donation
- Refund
- Payments for the donations and refunds
- Nonprofitlengthy
- Supporter
- Payment Method (card)

## Roles

- Host (nonprofit, event, campaign)
- Role Itself
- User

## Supporter

- Nonprofit
- Supporter

## Tag

## Ticket (This should be split into Ticket and Ticket purchase)

## User

- User
- User Profile

# Subscribers

Subscribers must be short running pieces of code. Any lengthy operations should
be put on a background through through a job.
