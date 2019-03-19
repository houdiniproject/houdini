// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import SelectableTableRow from '../common/SelectableTableRow';
import Star from '../common/icons/Star';
import Button from '../common/form/Button';
import { HoudiniForm, StaticFormToErrorAndBackConverter } from '../../lib/houdini_form';
import { PutSupporter, Supporter, ValidationErrorsException } from '../../../api';
import { initializationDefinition } from '../../../../types/mobx-react-form';
import { computed, observable, action } from 'mobx';
import { Address } from '../../../api';
import AddressPane, { AddressAction } from './AddressPane';
import { TwoColumnFields } from '../common/layout';
import { BasicField } from '../common/fields';
import { SupporterAddressController } from './supporter_address_controller';
import { createFieldDefinition } from '../../lib/mobx_utils';
import FailedToLoad from './FailedToLoad';
import Spinner from '../common/Spinner';
import { isFilled } from '../../lib/utils';

export interface SupporterPaneProps {
  nonprofitId: number
  supporterId: number
  onSave: () => void
  SupporterAddressController?: SupporterAddressController
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
    'defaultAddressId': 'supporter.default_address.id'
  }



  @computed
  get serializeValues(): { name: string, email: string, organization: string, phone: string, default_address: { id: number } } {
    return {
      name: this.$('name').value,
      email: this.$('email').value,
      organization: this.$('organization').value,
      phone: this.$('phone').value,
      default_address: {
        id: this.$('defaultAddressId').value
      }
    }
  }
}

class SupporterPane extends React.Component<SupporterPaneProps & InjectedIntlProps, {}> {

  constructor(props: SupporterPaneProps & InjectedIntlProps) {
    super(props)
  }

  @observable
  selectedAddress: Address

  @observable
  form: EditSupporterForm

  @observable
  loaded: boolean

  @computed
  get loading(): boolean {
    return !this.loaded;
  }

  @observable
  loadFailure: boolean

  @action.bound
  updateForm(s: Supporter) {
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
      await this.props.SupporterAddressController.init()
      const supporter = this.props.SupporterAddressController.supporter
      let params = [
        createFieldDefinition({ name: 'name', label: 'Name', value: supporter.name }),
        createFieldDefinition({ name: 'email', label: 'Email', value: supporter.email }),
        createFieldDefinition({ name: 'phone', label: 'Phone', value: supporter.phone }),
        createFieldDefinition({ name: 'organization', label: 'Organization', value: supporter.organization })
      ]


      this.form = new EditSupporterForm({ fields: params },
        {
          hooks: {
             onSuccess: async (f: any) => {
              await this.tryToSubmitForm()
            } 
          }
        })
      this.loaded = true;
    }
    catch (e) {
      console.error(e)
      this.loadFailure = true;
    }
  }



  async componentDidMount() {

    await this.attemptInit()


  }

  @action.bound
  async tryToSubmitForm() {
    try {
      await this.props.SupporterAddressController.updateSupporter(this.form.serializeValues)
      this.props.onSave();
    }
    catch (e) {
      if (e instanceof ValidationErrorsException) {
        this.form.converter.convertErrorToForm(e)
      }
      else {
        this.form.invalidateFromServer(e['error'])
      }
    }
  }


  @action.bound
  addAddress() {
    this.selectedAddress = { supporter: { id: this.props.supporterId } }
  }

  @action.bound
  async handleAddressPaneClose(action: AddressAction) {
    this.selectedAddress = null;
    await this.props.SupporterAddressController.handleAddressAction(action)
    this.form.$('defaultAddressId').set(this.props.SupporterAddressController.defaultAddressId)
  }

  @action.bound
  beginModifyAddress(address: Address) {
    this.selectedAddress = address
  }

  render() {
    let pane;

    if (this.loadFailure)
      pane = <FailedToLoad />
    else if (this.selectedAddress) {
      pane = <AddressPane
        nonprofitId={this.props.nonprofitId}
        onClose={this.handleAddressPaneClose}
        initialAddress={this.selectedAddress}
        isDefault={this.props.SupporterAddressController.isDefaultAddress(this.selectedAddress)} />
    }
    else if (!this.loading) {
      pane = <form>
        <TwoColumnFields>
          <BasicField field={this.form.$('name')} label={"Name"} />
          <BasicField field={this.form.$('email')} label={"Email"} />

        </TwoColumnFields>
        <TwoColumnFields>
          <BasicField field={this.form.$('phone')} label={"Phone"} />
          <BasicField field={this.form.$('organization')} label={"Organization"} />
        </TwoColumnFields>

        <input {...this.form.$('defaultAddressId').bind()} /> <!--- ethwoithio isn't working because defaultAddressId is not set properly -->
        {this.props.SupporterAddressController.addresses ?
          <table className={"clickable table--plaid"}>
            <thead>
              <tr>
                <th>Address</th>
                <th style={{textAlign: 'center'}}>Default?</th>
              </tr>
            </thead>


            <tbody style={{fontSize: '14px'}}>
              {this.props.SupporterAddressController.addresses.map((a) => {
                const address = [a.address, a.city, a.state_code, a.zip_code, a.country].filter((i) => isFilled(i)).join(", ")
                return <SelectableTableRow onSelect={() => this.beginModifyAddress(a)} key={a.id}>
                  <td>{address}</td>
                  <td style={{ textAlign: "center" }}>{this.props.SupporterAddressController.defaultAddressId === a.id ? <Star /> : false}</td>
                </SelectableTableRow>
              })
              }

              <SelectableTableRow onSelect={this.addAddress}>
                <td><Button onClick={this.addAddress} buttonSize="tiny">Add Address</Button></td>
              </SelectableTableRow>
            </tbody>
          </table> : false}

        <Button type={'submit'}
          onClick={this.form.onSubmit} >Save</Button>
      </form>
    }

    else {
      pane = <Spinner size="normal">Loading...</Spinner>
    }

    return <div className={"tw-bs"}>
      {pane}
    </div>
  }
}

export default injectIntl(observer(SupporterPane))



