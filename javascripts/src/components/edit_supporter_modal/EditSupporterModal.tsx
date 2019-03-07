// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject, disposeOnUnmount } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import Modal from '../common/Modal';
import { TwoColumnFields } from '../common/layout';
import { BasicField } from '../common/fields';
import { observable, action, computed, reaction, IReactionDisposer } from 'mobx';
import { Address } from '../../../api/model/Address';
import AddressPane, { AddressAction } from './AddressPane';
import { SupporterApi, PutSupporter, Supporter, APIS } from '../../../api';
import { HoudiniForm, StaticFormToErrorAndBackConverter } from '../../lib/houdini_form';
import { initializationDefinition, FieldDefinition } from '../../../../types/mobx-react-form';
import * as _ from 'lodash';
import { CSRFInterceptor } from '../../lib/csrf_interceptor';
import { ApiManager } from '../../lib/api_manager';
import SelectableTableRow from '../common/SelectableTableRow';
import Star from '../common/icons/Star';
import Button from '../common/form/Button';

export interface EditSupporterModalProps {
  //from ModalProps
  onClose: () => void
  modalActive: boolean
  nonprofitId: number
  supporterId: number
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

class EditSupporterModal extends React.Component<EditSupporterModalProps & InjectedIntlProps, {}> {

  constructor(props:EditSupporterModalProps & InjectedIntlProps) {
    super(props)
    this.ApiManager = new ApiManager(APIS, CSRFInterceptor)
    this.SupporterApi = this.ApiManager.get(SupporterApi)
    this.form = this.createNewForm()
   
  }


  ApiManager: ApiManager
  SupporterApi: SupporterApi
  
  @disposeOnUnmount
  updateValuesFormReaction: IReactionDisposer = reaction(
    () => this.supporter, 
    (s) => { this.updateForm(s)}
  )


  @observable
  supporter:Supporter

  @observable
  addresses:Array<Address>
  
  @observable
  selectedAddress:Address

  @observable
  form:EditSupporterForm

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

  @computed
  get defaultAddressId():number {
    return this.supporter && this.supporter.default_address && this.supporter.default_address.id
  }

  isDefaultAddress(address:Address):boolean {
    return address.id && address.id === this.defaultAddressId
  }
  
  componentDidMount(){
   this.loadSupporterAndAddress()
  }

  
  createNewForm() : EditSupporterForm
  {
    let params: { [name: string]: FieldDefinition } = {
      'name': { name: 'name', label: 'Name' },
      'email': { name: 'email', label: 'Email'},
      'phone': {name: 'phone', label: 'Phone'},
      'organization': {name: 'organization', label: 'Organization'},
      'defaultAddressId': {name:' defaultAddressId'}
    }

    return new EditSupporterForm({ fields: _.values(params)}, 
    {
      hooks: () =>  {
        return {onSuccess: this.tryToSubmitForm}
      }
    })
  }

  @action.bound
  async tryToSubmitForm() {
   
  }
  

  

  @action.bound
  async loadSupporterAndAddress() {
    this.loadSupporter()
    
    const addresses = await this.SupporterApi.getCrmAddresses(this.props.supporterId, 'CRM', PageLength)

    this.addresses = addresses.addresses
    
    
  }
  
  @action.bound
  async loadSupporter(){ 
    this.supporter = await this.SupporterApi.getSupporter(this.props.supporterId)
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
        break;
      case 'delete':
        this.handleDeletedAddress(action)
        break;
      case 'update':
        this.handleUpdatedAddress(action)
        break;
      case 'none':
        this.handleNoAction(action);
        break;
    }
  }

  @action.bound
  async handleAddedAddress(action:AddressAction) {
    this.addresses.push(action.address)
    await this.loadSupporter()
    if (action.setToDefault)
      this.form.$('defaultAddressId').set(action.address.id)
    this.selectedAddress = null
  }

  @action.bound
  async handleDeletedAddress(action:AddressAction) {
    _.remove(this.addresses, (a) => a.id === action.address.id)
    await this.loadSupporter()
    this.selectedAddress = null
  }

  @action.bound
  async handleUpdatedAddress(action:AddressAction) {
    const index = _.findIndex(this.addresses, (a) => a.id === action.address.id)
    this.addresses.splice(index, 1, action.address)
    await this.loadSupporter()
    this.selectedAddress = null

    if (action.setToDefault)
      this.form.$('defaultAddressId').set(action.address.id)
  }

  @action.bound
  handleNoAction(action:AddressAction) {
    this.selectedAddress = null
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
        isDefault={this.isDefaultAddress(this.selectedAddress)} ApiManager={this.ApiManager}
        >

    </AddressPane>: <form>
             <TwoColumnFields>
              <BasicField field={this.form.$('name')} label={"Name"}/>
              <BasicField field={this.form.$('email')}  label={"Email"}/>
             
            </TwoColumnFields> 
            <TwoColumnFields>
              <BasicField field={this.form.$('phone')}  label={"Phone"}/>
              <BasicField field={this.form.$('organization')} label={"Organization"}/>
            </TwoColumnFields>
        
            {/* <div style={{textAlign: "right"}}><Button onClick={this.addAddress}  buttonSize="tiny">Add Address</Button></div> */}
            {this.addresses ? 
            <table className={"clickable table--plaid"}>
              <thead>
                <th>Address</th>
                <th>Default?</th> 
              </thead>
              <tbody>
                {this.addresses.map((a) => {
                  return <SelectableTableRow onSelect={() => this.beginModifyAddress(a)} key={a.id}>
                    <td>{a.address}, {a.city}, {a.state_code}, {a.country}</td>
                    <td style={{textAlign:"center"}}>{this.isDefaultAddress(a) ?  <Star/> : false}</td>
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

    return <Modal 
      modalActive={this.props.modalActive} 
      titleText={'Create Offsite Donation'}
      focusDialog={true}
      onClose={this.props.onClose}
      dialogStyle={{ minWidth: '768px', position:'relative'}} 
      childGenerator={() => {
        return <div className={"tw-bs"}>
          {coverpane}      
        </div>
      }}>
    </Modal>
  }
}

export default injectIntl(observer(EditSupporterModal))



