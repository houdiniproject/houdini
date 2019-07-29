// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import HoudiniFormik, { HoudiniFormikServerStatus, FormikHelpers } from '../../common/HoudiniFormik';
import AddressPane from './AddressPane';
import { Address, TimeoutError, ValidationErrorsException } from '../../../../api';
import { FormikActions } from 'formik';
import { SupporterEntity } from '../supporter_entity';
import { AddressModalState } from './AddressModal';

export type AddressPaneFormikInputProps = Address & { isDefault?: boolean, shouldDelete?: boolean }

export interface AddressAction {
  type: 'none' | 'delete' | 'add' | 'update'
  address?: Address
  setToDefault?: boolean
}

export const TIMEOUT_ERROR_MESSAGE = "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds."

export const addressPaneFormSubmission = async ({ values, action, supporterEntity, onClose }: { values: AddressPaneFormikInputProps, action: FormikActions<AddressPaneFormikInputProps>, supporterEntity: SupporterEntity, onClose: (action: AddressAction) => void }) => {
  let input: AddressPaneFormikInputProps = values

  let status: HoudiniFormikServerStatus<AddressPaneFormikInputProps> = {}
  try {
    if (values.shouldDelete) {
      try {
        const address = await supporterEntity.deleteAddress(values.id)
        action.setStatus({})
        onClose({ type: 'delete', address: address })

      }
      finally {
        action.setFieldValue('shouldDelete', false)
      }
    }
    else {
      const shouldAdd = !input.id
      if (shouldAdd) {
        const addressPromise = supporterEntity.createAddress(input)
        const address = await addressPromise
        action.setStatus({})
        onClose({ type: 'add', address: address, setToDefault: values.isDefault })


      }
      else {
        const address = await supporterEntity.updateAddress(values.id, input)

        action.setStatus({})
        onClose({ type: 'update', address: address, setToDefault: values.isDefault })
      }
    }

  }
  catch (e) {
    if (e instanceof TimeoutError) {
      status.form = TIMEOUT_ERROR_MESSAGE
    }
    else {
      if (e instanceof ValidationErrorsException) {
        status.fields = FormikHelpers.convertServerValidationToFieldStatus(e)
      }

      status.form = e['error']
    }

    action.setStatus(status)
  }
  finally {
    action.setSubmitting(false)
  }
}

export interface AddressModalFormProps {
  initialAddress: Address
  isDefault?: boolean
  onClose: (action: AddressAction) => void
  supporterEntity: SupporterEntity
  addressModalState: AddressModalState
}

class AddressModalForm extends React.Component<AddressModalFormProps & InjectedIntlProps, {}> {
  render() {

    const initialValues: AddressPaneFormikInputProps = this.props.initialAddress && this.props.initialAddress.id && this.props.initialAddress.id !== 0 ? {
      'id': this.props.initialAddress.id,
      'address': this.props.initialAddress.address || "",
      'city': this.props.initialAddress.city || "",
      'state_code': this.props.initialAddress.state_code || "",
      'zip_code': this.props.initialAddress.zip_code || "",
      'country': this.props.initialAddress.country || "",
      'isDefault': this.props.isDefault
    } : {}

    return <HoudiniFormik initialValues={initialValues as AddressPaneFormikInputProps} onSubmit={async (values, action) => { return addressPaneFormSubmission({ values: values, action: action, supporterEntity: this.props.supporterEntity, onClose: this.props.onClose }) }} render={(props) =>
      <AddressPane formik={props} addressModalState={this.props.addressModalState} />
    } />
  }
}

export default injectIntl(AddressModalForm)
