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

## Disputes

## Donation

## Event

* Nonprofit
* Event
* Event creator user
* Event creator profile
* event_url

## Export

* Nonprofit
* Requestor
* Payments (when finished)
* Export

## Import

* Nonprofit
* Requestor
* Payments (when finished)
* Import

## Nonprofit

* Nonprofit
* 

### Create




## Payout

* Nonprofit
* Bank Account
* Payout
* Payments related
* Supporters

(This one might be difficult to provide all information in message)

## Recurring Donation

* Donation
* Recurring Donation
* Payments for the donations
* Nonprofit
* Supporter
* Payment Method (card)

## Refund

* Donation
* Refund
* Payments for the donations and refunds
* Nonprofit
* Supporter
* Payment Method (card)

## Roles
* Host (nonprofit, event, campaign)
* Role Itself
* User

## Supporter

* Nonprofit
* Supporter


## Tag

## Ticket (This should be split into Ticket and Ticket purchase)


## User

* User
* User Profile


# Subscribers

Subscribers must be short running pieces of code. Any lengthy operations should be put on a background through through a job.
