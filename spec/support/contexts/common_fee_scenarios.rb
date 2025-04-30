RSpec.shared_context "common fee scenarios" do
  include_context "Stripe::Source doubles"
  include_context :shared_donation_charge_context

  in_past = [{
    amount: 10000,
    source: :visa_card,
    at: :in_past,
    calculate_fee_result: 505,
    calculate_stripe_fee_result: 250,
    refunds: [
      {
        desc: "Full",
        refunded_already: 0,
        application_fee_refunded_already: 0,
        amount_refunded: 10000,
        charge_marked_as_refunded: false,
        calculate_application_fee_refund_result: 505
      },
      {
        desc: "half",
        refunded_already: 5000,
        application_fee_refunded_already: 0,
        amount_refunded: 5000,
        charge_marked_as_refunded: false,
        calculate_application_fee_refund_result: 505 / 2
      },
      {
        desc: "partial_refund_when_part_already_refunded",
        refunded_already: 0,
        application_fee_refunded_already: 195,
        amount_refunded: 3000,
        charge_marked_as_refunded: false,
        calculate_application_fee_refund_result: 151
      },
      {
        desc: "partial_refund_finishing_off_partial_refund",
        refunded_already: 500,
        application_fee_refunded_already: 504,
        amount_refunded: 50,
        charge_marked_as_refunded: true,
        calculate_application_fee_refund_result: 1
      },
      {
        desc: "partial_refund_finishing_off_partial_refund",
        refunded_already: 9999,
        application_fee_refunded_already: 505,
        amount_refunded: 1,
        charge_marked_as_refunded: true,
        calculate_application_fee_refund_result: 0
      }

    ]
  },
    {
      amount: 10000,
      source: :uk_visa_card,
      at: :in_past,
      calculate_fee_result: 505,
      calculate_stripe_fee_result: 250,
      refunds: [
        {
          desc: "Full",
          refunded_already: 0,
          application_fee_refunded_already: 0,
          amount_refunded: 10000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 505
        },
        {
          desc: "half",
          refunded_already: 5000,
          application_fee_refunded_already: 0,
          amount_refunded: 5000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 505 / 2
        },
        {
          desc: "partial_refund_when_part_already_refunded",
          refunded_already: 0,
          application_fee_refunded_already: 195,
          amount_refunded: 3000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 151
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 500,
          application_fee_refunded_already: 504,
          amount_refunded: 50,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 1
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 9999,
          application_fee_refunded_already: 505,
          amount_refunded: 1,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 0
        }

      ]
    },
    {
      amount: 10000,
      source: :amex_card,
      at: :in_past,
      calculate_fee_result: 505,
      calculate_stripe_fee_result: 250,
      refunds: [
        {
          desc: "Full",
          refunded_already: 0,
          application_fee_refunded_already: 0,
          amount_refunded: 10000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 505
        },
        {
          desc: "half",
          refunded_already: 5000,
          application_fee_refunded_already: 0,
          amount_refunded: 5000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 505 / 2
        },
        {
          desc: "partial_refund_when_part_already_refunded",
          refunded_already: 0,
          application_fee_refunded_already: 195,
          amount_refunded: 3000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 151
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 500,
          application_fee_refunded_already: 504,
          amount_refunded: 50,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 1
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 9999,
          application_fee_refunded_already: 505,
          amount_refunded: 1,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 0
        }

      ]
    },

    {
      amount: 10000,
      source: :amex_card,
      at: :in_past,
      calculate_fee_result: 505,
      calculate_stripe_fee_result: 250,
      refunds: [
        {
          desc: "Full",
          refunded_already: 0,
          application_fee_refunded_already: 0,
          amount_refunded: 10000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 505
        },
        {
          desc: "half",
          refunded_already: 5000,
          application_fee_refunded_already: 0,
          amount_refunded: 5000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 505 / 2
        },
        {
          desc: "partial_refund_when_part_already_refunded",
          refunded_already: 0,
          application_fee_refunded_already: 195,
          amount_refunded: 3000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 151
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 500,
          application_fee_refunded_already: 504,
          amount_refunded: 50,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 1
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 9999,
          application_fee_refunded_already: 505,
          amount_refunded: 1,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 0
        }

      ]
    },
    {
      amount: 10000,
      source: :source_from_ru,
      at: :in_past,
      calculate_fee_result: 505,
      calculate_stripe_fee_result: 250,
      refunds: [
        {
          desc: "Full",
          refunded_already: 0,
          application_fee_refunded_already: 0,
          amount_refunded: 10000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 505
        },
        {
          desc: "half",
          refunded_already: 5000,
          application_fee_refunded_already: 0,
          amount_refunded: 5000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 505 / 2
        },
        {
          desc: "partial_refund_when_part_already_refunded",
          refunded_already: 0,
          application_fee_refunded_already: 195,
          amount_refunded: 3000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 151
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 500,
          application_fee_refunded_already: 504,
          amount_refunded: 50,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 1
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 9999,
          application_fee_refunded_already: 505,
          amount_refunded: 1,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 0
        }

      ]
    },
    {
      amount: 10000,
      source: :discover_card,
      at: :in_past,
      calculate_fee_result: 505,
      calculate_stripe_fee_result: 250,
      refunds: [
        {
          desc: "Full",
          refunded_already: 0,
          application_fee_refunded_already: 0,
          amount_refunded: 10000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 505
        },
        {
          desc: "half",
          refunded_already: 5000,
          application_fee_refunded_already: 0,
          amount_refunded: 5000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 505 / 2
        },
        {
          desc: "partial_refund_when_part_already_refunded",
          refunded_already: 0,
          application_fee_refunded_already: 195,
          amount_refunded: 3000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 151
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 500,
          application_fee_refunded_already: 504,
          amount_refunded: 50,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 1
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 9999,
          application_fee_refunded_already: 505,
          amount_refunded: 1,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 0
        }

      ]
    }]

  now =
    # Current era both passed and unpassed
    [:now, nil].map { |time|
      [{
        amount: 10000,
        source: :visa_card,
        at: time,
        calculate_fee_result: 580,
        calculate_stripe_fee_result: 325,
        refunds: [
          {
            desc: "Full",
            refunded_already: 0,
            application_fee_refunded_already: 0,
            amount_refunded: 10000,
            charge_marked_as_refunded: false,
            calculate_application_fee_refund_result: 580 - 325
          },

          {
            desc: "half",
            refunded_already: 5000,
            application_fee_refunded_already: 0,
            amount_refunded: 5000,
            charge_marked_as_refunded: false,
            calculate_application_fee_refund_result: (580 - 325) / 2
          },
          {
            desc: "partial_refund_when_part_already_refunded",
            refunded_already: 0,
            application_fee_refunded_already: 195,
            amount_refunded: 3000,
            charge_marked_as_refunded: false,
            calculate_application_fee_refund_result: 60
          },
          {
            desc: "partial_refund_finishing_off_partial_refund",
            refunded_already: 500,
            application_fee_refunded_already: 254,
            amount_refunded: 50,
            charge_marked_as_refunded: true,
            calculate_application_fee_refund_result: 1
          },
          {
            desc: "partial_refund_finishing_off_partial_refund",
            refunded_already: 9999,
            application_fee_refunded_already: 255,
            amount_refunded: 1,
            charge_marked_as_refunded: true,
            calculate_application_fee_refund_result: 0
          }
        ]
      },
        {
          amount: 10000,
          source: :uk_visa_card,
          at: time,
          calculate_fee_result: 680,
          calculate_stripe_fee_result: 425,
          refunds: [
            {
              desc: "Full",
              refunded_already: 0,
              application_fee_refunded_already: 0,
              amount_refunded: 10000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: 680 - 425
            },
            {
              desc: "half",
              refunded_already: 5000,
              application_fee_refunded_already: 0,
              amount_refunded: 5000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: (680 - 425) / 2
            },
            {
              desc: "partial_refund_when_part_already_refunded",
              refunded_already: 0,
              application_fee_refunded_already: 195,
              amount_refunded: 3000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: 60
            },
            {
              desc: "partial_refund_finishing_off_partial_refund",
              refunded_already: 500,
              application_fee_refunded_already: 254,
              amount_refunded: 50,
              charge_marked_as_refunded: true,
              calculate_application_fee_refund_result: 1
            },
            {
              desc: "partial_refund_finishing_off_partial_refund",
              refunded_already: 9999,
              application_fee_refunded_already: 255,
              amount_refunded: 1,
              charge_marked_as_refunded: true,
              calculate_application_fee_refund_result: 0
            }
          ]
        },
        {
          amount: 10000,
          source: :source_from_ru,
          at: time,
          calculate_fee_result: 605,
          calculate_stripe_fee_result: 350,
          refunds: [
            {
              desc: "Full",
              refunded_already: 0,
              application_fee_refunded_already: 0,
              amount_refunded: 10000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: 605 - 350
            },
            {
              desc: "half",
              refunded_already: 5000,
              application_fee_refunded_already: 0,
              amount_refunded: 5000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: (605 - 350) / 2
            },
            {
              desc: "partial_refund_when_part_already_refunded",
              refunded_already: 0,
              application_fee_refunded_already: 195,
              amount_refunded: 3000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: 60
            },
            {
              desc: "partial_refund_finishing_off_partial_refund",
              refunded_already: 500,
              application_fee_refunded_already: 254,
              amount_refunded: 50,
              charge_marked_as_refunded: true,
              calculate_application_fee_refund_result: 1
            },
            {
              desc: "partial_refund_finishing_off_partial_refund",
              refunded_already: 9999,
              application_fee_refunded_already: 255,
              amount_refunded: 1,
              charge_marked_as_refunded: true,
              calculate_application_fee_refund_result: 0
            }
          ]
        },

        {
          amount: 10000,
          source: :amex_card,
          at: time,
          calculate_fee_result: 705,
          calculate_stripe_fee_result: 450,
          refunds: [
            {
              desc: "Full",
              refunded_already: 0,
              application_fee_refunded_already: 0,
              amount_refunded: 10000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: 705 - 450
            },
            {
              desc: "half",
              refunded_already: 5000,
              application_fee_refunded_already: 0,
              amount_refunded: 5000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: (705 - 450) / 2
            },
            {
              desc: "partial_refund_when_part_already_refunded",
              refunded_already: 0,
              application_fee_refunded_already: 195,
              amount_refunded: 3000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: 60
            },
            {
              desc: "partial_refund_finishing_off_partial_refund",
              refunded_already: 500,
              application_fee_refunded_already: 254,
              amount_refunded: 50,
              charge_marked_as_refunded: true,
              calculate_application_fee_refund_result: 1
            },
            {
              desc: "partial_refund_finishing_off_partial_refund",
              refunded_already: 9999,
              application_fee_refunded_already: 255,
              amount_refunded: 1,
              charge_marked_as_refunded: true,
              calculate_application_fee_refund_result: 0
            }

          ]
        },

        {
          amount: 10000,
          source: :amex_card,
          at: time,
          calculate_fee_result: 705,
          calculate_stripe_fee_result: 450,
          refunds: [
            {
              desc: "Full",
              refunded_already: 0,
              application_fee_refunded_already: 0,
              amount_refunded: 10000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: 705 - 450
            },
            {
              desc: "half",
              refunded_already: 5000,
              application_fee_refunded_already: 0,
              amount_refunded: 5000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: (705 - 450) / 2
            },
            {
              desc: "partial_refund_when_part_already_refunded",
              refunded_already: 0,
              application_fee_refunded_already: 195,
              amount_refunded: 3000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: 60
            },
            {
              desc: "partial_refund_finishing_off_partial_refund",
              refunded_already: 500,
              application_fee_refunded_already: 254,
              amount_refunded: 50,
              charge_marked_as_refunded: true,
              calculate_application_fee_refund_result: 1
            },
            {
              desc: "partial_refund_finishing_off_partial_refund",
              refunded_already: 9999,
              application_fee_refunded_already: 255,
              amount_refunded: 1,
              charge_marked_as_refunded: true,
              calculate_application_fee_refund_result: 0
            }

          ]
        },

        {
          amount: 10000,
          source: :source_from_ru,
          at: time,
          calculate_fee_result: 605,
          calculate_stripe_fee_result: 350,
          refunds: [
            {
              desc: "Full",
              refunded_already: 0,
              application_fee_refunded_already: 0,
              amount_refunded: 10000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: 605 - 350
            },
            {
              desc: "half",
              refunded_already: 5000,
              application_fee_refunded_already: 0,
              amount_refunded: 5000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: (605 - 350) / 2
            },
            {
              desc: "partial_refund_when_part_already_refunded",
              refunded_already: 0,
              application_fee_refunded_already: 195,
              amount_refunded: 3000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: 60
            },
            {
              desc: "partial_refund_finishing_off_partial_refund",
              refunded_already: 500,
              application_fee_refunded_already: 255 - 1,
              amount_refunded: 50,
              charge_marked_as_refunded: true,
              calculate_application_fee_refund_result: 1
            },
            {
              desc: "partial_refund_finishing_off_partial_refund",
              refunded_already: 9999,
              application_fee_refunded_already: 255,
              amount_refunded: 1,
              charge_marked_as_refunded: true,
              calculate_application_fee_refund_result: 0
            }

          ]
        },
        {
          amount: 10000,
          source: :discover_card,
          at: time,
          calculate_fee_result: 505,
          calculate_stripe_fee_result: 250,
          refunds: [
            {
              desc: "Full",
              refunded_already: 0,
              application_fee_refunded_already: 0,
              amount_refunded: 10000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: 505 - 250
            },
            {
              desc: "half",
              refunded_already: 5000,
              application_fee_refunded_already: 0,
              amount_refunded: 5000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: (505 - 250) / 2
            },
            {
              desc: "partial_refund_when_part_already_refunded",
              refunded_already: 0,
              application_fee_refunded_already: 195,
              amount_refunded: 3000,
              charge_marked_as_refunded: false,
              calculate_application_fee_refund_result: 60
            },
            {
              desc: "partial_refund_finishing_off_partial_refund",
              refunded_already: 500,
              application_fee_refunded_already: 254,
              amount_refunded: 50,
              charge_marked_as_refunded: true,
              calculate_application_fee_refund_result: 1
            },
            {
              desc: "partial_refund_finishing_off_partial_refund",
              refunded_already: 9999,
              application_fee_refunded_already: 255,
              amount_refunded: 1,
              charge_marked_as_refunded: true,
              calculate_application_fee_refund_result: 0
            }

          ]
        }]
    }.flatten

  in_future = [{
    amount: 10000,
    source: :visa_card,
    at: :in_future,
    calculate_fee_result: 505,
    calculate_stripe_fee_result: 250,
    refunds: [
      {
        desc: "Full",
        refunded_already: 0,
        application_fee_refunded_already: 0,
        amount_refunded: 10000,
        charge_marked_as_refunded: false,
        calculate_application_fee_refund_result: 505 - 250
      },
      {
        desc: "half",
        refunded_already: 5000,
        application_fee_refunded_already: 0,
        amount_refunded: 5000,
        charge_marked_as_refunded: false,
        calculate_application_fee_refund_result: (505 - 250) / 2
      },
      {
        desc: "partial_refund_when_part_already_refunded",
        refunded_already: 0,
        application_fee_refunded_already: 195,
        amount_refunded: 3000,
        charge_marked_as_refunded: false,
        calculate_application_fee_refund_result: 60
      },
      {
        desc: "partial_refund_finishing_off_partial_refund",
        refunded_already: 500,
        application_fee_refunded_already: 254,
        amount_refunded: 50,
        charge_marked_as_refunded: true,
        calculate_application_fee_refund_result: 1
      },
      {
        desc: "partial_refund_finishing_off_partial_refund",
        refunded_already: 9999,
        application_fee_refunded_already: 255,
        amount_refunded: 1,
        charge_marked_as_refunded: true,
        calculate_application_fee_refund_result: 0
      }

    ]
  },
    {
      amount: 10000,
      source: :uk_visa_card,
      at: :in_future,
      calculate_fee_result: 605,
      calculate_stripe_fee_result: 350,
      refunds: [
        {
          desc: "Full",
          refunded_already: 0,
          fee_refunded_already: 0,
          application_fee_refunded_already: 0,
          amount_refunded: 10000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 605 - 350
        },
        {
          desc: "half",
          refunded_already: 5000,
          application_fee_refunded_already: 0,
          amount_refunded: 5000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: (605 - 350) / 2
        },
        {
          desc: "partial_refund_when_part_already_refunded",
          refunded_already: 0,
          application_fee_refunded_already: 195,
          amount_refunded: 3000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 60
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 500,
          application_fee_refunded_already: 254,
          amount_refunded: 50,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 1
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 9999,
          application_fee_refunded_already: 255,
          amount_refunded: 1,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 0
        }

      ]
    },

    {
      amount: 10000,
      source: :amex_card,
      at: :in_future,
      calculate_fee_result: 705,
      calculate_stripe_fee_result: 450,
      refunds: [
        {
          desc: "Full",
          refunded_already: 0,
          application_fee_refunded_already: 0,
          amount_refunded: 10000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 705 - 450
        },
        {
          desc: "half",
          refunded_already: 5000,
          application_fee_refunded_already: 0,
          amount_refunded: 5000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: (705 - 450) / 2
        },
        {
          desc: "partial_refund_when_part_already_refunded",
          refunded_already: 0,
          application_fee_refunded_already: 195,
          amount_refunded: 3000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 60
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 500,
          application_fee_refunded_already: 254,
          amount_refunded: 50,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 1
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 9999,
          application_fee_refunded_already: 255,
          amount_refunded: 1,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 0
        }

      ]
    },

    {
      amount: 10000,
      source: :source_from_ru,
      at: :in_future,
      calculate_fee_result: 605,
      calculate_stripe_fee_result: 350,
      refunds: [
        {
          desc: "Full",
          refunded_already: 0,
          application_fee_refunded_already: 0,
          amount_refunded: 10000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 605 - 350
        },
        {
          desc: "half",
          refunded_already: 5000,
          application_fee_refunded_already: 0,
          amount_refunded: 5000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: (605 - 350) / 2
        },
        {
          desc: "partial_refund_when_part_already_refunded",
          refunded_already: 0,
          application_fee_refunded_already: 195,
          amount_refunded: 3000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 60
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 500,
          application_fee_refunded_already: 255 - 1,
          amount_refunded: 50,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 1
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 9999,
          application_fee_refunded_already: 255,
          amount_refunded: 1,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 0
        }

      ]
    },
    {
      amount: 10000,
      source: :discover_card,
      at: :in_future,
      calculate_fee_result: 505,
      calculate_stripe_fee_result: 250,
      refunds: [
        {
          desc: "Full",
          refunded_already: 0,
          application_fee_refunded_already: 0,
          amount_refunded: 10000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 505 - 250
        },
        {
          desc: "half",
          refunded_already: 5000,
          application_fee_refunded_already: 0,
          amount_refunded: 5000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: (505 - 250) / 2
        },
        {
          desc: "partial_refund_when_part_already_refunded",
          refunded_already: 0,
          application_fee_refunded_already: 195,
          amount_refunded: 3000,
          charge_marked_as_refunded: false,
          calculate_application_fee_refund_result: 60
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 500,
          application_fee_refunded_already: 254,
          amount_refunded: 50,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 1
        },
        {
          desc: "partial_refund_finishing_off_partial_refund",
          refunded_already: 9999,
          application_fee_refunded_already: 255,
          amount_refunded: 1,
          charge_marked_as_refunded: true,
          calculate_application_fee_refund_result: 0
        }

      ]
    }]

  SCENARIOS ||= [].concat(in_past).concat(now).concat(in_future)

  def get_source(example_details)
    eval(example_details[:source].to_s)
  end

  def at(example_details)
    case example_details[:at]
    when :now
      Time.current
    when :in_past
      Time.new(2000, 1, 1)
    when :in_future
      Time.new(2022, 1, 1)
    end
  end
end
