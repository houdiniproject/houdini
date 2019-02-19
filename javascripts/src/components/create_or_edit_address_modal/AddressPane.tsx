// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import * as _ from 'lodash';
import { action, observable } from 'mobx';
import { HoudiniForm } from '../../lib/houdini_form';
import { FieldDefinition, Field } from 'mobx-react-form';
import { Address } from '../../../api/model/Address';
import { ApiManager } from '../../lib/api_manager';
import { SupporterApi } from '../../../api';


export interface AddressPaneProps
{
  nonprofitId: number
  initialAddress?:Address
  isDefault?:boolean
  onClose:(address?:Address, isDefault?:boolean) => void
  ApiManager:ApiManager
}

@inject('ApiManager')
class AddressPane extends React.Component<AddressPaneProps & InjectedIntlProps, {}> {
  constructor(props:AddressPaneProps & InjectedIntlProps){
    super(props)
    this.form = this.initialize()
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
      onSuccess: async (e: Field) => {
        if (this.shouldAdd)
          await this.add
        else
          await this.update
      }
    }

    return new HoudiniForm({fields: _.values(params), hooks:hooks})
  }

  async add() {
    this.
  }

  async update() {

  }

  
  @observable
  form:HoudiniForm

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



