// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import * as _ from 'lodash';
import { Address, TimeoutError, ValidationErrorsException, ValidationError } from '../../../api';
import FormNotificationBlock from '../common/form/FormNotificationBlock';
import Button from '../common/form/Button';
import { TwoColumnFields } from '../common/layout';
import { LocalRootStore } from './local_root_store';
import FormikBasicField from '../common/FormikBasicField';
import { FieldCreator } from '../common/form/FieldCreator';
import { FormikCheckbox } from '../common/form/FormikCheckbox';
import { action, observable } from 'mobx';
import HoudiniFormik, { HoudiniFormikActions, HoudiniFormikProps, HoudiniFormikServerStatus, FormikHelpers } from '../common/HoudiniFormik';
import { SupporterEntity } from './supporter_entity';
import { FormikActions } from 'formik';

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


  constructor(props: AddressPaneProps & InjectedIntlProps) {
    super(props)
    // this.addressPaneState = props.addressPaneState || new AddressPaneState(props.initialAddress, props.isDefault, props.LocalRootStore, props.onClose)
    this.initialize(props.initialAddress, props.isDefault)
  }




  initialize(initialAddress: Address, isDefault: boolean) {
    const shouldAdd = (!initialAddress || !initialAddress.id)
    this.initialValues = shouldAdd ? {} : {
      'id': initialAddress.id,
      'address': initialAddress.address,
      'city': initialAddress.city,
      'state_code': initialAddress.state_code,
      'zip_code': initialAddress.zip_code,
      'country': initialAddress.country,
      'isDefault': isDefault
    }
  }

  @observable
  initialValues: AddressPaneFormikInputProps
  
  @action.bound
  close(){
    this.props.onClose({ type: 'none' })
  }
  
  render() {
    return <HoudiniFormik initialValues={this.initialValues as AddressPaneFormikInputProps} onSubmit={(values, action) => {addressPaneFormSubmission({values:values, action:action, supporterAddressStore:this.props.LocalRootStore.supporterAddressStore, onClose: this.props.onClose})}}
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



