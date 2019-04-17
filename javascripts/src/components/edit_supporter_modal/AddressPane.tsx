// License: LGPL-3.0-or-later
import { FormikActions } from 'formik';
import { action } from 'mobx';
import { inject, observer } from 'mobx-react';
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { Address, TimeoutError, ValidationErrorsException } from '../../../api';
import Button from '../common/form/Button';
import { FieldCreator } from '../common/form/FieldCreator';
import { FormikCheckbox } from '../common/form/FormikCheckbox';
import FormNotificationBlock from '../common/form/FormNotificationBlock';
import FormikBasicField from '../common/FormikBasicField';
import HoudiniFormik, { FormikHelpers, HoudiniFormikProps, HoudiniFormikServerStatus } from '../common/HoudiniFormik';
import { TwoColumnFields } from '../common/layout';
import { LocalRootStore } from './local_root_store';
import { SupporterEntity } from './supporter_entity';

export interface AddressAction {
  type: 'none' | 'delete' | 'add' | 'update'
  address?: Address
  setToDefault?: boolean
}

export interface AddressPaneProps {
  initialAddress: Address
  isDefault?: boolean
  onClose: (action: AddressAction) => void
  LocalRootStore?: LocalRootStore
}

type AddressPaneFormikInputProps = Address & { isDefault?: boolean, shouldDelete?:boolean }

export const TIMEOUT_ERROR_MESSAGE = "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds."

export const addressPaneFormSubmission = async ({values, action, supporterAddressStore, onClose}:{values: AddressPaneFormikInputProps, action: FormikActions<AddressPaneFormikInputProps>, supporterAddressStore:SupporterEntity, onClose: (action: AddressAction) => void}) =>  {
  let input:AddressPaneFormikInputProps = values

  let status: HoudiniFormikServerStatus<AddressPaneFormikInputProps> = {}
  try {
    if (values.shouldDelete){
      try{
        const address = await supporterAddressStore.deleteAddress(values.id)
        action.setStatus({} )
        onClose({ type: 'delete', address: address })
      
      }
      finally{
        action.setFieldValue('shouldDelete', false)
      }
    }
    else {
      const shouldAdd = !input.id
      if (shouldAdd) {
        const address = await supporterAddressStore.createAddress(input)
        action.setStatus({})
        onClose({ type: 'add', address: address, setToDefault: values.isDefault })
      }
      else {
        const address = await supporterAddressStore.updateAddress(values.id, input)

        action.setStatus({})
        onClose({ type: 'update', address: address, setToDefault: values.isDefault })
      }
    }

  }
  catch (e) {
    if (e instanceof TimeoutError) {
      status.form = "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds."
    }
    else {
      if (e instanceof ValidationErrorsException) {
        status.fields = FormikHelpers.convertServerValidationToFieldStatus(e)
      }

      status.form = e['error']
    }

    action.setStatus(status)
  }
}


class AddressPane extends React.Component<AddressPaneProps & InjectedIntlProps, {}> {
  
  @action.bound
  close(){
    this.props.onClose({ type: 'none' })
  }
  
  render() {
    const shouldAdd = (!this.props.initialAddress || !this.props.initialAddress.id)
    const initialValues:AddressPaneFormikInputProps = shouldAdd ? {} : {
      'id': this.props.initialAddress.id,
      'address': this.props.initialAddress.address || "",
      'city': this.props.initialAddress.city || "",
      'state_code': this.props.initialAddress.state_code || "",
      'zip_code': this.props.initialAddress.zip_code || "",
      'country': this.props.initialAddress.country || "",
      'isDefault': this.props.isDefault
    }

    return <HoudiniFormik initialValues={initialValues as AddressPaneFormikInputProps} onSubmit={(values, action) => {addressPaneFormSubmission({values:values, action:action, supporterAddressStore:this.props.LocalRootStore.supporterAddressStore, onClose: this.props.onClose})}}
    render={(props: HoudiniFormikProps<AddressPaneFormikInputProps>) => {
      const modifiedEnoughToSubmit = props.dirty && !(
        FormikHelpers.isEmpty(props.values.address)
           && FormikHelpers.isEmpty(props.values.city)
           && FormikHelpers.isEmpty(props.values.state_code)
           && FormikHelpers.isEmpty(props.values.zip_code)
           && FormikHelpers.isEmpty(props.values.country)
      )

      const shouldAdd = !props.values.id
      return (
        <form onSubmit={props.handleSubmit} onReset={props.handleReset}>
          <div>
            <TwoColumnFields>
              <FieldCreator component={FormikBasicField} name={'address'} label={'Address'} inputId={FormikHelpers.createId(props, 'address')}/>
              <FieldCreator component={FormikBasicField} name={'city'} label={'City'}  inputId={FormikHelpers.createId(props, 'city')}/>

            </TwoColumnFields>
            <TwoColumnFields>
              <FieldCreator component={FormikBasicField} name={'state_code'} label={'State/Region Code'} inputId={FormikHelpers.createId(props, 'state_code')}/>
              <FieldCreator component={FormikBasicField} name={'zip_code'} label={'Postal/Zip Code'} inputId={FormikHelpers.createId(props, 'zip_code')}/>

            </TwoColumnFields>
            <TwoColumnFields>
              <FieldCreator component={FormikBasicField} name={'country'} label={'Country'} inputId={FormikHelpers.createId(props, 'country')} />
            </TwoColumnFields>
            <FieldCreator component={FormikCheckbox} name={'isDefault'} label={"Set as Default Address"} id={FormikHelpers.createId(props, 'isDefault')}/>

            {
              (props.status && props.status.form) ? <FormNotificationBlock>{props.status.form}</FormNotificationBlock> : ""
            }

            
          </div>
          <div>

            <Button type="button" onClick={this.close}>Close</Button>
            {shouldAdd ?
              <>
                <Button type="submit" disabled={!modifiedEnoughToSubmit}>Add</Button>
              </> :
              <>
                <Button type="submit" disabled={!modifiedEnoughToSubmit}>Save</Button>
                <Button type="submit" onClick={() => {props.setFieldValue('shouldDelete', true); props.submitForm()}}>Delete</Button>
              </>
            }
          </div>
        </form>)
    }
    } />
  }
}

export default injectIntl(inject('LocalRootStore')(observer(AddressPane)))



