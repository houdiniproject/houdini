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

  let campaigns: FundraiserInfo[] = [{ id: 33, name: 'campaigns ' }]
  let events: FundraiserInfo[] = [{ id: 33, name: 'event' }]

  let editPaymentModalController: EditPaymentModalController
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
    nonprofit: { id: 99 }
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
      dedication: JSON.stringify({ type: 'honor', dedication: { full_address: 'iiii' } })
    }
  }

  const hasAddress: PaymentData = {
    ...paymentData,
    donation: {
      ...paymentData.donation,
      address: {
        id: 3433,
        address: "address",
        city: 'city',
        state_code: 'state',
        country: 'country',
        zip_code: 'zip'
      }
    }
  }





  let rootWrapper: ReactWrapper

  describe('loading', () => {
    function getCampaignsSelect() {
      return rootWrapper.find('select').filterWhere((w) => w.getDOMNode().getAttribute('id') && w.getDOMNode().getAttribute('id').indexOf('campaign') > 0)
    }

    function getEventsSelect() {
      return rootWrapper.find('select').filterWhere((w) => w.getDOMNode().getAttribute('id') && w.getDOMNode().getAttribute('id').indexOf('event') > 0)
    }

    function getDedicationSelect() {
      return rootWrapper.find('select').filterWhere((w) => w.getDOMNode().getAttribute('id') && w.getDOMNode().getAttribute('id').indexOf('dedication.type') > 0)
    }

    function getDedicationName() {
      return rootWrapper.find('input').filterWhere((w) => w.getDOMNode().getAttribute('id') && w.getDOMNode().getAttribute('id').indexOf('dedication.name') > 0)
    }

    function getDedicationAddress() {
      return rootWrapper.find('input').filterWhere((w) => w.getDOMNode().getAttribute('id') && w.getDOMNode().getAttribute('id').indexOf('dedication.full_address') > 0)
    }

    function getInputById(id: string) {
      return rootWrapper.find('input').filterWhere((w) => w.getDOMNode().getAttribute('id') && w.getDOMNode().getAttribute('id').indexOf(id) > 0)
    }


    function getAddressWrappers() {
      return {
        address: getInputById('address.address'),
        city: getInputById('address.city'),
        state_code: getInputById('address.state_code'),
        zip_code: getInputById('address.zip_code'),
        country: getInputById('address.country')
      }
    }

    describe('basic', () => {
      beforeEach(() => {
        rootWrapper = mountWithIntl(<EditPaymentFormik data={paymentData} events={events} campaigns={campaigns} ApiManager={createApiManagerWithMock(() => { })} preupdateDonationAction={preupdateDonationAction} postUpdateSuccess={postUpdateSuccess} onClose={onClose} editPaymentModalController={editPaymentModalController} />)
      })

      it('rootWrapper is mounted', () => {
        expect(rootWrapper.text()).toBeTruthy()
      })

      it('set form called', () => {
        expect(editPaymentModalController.setFormId).toBeCalledWith(expect.anything())
      })

      it('set disable close not called', () => {
        expect(editPaymentModalController.setDisableClose).toBeCalledWith(false)
      })

      it('set disable save called', () => {
        expect(editPaymentModalController.setDisableSave).toBeCalledWith(true)
      })

      it('set canClose called', () => {
        expect(editPaymentModalController.setCanClose).toBeCalled()
      })

      it('onClose not called', () => {
        expect(onClose).not.toBeCalled()
      })

      describe('form parts', () => {
        describe('campaign select', () => {
          it('exists', () => {
            expect(getCampaignsSelect().exists()).toBeTruthy()
          })

          it('has no value', () => {
            expect(getCampaignsSelect().prop('value')).toBeFalsy()
          })
        })

        describe('event select', () => {
          it('exists', () => {
            expect(getEventsSelect().exists()).toBeTruthy()
          })

          it('has no value', () => {
            expect(getEventsSelect().prop('value')).toBeFalsy()
          })
        })

        describe('dedication type', () => {
          it('exists', () => {
            expect(getDedicationSelect().exists()).toBeTruthy()
          })

          it('has no value', () => {
            expect(getDedicationSelect().prop('value')).toBeFalsy()
          })
        })


        describe('dedication name', () => {
          it("doesnt exist", () => {
            expect(getDedicationName().exists()).toBeFalsy()
          })
        })
      })

    })

    describe('empty dedication', () => {
      beforeEach(() => {
        rootWrapper = mountWithIntl(<EditPaymentFormik data={hasEmptyDedication} events={events} campaigns={campaigns} ApiManager={createApiManagerWithMock(() => { })} preupdateDonationAction={preupdateDonationAction} postUpdateSuccess={postUpdateSuccess} onClose={onClose} editPaymentModalController={editPaymentModalController} />)
      })

      it('rootWrapper is mounted', () => {
        expect(rootWrapper.text()).toBeTruthy()
      })

      it('set form called', () => {
        expect(editPaymentModalController.setFormId).toBeCalledWith(expect.anything())
      })

      it('set disable close not called', () => {
        expect(editPaymentModalController.setDisableClose).toBeCalledWith(false)
      })

      it('set disable save called', () => {
        expect(editPaymentModalController.setDisableSave).toBeCalledWith(true)
      })

      it('set canClose called', () => {
        expect(editPaymentModalController.setCanClose).toBeCalled()
      })

      it('onClose not called', () => {
        expect(onClose).not.toBeCalled()
      })

      describe('form parts', () => {
        describe('campaign select', () => {
          it('exists', () => {
            expect(getCampaignsSelect().exists()).toBeTruthy()
          })

          it('has no value', () => {
            expect(getCampaignsSelect().prop('value')).toBeFalsy()
          })
        })

        describe('event select', () => {
          it('exists', () => {
            expect(getEventsSelect().exists()).toBeTruthy()
          })

          it('has no value', () => {
            expect(getEventsSelect().prop('value')).toBeFalsy()
          })
        })

        describe('dedication type', () => {
          it('exists', () => {
            expect(getDedicationSelect().exists()).toBeTruthy()
          })

          it('has no value', () => {
            expect(getDedicationSelect().prop('value')).toBeFalsy()
          })
        })


        describe('dedication name', () => {
          it("doesnt exist", () => {
            expect(getDedicationName().exists()).toBeFalsy()
          })
        })
      })

    })

    describe('has campaign', () => {
      beforeEach(() => {
        rootWrapper = mountWithIntl(<EditPaymentFormik data={hasCampaign} events={events} campaigns={campaigns} ApiManager={createApiManagerWithMock(() => { })} preupdateDonationAction={preupdateDonationAction} postUpdateSuccess={postUpdateSuccess} onClose={onClose} editPaymentModalController={editPaymentModalController} />)
      })

      it('rootWrapper is mounted', () => {
        expect(rootWrapper.text()).toBeTruthy()
      })

      it('set form called', () => {
        expect(editPaymentModalController.setFormId).toBeCalledWith(expect.anything())
      })

      it('set disable close not called', () => {
        expect(editPaymentModalController.setDisableClose).toBeCalledWith(false)
      })

      it('set disable save called', () => {
        expect(editPaymentModalController.setDisableSave).toBeCalledWith(true)
      })

      it('set canClose called', () => {
        expect(editPaymentModalController.setCanClose).toBeCalled()
      })

      it('onClose not called', () => {
        expect(onClose).not.toBeCalled()
      })

      describe('form parts', () => {
        describe('campaign select', () => {
          it('exists', () => {
            expect(getCampaignsSelect().exists()).toBeTruthy()
          })

          it('has value', () => {
            expect(getCampaignsSelect().prop('value')).toBe(33)
          })
        })

        describe('event select', () => {
          it('exists', () => {
            expect(getEventsSelect().exists()).toBeTruthy()
          })

          it('has no value', () => {
            expect(getEventsSelect().prop('value')).toBeFalsy()
          })
        })

        describe('dedication type', () => {
          it('exists', () => {
            expect(getDedicationSelect().exists()).toBeTruthy()
          })

          it('has no value', () => {
            expect(getDedicationSelect().prop('value')).toBeFalsy()
          })
        })


        describe('dedication name', () => {
          it("doesnt exist", () => {
            expect(getDedicationName().exists()).toBeFalsy()
          })
        })
      })

    })

    describe('has event', () => {
      beforeEach(() => {
        rootWrapper = mountWithIntl(<EditPaymentFormik data={hasEvent} events={events} campaigns={campaigns} ApiManager={createApiManagerWithMock(() => { })} preupdateDonationAction={preupdateDonationAction} postUpdateSuccess={postUpdateSuccess} onClose={onClose} editPaymentModalController={editPaymentModalController} />)
      })

      it('rootWrapper is mounted', () => {
        expect(rootWrapper.text()).toBeTruthy()
      })

      it('set form called', () => {
        expect(editPaymentModalController.setFormId).toBeCalledWith(expect.anything())
      })

      it('set disable close not called', () => {
        expect(editPaymentModalController.setDisableClose).toBeCalledWith(false)
      })

      it('set disable save called', () => {
        expect(editPaymentModalController.setDisableSave).toBeCalledWith(true)
      })

      it('set canClose called', () => {
        expect(editPaymentModalController.setCanClose).toBeCalled()
      })

      it('onClose not called', () => {
        expect(onClose).not.toBeCalled()
      })

      describe('form parts', () => {
        describe('campaign select', () => {
          it('exists', () => {
            expect(getCampaignsSelect().exists()).toBeTruthy()
          })

          it('has value', () => {
            expect(getCampaignsSelect().prop('value')).toBeFalsy()
          })
        })

        describe('event select', () => {
          it('exists', () => {
            expect(getEventsSelect().exists()).toBeTruthy()
          })

          it('has value', () => {
            expect(getEventsSelect().prop('value')).toBe(33)
          })
        })

        describe('dedication type', () => {
          it('exists', () => {
            expect(getDedicationSelect().exists()).toBeTruthy()
          })

          it('has no value', () => {
            expect(getDedicationSelect().prop('value')).toBeFalsy()
          })
        })


        describe('dedication name', () => {
          it("doesnt exist", () => {
            expect(getDedicationName().exists()).toBeFalsy()
          })
        })
      })

    })

    describe('has honor dedication', () => {
      beforeEach(() => {
        rootWrapper = mountWithIntl(<EditPaymentFormik data={hasHonorDedication} events={events} campaigns={campaigns} ApiManager={createApiManagerWithMock(() => { })} preupdateDonationAction={preupdateDonationAction} postUpdateSuccess={postUpdateSuccess} onClose={onClose} editPaymentModalController={editPaymentModalController} />)
      })

      it('rootWrapper is mounted', () => {
        expect(rootWrapper.text()).toBeTruthy()
      })

      it('set form called', () => {
        expect(editPaymentModalController.setFormId).toBeCalledWith(expect.anything())
      })

      it('set disable close not called', () => {
        expect(editPaymentModalController.setDisableClose).toBeCalledWith(false)
      })

      it('set disable save called', () => {
        expect(editPaymentModalController.setDisableSave).toBeCalledWith(true)
      })

      it('set canClose called', () => {
        expect(editPaymentModalController.setCanClose).toBeCalled()
      })

      it('onClose not called', () => {
        expect(onClose).not.toBeCalled()
      })

      describe('form parts', () => {
        describe('campaign select', () => {
          it('exists', () => {
            expect(getCampaignsSelect().exists()).toBeTruthy()
          })

          it('has value', () => {
            expect(getCampaignsSelect().prop('value')).toBeFalsy()
          })
        })

        describe('event select', () => {
          it('exists', () => {
            expect(getEventsSelect().exists()).toBeTruthy()
          })

          it('has no value', () => {
            expect(getEventsSelect().prop('value')).toBeFalsy()
          })

          describe('dedication type', () => {
            it('exists', () => {
              expect(getDedicationSelect().exists()).toBeTruthy()
            })

            it('has value', () => {
              expect(getDedicationSelect().prop('value')).toBe('honor')
            })
          })

          describe('dedication name', () => {
            it("exists", () => {
              expect(getDedicationName().exists()).toBeTruthy()
            })
          })

          describe('dedication address', () => {
            it('exists', () => {
              expect(getDedicationAddress().exists()).toBeTruthy()
            })

            it('has correct value', () => {
              expect(getDedicationAddress().prop('value')).toBe('iiii')
            })
          })
        })
      })
    })

    describe('has address', () => {
      beforeEach(() => {
        rootWrapper = mountWithIntl(<EditPaymentFormik data={hasAddress} events={events} campaigns={campaigns} ApiManager={createApiManagerWithMock(() => { })} preupdateDonationAction={preupdateDonationAction} postUpdateSuccess={postUpdateSuccess} onClose={onClose} editPaymentModalController={editPaymentModalController} />)
      })

      it('rootWrapper is mounted', () => {
        expect(rootWrapper.text()).toBeTruthy()
      })

      it('set form called', () => {
        expect(editPaymentModalController.setFormId).toBeCalledWith(expect.anything())
      })

      it('set disable close not called', () => {
        expect(editPaymentModalController.setDisableClose).toBeCalledWith(false)
      })

      it('set disable save called', () => {
        expect(editPaymentModalController.setDisableSave).toBeCalledWith(true)
      })

      it('set canClose called', () => {
        expect(editPaymentModalController.setCanClose).toBeCalled()
      })

      it('onClose not called', () => {
        expect(onClose).not.toBeCalled()
      })

      describe('form parts', () => {
        describe('campaign select', () => {
          it('exists', () => {
            expect(getCampaignsSelect().exists()).toBeTruthy()
          })

          it('has value', () => {
            expect(getCampaignsSelect().prop('value')).toBeFalsy()
          })
        })

        describe('event select', () => {
          it('exists', () => {
            expect(getEventsSelect().exists()).toBeTruthy()
          })

          it('has no value', () => {
            expect(getEventsSelect().prop('value')).toBeFalsy()
          })
        })

        describe('dedication', () => {
          describe('dedication type', () => {
            it('exists', () => {
              expect(getDedicationSelect().exists()).toBeTruthy()
            })

            it('has no value', () => {
              expect(getDedicationSelect().prop('value')).toBeFalsy()
            })
          })

          describe('dedication name', () => {
            it("doesnt exists", () => {
              expect(getDedicationName().exists()).toBeFalsy()
            })
          })

          describe('dedication address', () => {
            it('doesnt exists', () => {
              expect(getDedicationAddress().exists()).toBeFalsy()
            })
          })
        })


        describe('address ', () => {
          it('has address', () => {
            const address = getAddressWrappers().address
            expect(address.exists()).toBeTruthy()
            expect(address.prop('value')).toBe('address')
          })
          it('has city', () => {
            const city = getAddressWrappers().city
            expect(city.exists()).toBeTruthy()
            expect(city.prop('value')).toBe('city')
          })

          it('has state_code', () => {
            const state_code = getAddressWrappers().state_code
            expect(state_code.exists()).toBeTruthy()
            expect(state_code.prop('value')).toBe('state')
          })

          it('has zip_code', () => {
            const zip_code = getAddressWrappers().zip_code
            expect(zip_code.exists()).toBeTruthy()
            expect(zip_code.prop('value')).toBe('zip')
          })

          it('has country', () => {
            const country = getAddressWrappers().country
            expect(country.exists()).toBeTruthy()
            expect(country.prop('value')).toBe('country')
          })
        })
      })
    })
  })
})