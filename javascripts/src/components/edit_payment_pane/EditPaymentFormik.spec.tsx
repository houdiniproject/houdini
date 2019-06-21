// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import EditPaymentFormik, { FormData, onSubmit } from './EditPaymentFormik'
import { ApiManager } from '../../lib/api_manager';
import { Money } from '../../lib/money';
import { FormikActions } from 'formik';
import { PaymentData, FundraiserInfo } from './types';
import { ReactWrapper } from 'enzyme';
import { mountWithIntl } from '../../lib/tests/helpers';
import { EditPaymentModalController } from './EditPaymentModalChildren';

function createApiManagerWithMock(mockPutDonationFunction: any): ApiManager {

  return {
    get: (...ignore: any[]) => {
      return {
        putDonation: mockPutDonationFunction
      }
    }
  } as any
}

// describe('onSubmit', () => {
//   const baseData: FormData = {

//     event: 1,
//     gross_amount: Money.fromCents(200, 'usd'),
//     fee_total: Money.fromCents(3, 'usd'),
//     date: '3/3/33',

//   }

//   const withEmptyDedication: FormData = {
//     ...baseData,
//     dedication: {
//       type: null
//     }
//   }

//   const nonprofitId = 99
//   const paymentId = 98

//   let onClose: jest.Mock
//   let preupdateDonationAction: jest.Mock
//   let postUpdateSuccess: jest.Mock
//   let setStatus: jest.Mock
//   let formikActions: FormikActions<FormData>
//   let putDonation: jest.Mock
//   beforeEach(() => {
//     onClose = jest.fn()
//     preupdateDonationAction = jest.fn()
//     postUpdateSuccess = jest.fn()
//     setStatus = jest.fn()
//     formikActions = { setStatus } as any
//   })


//   describe('success', () => {
//     beforeEach(() => {
//       putDonation = jest.fn()
//     })
//     it('successes without dedication', async () => {
//       await onSubmit(baseData, formikActions, putDonation, preupdateDonationAction, postUpdateSuccess, nonprofitId,
//         paymentId, onClose)

//       expect(onClose).toBeCalled()
//       expect(preupdateDonationAction).toBeCalled()
//       expect(postUpdateSuccess).toBeCalled()
//       expect(putDonation).toBeCalledWith()
//     })

//   })
// })

describe('EditPaymentFormik', () => {
  const baseData: FormData = {

    event: 1,
    gross_amount: Money.fromCents(200, 'usd'),
    fee_total: Money.fromCents(3, 'usd'),
    date: '3/3/33',

  }

  const withEmptyDedication: FormData = {
    ...baseData,
    dedication: {
      type: null
    }
  }

  const nonprofitId = 99
  const paymentId = 98

  let onClose: jest.Mock
  let preupdateDonationAction: jest.Mock
  let postUpdateSuccess: jest.Mock
  let setStatus: jest.Mock
  let formikActions: FormikActions<FormData>
  let putDonation: jest.Mock

  let campaigns:FundraiserInfo[] = [{id: 3, name: '3'}]
  let events:FundraiserInfo[] = [{id: 4, name: '4'}]

  let editPaymentModalController:EditPaymentModalController
  beforeEach(() => {
    onClose = jest.fn()
    preupdateDonationAction = jest.fn()
    postUpdateSuccess = jest.fn()
    setStatus = jest.fn()
    formikActions = { setStatus } as any
    editPaymentModalController = {
      setCanClose: jest.fn(),
      closeAction: jest.fn(),
      setFormId: jest.fn(),
      setDisableSave: jest.fn(),
      setDisableClose: jest.fn()
    }

  })

  const paymentData: PaymentData = {
    gross_amount: 33,
    net_amount: 33,
    fee_total: -1,
    refund_total: undefined,
    date: new Date(2014, 2, 3).toUTCString(),
    offsite_payment: {},
    donation: {
      designation: 'etwoth',
      comment: 'eee',

      id: 333
    },
    kind: 'Donation',
    id: "98",
    nonprofit: { id: 99 },

  }

  const hasEmptyDedication: PaymentData = {
    ...paymentData,
    donation: {
      ...paymentData.donation,
      dedication: JSON.stringify({ type: null })
    }
  }

  const hasCampaign: PaymentData = {
    ...paymentData,
    donation: {
      ...paymentData.donation,
      campaign: { id: 33 }
    }
  }

  const hasEvent: PaymentData = {
    ...paymentData,
    donation: {
      ...paymentData.donation,
      event: { id: 33 }
    }
  }

  const hasHonorDedication: PaymentData = {
    ...paymentData,
    donation: {
      ...paymentData.donation,
      dedication: JSON.stringify({ type: 'honor', dedication: {full_address: 'iiii'}})
    }
  }

  

  let rootWrapper:ReactWrapper

  describe('loading', () => {

    function commonTests(){
      it('set form called', () => {
        expect(editPaymentModalController.setFormId).toBeCalledWith(expect.anything())
      })

      it('set disable close not called', () => {
        expect(editPaymentModalController.setDisableClose).not.toBeCalled()
      })

      it('set disable save called', () => {
        expect(editPaymentModalController.setDisableSave).not.toBeCalled()
      })

      it('set canClose called', () => {
        expect(editPaymentModalController.setCanClose).toBeCalled()
      })

      it('onClose not called', () => {
        expect(onClose).not.toBeCalled()
      })
      
      
    }

    describe('basic', () => {
      beforeEach(() => {
        rootWrapper = mountWithIntl(<EditPaymentFormik  data={paymentData} events={events} campaigns={campaigns} ApiManager={createApiManagerWithMock(()=> {})} preupdateDonationAction={preupdateDonationAction} postUpdateSuccess={postUpdateSuccess} onClose={onClose} editPaymentModalController={editPaymentModalController}/>)
      })

      it('rootWrapper is mounted', () => {
        expect(rootWrapper.text()).toBeTruthy()
      })
      commonTests()
    })
  })
})