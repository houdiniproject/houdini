// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import * as _ from 'lodash';
import { action, observable, computed } from 'mobx';
import { HoudiniForm, StaticFormToErrorAndBackConverter } from '../../lib/houdini_form';
import { FieldDefinition, Field, initializationDefinition, Form } from 'mobx-react-form';
import { Address } from '../../../api/model/Address';
import { ApiManager } from '../../lib/api_manager';
import { SupporterApi, PostSupporterSupporterIdAddress, PutSupporterSupporterIdAddress, ValidationErrorsException } from '../../../api';


export interface AddressPaneProps
{
  nonprofitId: number
  initialAddress?:Address
  isDefault?:boolean
  onClose:(address?:Address, isDefault?:boolean) => void
  ApiManager:ApiManager
}

export class AddressPaneForm extends HoudiniForm {
  converter: StaticFormToErrorAndBackConverter<PostSupporterSupporterIdAddress| PutSupporterSupporterIdAddress>

  constructor(definition: initializationDefinition, options?: any) {
    super(definition, options)
    this.converter = new StaticFormToErrorAndBackConverter<PostSupporterSupporterIdAddress| PutSupporterSupporterIdAddress>(this.inputToForm, this)
  }

  inputToForm(): PathToFormField {
    return null;
  }

  @computed
  get isAdd() : boolean {
    return !(this.has("id") && this.get('id').value)
  }


  inputToForm = {
    'nonprofit[name]': 'nonprofitTab.organization_name',
    'nonprofit[website]': 'nonprofitTab.website',
    'nonprofit[email]': 'nonprofitTab.org_email',
    'nonprofit[phone]': 'nonprofitTab.org_phone',
    'nonprofit[city]': 'nonprofitTab.city',
    'nonprofit[state_code]': 'nonprofitTab.state',
    'nonprofit[zip_code]': 'nonprofitTab.zip',
    'user[name]': 'userTab.name',
    'user[email]': 'userTab.email',
    'user[password]': 'userTab.password',
    'user[password_confirmation]': 'userTab.password_confirmation'
  }
}


@inject('ApiManager')
class AddressPane extends React.Component<AddressPaneProps & InjectedIntlProps, {}> {

  form: AddressPaneForm
  constructor(props:AddressPaneProps & InjectedIntlProps){
    super(props)
    this.form = this.initialize(props.initialAddress)
    this.supporterApi = this.props.ApiManager.get(SupporterApi)
  }

  supporterApi:SupporterApi

  @action
  initialize(initialAddress?:Address){
    let params: {[name:string]:FieldDefinition} = {
      'id': {name:'id', value: this.shouldAdd ? undefined: initialAddress.id},
      'address': {name:'address', value: this.shouldAdd ? undefined: initialAddress.address},
      'city': {name:'city', value: this.shouldAdd ? undefined: initialAddress.city},
      'state_code': {name:'state_code', value: this.shouldAdd ? undefined: initialAddress.stateCode},
      'zip_code': {name:'zip_code', value: this.shouldAdd ? undefined: initialAddress.zipCode},
      'country': {name:'country', value: this.shouldAdd ? undefined: initialAddress.country}
    }
    let hooks = {
      onSuccess: async (f: Form) => {
        if (this.shouldAdd)
          await this.add()
        else
          await this.update()
      }
    }

    return new AddressPaneForm({fields: _.values(params), hooks:hooks})
  }

  async add() {
    try {
      await this.supporterApi.postSupporterSupporterIdAddress
    }
    catch (e) {
      console.log(e)
      if (e instanceof ValidationErrorsException) {
        this.form.converter.convertErrorToForm(e)
      }

      this.form.invalidateFromServer(e['error'])
      //set error to the form
    }
  }

  async update() {
    try {
      await this.supporterApi.putSupporterSupporterIdAddressCrmAddressId
    }
    catch (e) {
      console.log(e)
      if (e instanceof ValidationErrorsException) {
        this.form.converter.convertErrorToForm(e)
      }

      this.form.invalidateFromServer(e['error'])
      //set error to the form
    }
  }

  @action
  closePane() {
    this.props.onClose(formaddress)
  }

  get shouldAdd() {
    return this.props.initialAddress && this.props.initialAddress.id
  }

  render() {
     return <div style={{
      position:'absolute',
      width: '100%',
      height: '100%',
      right:'0px',
      top:'0px'
    }}>
      <button onClick={this.closePane}>Close</button>
      {this.props.initialAddress.address}
      {this.props.initialAddress.city}
      {this.props.initialAddress.stateCode}
      {this.props.initialAddress.zipCode}
      {this.props.initialAddress.country}

      { this.shouldAdd ? 
        <>
          <button>Add</button>
        </> : 
        <>
          <button>Save</button>
          <button>Set as default</button>
          <button>Delete</button>
        </>
      }
    </div>
  }
}

export default injectIntl(observer(AddressPane))



