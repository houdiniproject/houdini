V2 of Houdini will have an event based system as described in #113. Events are ONE-WAY notifications from a publisher to a subscriber. We wrap `ActiveSupport::Notifications` a custom class called `Houdini::Notifications` (there's a chance we'll want to use a different notification system at some point).

Unless there is a very good reason, the data necessary for handling the event should be passed in as actual objects and attributes, not references to a database key. The idea is that you shouldn't have to worry about additional changes to entities being made before you can react to the event.


## Campaign

### Campaign created

* Nonprofit
* Campaign
* Campaign creator user
* Campaign creator profile
* campaign_url

### Campaign Modified

* Nonprofit
* Campaign
* Campaign creator user
* Campaign creator profile
* campaign_url

### Campaign Deleted

* Nonprofit
* Campaign
* Campaign creator user
* Campaign creator profile
* campaign_url

## Campaign Gift Option

todo

## Donation

## Event

* Nonprofit
* Event
* Event creator user
* Event creator profile
* event_url

## Export

## Import



## Nonprofit

### Create

### Verification

## Payout

## Recurring Donation

## Refund

## Supporter

* Nonprofit
* Supporter


## Tag



## Ticket


## User

# Subscribers

Subscribers must be short running pieces of code. Any lengthy operations should be put on a background through through a job.