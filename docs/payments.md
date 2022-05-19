# Payments

After configuring `STRIPE_API_KEY` and `STRIPE_API_PUBLIC` as per [Getting
Started](getting_started.md), you should be able to successfully process credit
card payments.

## Confirming payments

After a payment has been processed, Stripe consider the transaction to be
"pending". Under normal circumstances, Stripe will update the status to
"confirmed" after a few days. Houdini will also reflect this transaction status,
as seen under the details of a payment within the "Payments" section.

Payment statuses in Houdini are updated by the batch job
`update_np_balances`. This can be called from the command-line with `bin/rails
heroku_scheduled_job[update_np_balances]`, though is best configured to run once
daily through a scheduling system such as cron.

*Note*: Currently the `update_np_balances` job will fail silently unless you
additionally configuring the `stripe_account_id` field for your `nonprofit`
database record. For example:

$ bin/rails console
# Nonprofit.find_by(name: 'My Org').update(stripe_account_id: 'acct_xxxxxxxxxxxxxxxx')
