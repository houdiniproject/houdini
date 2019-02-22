// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import * as _ from 'lodash';
import { action, observable, computed } from 'mobx';
import { HoudiniForm, StaticFormToErrorAndBackConverter } from '../../lib/houdini_form';
import { FieldDefinition, Field, initializationDefinition, Form } from 'mobx-react-form';
import { Address } from '../../../api/model/Address';
import { ApiManager } from '../../lib/api_manager';
import { SupporterApi, PostSupporterSupporterIdAddress, PutSupporterSupporterIdAddress, ValidationErrorsException } from '../../../api';


export interface AddressAction {
  type: 'none'| 'deleted'| 'add' | 'update'
  address?: Address
  setToDefault?:boolean
}

export interface AddressPaneProps {
  nonprofitId: number
  initialAddress: Address
  isDefault?: boolean
  onClose?: (action:AddressAction) => void
  ApiManager?: ApiManager
}

export class AddressPaneForm extends HoudiniForm {
  converter: StaticFormToErrorAndBackConverter<PostSupporterSupporterIdAddress | PutSupporterSupporterIdAddress>

  constructor(definition: initializationDefinition, options?: any) {
    super(definition, options)
    this.converter = new StaticFormToErrorAndBackConverter<PostSupporterSupporterIdAddress | PutSupporterSupporterIdAddress>(this.inputToForm, this)
  }

  inputToForm = {
    'address': 'address.address',
    'city': 'address.city',
    'stateCode': 'address.stateCode',
    'zipCode': 'address.zipCode',
    'country': 'address.country'
  }
}


@inject('ApiManager')
class AddressPane extends React.Component<AddressPaneProps & InjectedIntlProps, {}> {

  form: AddressPaneForm
  
  constructor(props: AddressPaneProps & InjectedIntlProps) {
    super(props)
    this.form = this.initialize(props.initialAddress)
    this.supporterApi = this.props.ApiManager.get(SupporterApi)
  }

  supporterApi: SupporterApi

  @computed
  get isAdd(): boolean {
    return !(this.form.has("id") && this.form.get('id').value)
  }

  @action
  initialize(initialAddress?: Address) {
    let params: { [name: string]: FieldDefinition } = {
      'id': { name: 'id', value: this.shouldAdd ? undefined : initialAddress.id },
      'address': { name: 'address', value: this.shouldAdd ? undefined : initialAddress.address },
      'city': { name: 'city', value: this.shouldAdd ? undefined : initialAddress.city },
      'state_code': { name: 'state_code', value: this.shouldAdd ? undefined : initialAddress.stateCode },
      'zip_code': { name: 'zip_code', value: this.shouldAdd ? undefined : initialAddress.zipCode },
      'country': { name: 'country', value: this.shouldAdd ? undefined : initialAddress.country }
    }

    return new AddressPaneForm({ fields: _.values(params)}, {hooks: {onSuccess: this.tryToSubmitForm}})
  }

  close(action:AddressAction) {
    this.props.onClose && this.props.onClose(action)
  }

  @action.bound
  async delete() {
    try{
      await this.supporterApi.deleteSupporterSupporterIdAddressCrmAddressId(this.props.initialAddress.supporter.id, this.props.initialAddress.id)
      this.close({type: 'deleted', address:this.props.initialAddress})
    }
    catch(e){
      //handle
    }
  }

  @action.bound
  async tryToSubmitForm(f: AddressPaneForm) {
    let input = f.converter.convertFormToObject()

    try {
      if (this.isAdd) {
        const address  = await this.supporterApi.postSupporterSupporterIdAddress(f.$('supporterId').get('value'), input)
        this.close({type: 'add', address:address })
      }
      else {
        const address = await this.supporterApi.putSupporterSupporterIdAddressCrmAddressId(f.$('supporterId').get('value'), f.$('crmAddressId').get('value'), input)

        this.close({type: 'update', address:address})
      }
    }
    catch (e) {
      if (e instanceof ValidationErrorsException) {
        this.form.converter.convertErrorToForm(e)
      }
      this.form.invalidateFromServer(e['error'])
    }
  }

  get shouldAdd() {
    return this.props.initialAddress && this.props.initialAddress.id
  }

  render() {
    return <div style={{
      position: 'absolute',
      width: '100%',
      height: '100%',
      right: '0px',
      top: '0px'
    }}>
      <button onClick={()=>this.close}>Close</button>
      {this.props.initialAddress.address}
      {this.props.initialAddress.city}
      {this.props.initialAddress.stateCode}
      {this.props.initialAddress.zipCode}
      {this.props.initialAddress.country}

      {this.shouldAdd ?
        <>
          <button onClick={() => this.form.submit()}>Add</button>
        </> :
        <>
          <button onClick={() => this.form.submit()}>Save</button>
          <button onClick={() => this.delete()}>Delete</button>
        </>
      }
    </div>
  }
}

export default injectIntl(observer(AddressPane))



