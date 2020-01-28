#!/bin/bash
stripe listen -l -e account.updated --forward-to localhost:5000/webhooks/stripe/receive -j