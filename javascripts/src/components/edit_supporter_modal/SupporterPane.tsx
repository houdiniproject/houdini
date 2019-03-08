// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import SelectableTableRow from '../common/SelectableTableRow';
import Star from '../common/icons/Star';
import Button from '../common/form/Button';
import { HoudiniForm, StaticFormToErrorAndBackConverter } from '../../lib/houdini_form';
import { PutSupporter, Supporter } from '../../../api';
import { initializationDefinition } from '../../../../types/mobx-react-form';
import { computed, observable, action } from 'mobx';
import { ApiManager } from '../../lib/api_manager';
import { Address } from '../../../api';
import AddressPane, { AddressAction } from './AddressPane';
import { TwoColumnFields } from '../common/layout';
import { BasicField } from '../common/fields';
import { SupporterAddressStore } from './supporter_address_store';
import { createFieldDefinition } from '../../lib/mobx_utils';

export interface SupporterPaneProps
{
  nonprofitId: number
  supporterId: number
  onClose: () => void
  ApiManager?: ApiManager
}


export class EditSupporterForm extends HoudiniForm {
  converter: StaticFormToErrorAndBackConverter<PutSupporter>

  constructor(definition: initializationDefinition, options?: any) {
    super(definition, options)
    this.converter = new StaticFormToErrorAndBackConverter<PutSupporter>(this.inputToForm, this)
  }

  inputToForm = {
    'name': 'supporter.name',
    'email': 'supporter.email',
    'organization': 'supporter.organization',
    'phone': 'supporter.phone',
    'defaultAddress' : 'supporter.default_address.id'
  }

  

  @computed
  get serializeValues() : {name:string, email:string, organization:string, phone:string, default_address:{id:number}}{
    return {
      name: this.$('name').value,
      email: this.$('email').value,
      organization: this.$('organization').value,
      phone: this.$('phone').value,
      default_address: {
        id: this.$('defaultAddress').value
      }
    }
  }
}

class SupporterPane extends React.Component<SupporterPaneProps & InjectedIntlProps, {}> {

  constructor(props:SupporterPaneProps & InjectedIntlProps) {
    super(props)
    this.store = new SupporterAddressStore(props.supporterId, props.ApiManager)
  }
  store: SupporterAddressStore
 
  @observable
  selectedAddress:Address

  @observable
  form:EditSupporterForm


  @observable
  loaded:boolean

  @observable
  loadFailure:boolean

  @action.bound
  updateForm(s:Supporter)
  {
    this.form.update({
      name: s.name,
      email: s.email,
      organization: s.organization,
      phone: s.phone,
      defaultAddressId: s.default_address
    })
  }
  
  @action.bound
  async attemptInit() {
    try {
      this.loadFailure = false
      this.loaded = false
      await this.store.init()
      const supporter = this.store.supporter
      let params = [
        createFieldDefinition({name:'name', label: 'Name', value:supporter.name}),
        createFieldDefinition({ name: 'email', label: 'Email', value: supporter.email}),
        createFieldDefinition({name: 'phone', label: 'Phone', value: supporter.phone}),
        createFieldDefinition({name: 'organization', label: 'Organization', value: supporter.organization}),
        createFieldDefinition({name:'defaultAddressId', type: 'hidden'})
      ]
      
      
      this.form = new EditSupporterForm({ fields: params},
      {
        hooks: () =>  {
          return {onSuccess: this.tryToSubmitForm}
        }
      })
      this.loaded = true
    }
    catch(e) {
      this.loadFailure = true;  
    }
  }

 
  
  async componentDidMount(){
    
    await this.attemptInit()
    

  }

  @action.bound
  async tryToSubmitForm() {
   
  }


  @action.bound
  addAddress() {
    this.selectedAddress = {supporter: {id: this.props.supporterId}}
  }

  @action.bound
  async handleAddressPaneClose(action:AddressAction) {
    await this.store.handleAddressAction(action)
    this.selectedAddress = null;
  }

  @action.bound
  beginModifyAddress(address:Address) {
    this.selectedAddress = address
  }
  
  Components = {
    Loading: () => <div> Loading!!!</div>,
    AddressPane: () => <AddressPane 
    nonprofitId={this.props.nonprofitId} 
    onClose={this.handleAddressPaneClose}
    initialAddress={this.selectedAddress}
    isDefault={this.store.isDefaultAddress(this.selectedAddress)}/>,
    FailedToLoad: () => <div> Failure </div>,
    Main: () => <form>
    <TwoColumnFields>
     <BasicField field={this.form.$('name')} label={"Name"}/>
     <BasicField field={this.form.$('email')}  label={"Email"}/>
    
   </TwoColumnFields> 
   <TwoColumnFields>
     <BasicField field={this.form.$('phone')}  label={"Phone"}/>
     <BasicField field={this.form.$('organization')} label={"Organization"}/>
   </TwoColumnFields>

   <input {...this.form.$('defaultAddressId').bind()} value={this.store.defaultAddressId}/>
   {this.store.addresses ? 
   <table className={"clickable table--plaid"}>
     <thead>
       <th>Address</th>
       <th>Default?</th> 
     </thead>

    
     <tbody>
       {this.store.addresses.map((a) => {
         return <SelectableTableRow onSelect={() => this.beginModifyAddress(a)} key={a.id}>
           <td>{a.address}, {a.city}, {a.state_code}, {a.country}</td>
           <td style={{textAlign:"center"}}>{this.store.isDefaultAddress(a) ?  <Star/> : false}</td>
         </SelectableTableRow> 
       })
     }
     
     <SelectableTableRow onSelect={this.addAddress}>
     <td><Button onClick={this.addAddress}  buttonSize="tiny">Add Address</Button></td>
     </SelectableTableRow>
     </tbody>
   </table> : false}

   <Button
   onClick={() => this.form.submit()}>Save</Button>
  </form>
  }

  render() {
    let pane;

    if (this.loadFailure)
      pane = <this.Components.FailedToLoad/>
    else if (this.selectedAddress) {
        pane = <this.Components.AddressPane/>
    }
    else if (this.loaded) {
      pane = <this.Components.Main/>
    }
    
    else {
      pane = <this.Components.Loading/>
    }

    return <div className={"tw-bs"}>
       {pane}      
     </div>
  }
}

export default injectIntl(inject('ApiManager')(observer(SupporterPane)))



