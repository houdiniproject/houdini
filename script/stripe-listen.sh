#!/bin/bash
stripe listen -l -e account.updated --forward-to localhost:5000/stripe_webhook/receive -j