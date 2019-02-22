// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import Modal from '../common/Modal';
import { TwoColumnFields } from '../common/layout';
import { BasicField } from '../common/fields';
import { observable, action, computed, reaction, Reaction, IReactionDisposer } from 'mobx';
import { Address } from '../../../api/model/Address';
import AddressPane, { AddressAction } from './AddressPane';
import { SupporterApi, PutSupporterSupporterDefaultAddress, PutSupporter, Supporter, PostSupporterSupporterIdAddress, PutSupporterSupporter, PutSupporterSupporterIdAddress } from '../../../api';
import { HoudiniForm, StaticFormToErrorAndBackConverter } from '../../lib/houdini_form';
import { initializationDefinition, FieldDefinition } from '../../../../types/mobx-react-form';
import _ = require('lodash');

export interface CreateOrEditAddressModalProps {
  //from ModalProps
  onClose: () => void
  modalActive: boolean
  nonprofitId: number
  supporterId: number
  SupporterApi?:SupporterApi
}

// TODO: we only get the first 100 addresses. We will get more in the future (probably with rxjs) but seriously, you shouldn't have that many
const PageLength = 100

export class EditSupporterForm extends HoudiniForm {
  converter: StaticFormToErrorAndBackConverter<PutSupporter>

  constructor(definition: initializationDefinition, options?: any) {
    super(definition, options)
    this.converter = new StaticFormToErrorAndBackConverter<PutSupporter>(this.inputToForm, this)
  }

  inputToForm = {
    'name': 'supporter.name',
    'email': 'supporter.emailAddress',
    'organization': 'supporter.organization',
    'phone': 'supporter.phone',
    'defaultAddress' : 'supporter.defaultAddress.id'
  }
}

@inject('SupporterApi')
class CreateOrEditAddressModal extends React.Component<CreateOrEditAddressModalProps & InjectedIntlProps, {}> {

  constructor(props:CreateOrEditAddressModalProps & InjectedIntlProps) {
    super(props)
    this.form = this.createNewForm()
    this.updateValuesFormReaction = reaction(
        () => this.supporter, 
        (s, r) => { this.updateForm(s)}
      )
    
  }

  componentWillUnmount(){
    this.updateValuesFormReaction && this.updateValuesFormReaction()
  }

  updateValuesFormReaction: IReactionDisposer

  @observable
  supporter:Supporter

  @observable
  addresses:Array<Address>
  
  @observable
  selectedAddress:Address

  @observable
  form:HoudiniForm
  
  

  @action.bound
  updateForm(s:Supporter)
  {
    this.form.update({
      name: s.name,
      email: s.emailAddress,
      organization: s.organization,
      phone: s.phone,
      defaultAddressId: s.defaultAddress
    })
  }

  @computed
  get defaultAddressId():number {
    return this.supporter && this.supporter.defaultAddress && this.supporter.defaultAddress.id
  }

  isDefaultAddress(address:Address):boolean {
    return address.id && address.id === this.defaultAddressId
  }


  
  componentDidMount(){
   this.loadSupporterAndAddress()
  }

  
  createNewForm() : HoudiniForm
  {
    let params: { [name: string]: FieldDefinition } = {
      'name': { name: 'name' },
      'email': { name: 'email'},
      'phone': {name: 'phone'},
      'organization': {name: 'organization'},
      'defaultAddress': {name:' defaultAddress'}
    }

    return new EditSupporterForm({ fields: _.values(params)}, {hooks: {onSuccess: this.tryToSubmitForm}})
  }

  @action.bound
  async tryToSubmitForm() {

  }

  

  @action.bound
  async loadSupporterAndAddress() {
    this.loadSupporter()
    
    const addresses = await this.props.SupporterApi.getSupporterSupporterIdAddress(this.props.supporterId, 'CRM', PageLength)

    this.addresses = addresses.addresses
    
    
  }
  
  @action.bound
  async loadSupporter(){ 
    this.supporter = await this.props.SupporterApi.getSupporterSupporterId(this.props.supporterId)
  }

  @action.bound
  addAddress() {
    this.selectedAddress = {supporter: {id: this.props.supporterId}}
  }

  @action.bound
  handleAddressAction(action:AddressAction)
  {
    switch(action.type) {
      case 'add':
        this.handleAddedAddress(action)
      case 'deleted':
        this.handleDeletedAddress(action)
      case 'update':
        this.handleUpdatedAddress(action)
      case 'none':
        break;
    }
  }

  @action.bound
  async handleAddedAddress(action:AddressAction) {
    this.addresses.push(action.address)
    await this.loadSupporter()
    if (action.setToDefault)
      this.form.$('defaultAddress').set(action.address.id)
  }

  

  @action.bound
  async handleDeletedAddress(action:AddressAction) {
    _.remove(this.addresses, (a) => a.id === action.address.id)
    await this.loadSupporter()
  }

  @action.bound
  async handleUpdatedAddress(action:AddressAction) {
    const index = _.findIndex(this.addresses, (a) => a.id === action.address.id)
    this.addresses.splice(index, 1, action.address)
    await this.loadSupporter()

    if (action.setToDefault)
      this.form.$('defaultAddress').set(action.address.id)
  }

  @action.bound
  beginModifyAddress(address:Address) {
    this.selectedAddress = address
  }

  render() {

    let coverpane = this.selectedAddress ? <AddressPane 
      nonprofitId={this.props.nonprofitId} 
      onClose={this.handleAddressAction}
      initialAddress={this.selectedAddress}
      isDefault={this.isDefaultAddress(this.selectedAddress)}
      >

    </AddressPane> : false

    return <Modal 
      modalActive={this.props.modalActive} 
      titleText={'Create Offsite Donation'}
      focusDialog={true}
      onClose={this.props.onClose}
      dialogStyle={{ minWidth: '768px' }} 
      childGenerator={() => {
        return <div className={"tw-bs"}>
          <div style={{
            position:'absolute',
            zIndex:100,
            top:'0px',
            left:'0px',
            height:'100%',
            width:'100%'
          }}>
          {coverpane}
          </div>
          <form className='u-marginTop--20'>
             <TwoColumnFields>
              <BasicField field={this.form.$('name')} />
              <BasicField field={this.form.$('email')} />
              <BasicField field={this.form.$('phone')} />
              <BasicField field={this.form.$('organization')} />
            </TwoColumnFields> 
            <hr />
            <button onClick={this.addAddress}>Add Address</button>
            {this.addresses.map((a) => {
              return <div>
                {a.address}, {a.city}, {a.stateCode}, {a.country} <button onClick={() => this.beginModifyAddress(a)}>Modify</button>
              </div>
            })}
            <hr/>
            <button type="submit" 
            onClick={() => this.form.submit()}>Save</button>
          </form>
        </div>
      }}>
    </Modal>
  }
}

export default injectIntl(observer(CreateOrEditAddressModal))



