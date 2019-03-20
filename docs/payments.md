
# Payments
A payment represents a description of a transaction that the user of Houdini cares about. It can be of positive or negative value. 

Notably, a payment object may be associated with a charge, refund, dispute or fee handled through a payment processor. If a payment does not have an associated transaction through a payment processor, no money has changed hands and the "offsite payment" is simply included for the preferences of the user. As an example, if a nonprofit receives a paper check, they may wish to record it Houdini but have no interest in having it processed through Houdini. 

Payment processing in Houdini V2 is modular. No assumptions should be made in the base of Houdini about what payment processing mechanisms are used.

## Sources
Payment sources correspond to some sort of account number or identifier belonging to a supporter which can be used by a payment processor to transfer money from a supporter to a nonprofit. As an example, it might represent the ACH information necessary for transferring from a supporter's checking account. A source record in the database has the following properties:

* an generated ID
* a pointer to a supporter
* a pointer to a payment processor payment source (polymorphic)
* a readable name (optional)

### Source creation
Sources are created using using a POST request to `api/v1/supporters/:id/sources`. The post request will include a body as follows:
```json
{
    payment_processor_source_type: <symbol corresponding to a payment processor source type (registered by plugin)>,
    payment_processor_source_object: <object corresponding to the information needed by payment processor source>
}
```
In the case of an ACH payment processor, the payment_processor_source_object might include the account and routing number. In the case of a 

# Payment process



Payments start with a POST request to `api/v1/nonprofits/:id/payment`. The post request will include a body as follows:

```json
{
    supporter_id: <supporter.id>,
    address_id: <address.id>,
    amount: <amount in cents (or lowest denomination of currency)>,
    currency: <currency symbol. Must match nonprofit's currency symbol>,
    payment_processor?: <symbol corresponding to the payment processor (registered by plugin)>,
    payment_processing_object?: <object corresponding to the information needed by the payment method. This will include the source ID or a source token>,
    payment_type_object: <object corresponding to a donation, recurring donation, ticket sale, campaign gift, etc. each registered as plugin>
}
```

The pseudo-code for payment is as follows:

```ruby
def payment(input)
    
    verify_supporter_belongs_to_nonprofit(input)
    verify_currency_is_valid_for_nonprofit(input)

    # Here we reserve the number of items requested. As an example, if there tickets being requested, we make sure enough are available. If there are, we reserve them. Otherwise we throw and tell the supporter that we don't have any
    item_request = payment_type_plugin.reserve_limited_items(input)
    
    fire_event(:begin_payment)
    
    begin
        start_transaction do   
            #payment processor performs the charges. This could succeed or fail for a lot of reasons.
            
            payment_result = payment_processor.process(input)
            # here's where recurring donations and other objects get set up.
            payment_type_plugin.process(input)
        
            save_payment(payment_result, input)
            payment_type_plugin.finalized_limited_items(item_request)
        end
        fire_event(:payment_completed)
    rescue => e
        fire_event(:payment_failed, e)
    end
end
```

# Payment processors
Payment processors register themselves during the initialization phase of Houdini. Payment processors have a front end and backend.

## Front end
The front end for a payment processor consists of a set of React components. At a minimum, every payment processor must register a payment form. Other components which could exist based upon need include:

* Account balance/Payout page

### Payment form
A payment form is where payment informations is collected from the supporter and then prepared for submission to the payment API. As an example, for a credit card donation using Stripe, this would include:

* the credit card, expiration date, CVV fields for a donation
* the javascript necessary for tokenizing the information with stripe
* a javascript call to the Source API to create a new source for the supporter and get a source token
* a javascript call to pass the source token to the payment API

Additionally, the Stripe Payment form may have to handle exposing errors to the supporter which are unique to the Stripe payment form. For example, if the expiration year is rejected, the Stripe payment form may need to handle that error and indicate on the expiration year input fields that there was an error.

### Account balance/Payout page
Some payment processors allow the nonprofit to manage their connection with the payment processor service in the payments dashboard. As an example, the Stripe payment processor, when in Stripe Connect mode, allows nonprofits to register their bank account and perform payouts.

## Back end

The back end contains all the information and code necessary for handling charges, refunds, processing disputes, assessing fees, etc. This is where services are called to have real money change hands. Each backend

### web hooks


