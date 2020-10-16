# Definitions

## Instance

A copy of Houdini running. An organization with a server running Houdini is
running their own instance.

## Hoster

The entity responsible for running an instance of Houdini. In cases of a
Houdini hosted service, like CommitChange, this is an organization independent
of the nonprofits using this instance of Houdini. In other cases, this may be
an organization with some sort of oversight of all of the nonprofits on
their instance of Houdini, such as a fiscal sponsor. In some cases,
a single nonprofit may also be their own Hoster.
The Hoster has control over which users receives the access to the superuser role
which gives the user access to the information of ALL of the nonprofits on
their instance.

## Nonprofit

Short hand for an organization registered on an instance of Houdini. The
nonprofit doesn't have to formally be a nonprofit or NGO but they often are.

## Payment

A payment represents a description of a non-expense transaction that the a
Nonprofit on Houdini cares about. It can be of positive or negative value.
Money could have changed hands through Houdini, like via Stripe or Paypal, or
offline, via paper check. It's, more or less, like a checkbook entry but the
unlike a checking account, it isn't specific to a particular financial account.
Notably, expenses are NEVER handled through Houdini. Houdini only cares
about contributions to an organization (such as a donation, ticket purchase,  
etc) and any disputes, refunds, or fees related to those contributions.

## Merchant Provider Plugin (MPP)

A Merchant Provider Plugin (or TPP) is used for making online transactions through a merchant provider. A MPP, which is provided to Houdini as a Rails engine, handles the transaction flow for a given merchant provider, both on the backend and the front end. Additionally, it keeps any necessary state used by the transaction flow. This could include ids used for different transaction sources that are meaningful to a transaction provider, records of transactions in different states, the current balance for a given nonprofit, etc. A MPP may also need to handle events created by their merchant provider, such as notification of a dispute, a change in status of a transaction, etc.

## Merchant provider

The service, system or source used for making transactions.
In the case of a service like Stripe, there might be specific accounts
related to the service for both the Hoster and the Nonprofit (depending on
setup, they could differ or not). In the case of cryptocurrency,
the transaction provider faciliate transfers between
wallets and the Hoster and Nonprofit may have wallet addresses the same or
different wallet address.

## Transaction source

The database and data entity which contains an transaction source id. Each one has a source type, since they're only meaningful for a given transaction source type on a particular merchant provider.

## Transaction source ID

A identification of an account belonging to a supporter which can make transactions. This could be an address for a cryptocurrency wallet, a Stripe card identifier or, in the case where the Houdini instance works with a raw merchant account, the credit card number and expiration date. This is something the supporter has given to the nonprofit for making transactions. Stored by the MPP in an entry source.

## Supporter

An individual who is in the nonprofit's CRM in Houdini. A supporter, if they have any payments with the nonprofit, may have a 

## Transaction

The logical process of making money change hands from a supporter to a nonprofit as well as in the reverse direction for disputes, refunds, etc. happens. If a transaction completes, money changes hands.

# Payments

A payment object may be associated with a charge, refund, dispute or fee, etc. handled through a merchant processor plugin (MPP) as well as a supporter. If a payment does not have an associated transaction through an MPP, no money has changed hands and the "offsite payment" is simply included for the convenience of the nonprofit. As an example, if a nonprofit receives a paper check from a supporter, they may wish to recorded in Houdini.

Payment processing in Houdini V2 is modular. No assumptions should be made in the base of Houdini about what payment processing mechanisms are used.

## Transaction sources

A transaction source is partially maintained through the MPP and partially through core. At a minimum the source will have:

In the core database tables:

* an generated ID, used for making new transactions
* a reference to the transaction source's supporter
* a reference to the transaction source's entity in MPP's database tables (polymorphic)
* a human-readable description

### Source creation

Sources are created using using a POST request to `api/v1/supporters/:id/sources` . The post request will include a body as follows:

``` json
{
    description: <a short description of the transaction source>,
    transaction_source_type: <symbol corresponding to a transaction source type (registered by MPP)>,
    transaction_source_object: <object corresponding to the transaction source>

}
```

#### Example

Let's say an MPP, IbanMpp, handles IBAN transactions directly (not through a system like Stripe). On registration, IbanMpp registers a transaction source type of 'iban' corresponding to an Iban account. The supporter has an id of '1'. An example POST call made to api/v1/supporters/1/sources is:

``` json
{
    description: 'DE*3000'
    transaction_source_type: 'iban',
    transaction_source_object: {
        iban_number: 'DE89370400440532013000'
    }
}
```

# Transaction plugin

# Payment process

Payments start with a POST request to `api/v1/nonprofits/:id/payment` . The post request will include a body as follows:

``` json
{
    supporter_id: <supporter.id>,
    source_id: <transaction_source.id>
    address_id: <address.id>,
    amount: <amount in lowest denomination of currency)>,
    currency: <currency symbol. Must match nonprofit's currency symbol>,
    payment_processing_object?: <object corresponding to the information needed by MPP to make a transaction with the given transaction>,
    payment_type_object: <object corresponding to a donation, recurring donation, ticket sale, campaign gift, etc. each registered as plugin>
}
```

The pseudo-code for payment is as follows:

``` ruby
def payment(input)
    
    verify_supporter_belongs_to_nonprofit(input)
    verify_currency_is_valid_for_nonprofit(input)
    verify_supporter_owns_transaction_source(input)
    transaction_source_plugin = get_plugin_for_transaction_source(input)

    # Here we reserve the number of items requested. As an example, if there tickets being requested, we make sure enough are available. If there are, we reserve them. Otherwise we throw and tell the supporter that we don't have any
    item_request = reserve_limited_items(input)
    
    fire_event(:begin_payment)
    
    begin
        start_transaction do   
            #payment processor performs the charges. This could succeed or fail for a lot of reasons.
            
            payment_result = transaction_source_plugin.process(input)
            # here's where recurring donations and other objects get set up.
            setup_recurring_donations(input)
            save_payment(payment_result, input)

            # If we have reserved items, we need to convert them to a purchased items.
            finalized_limited_items(item_request)
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
