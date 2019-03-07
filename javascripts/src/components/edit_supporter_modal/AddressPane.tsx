// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import * as _ from 'lodash';
import { action, observable, computed } from 'mobx';
import { HoudiniForm, StaticFormToErrorAndBackConverter, HoudiniField } from '../../lib/houdini_form';
import { FieldDefinition, Field, initializationDefinition, Form } from 'mobx-react-form';
import { Address } from '../../../api/model/Address';
import { ApiManager } from '../../lib/api_manager';
import { SupporterApi, ValidationErrorsException, TimeoutError } from '../../../api';
import { BasicField } from '../common/fields';
import ReactCheckbox from '../common/form/ReactCheckbox';
import FormNotificationBlock from '../common/form/FormNotificationBlock';
import Button from '../common/form/Button';



export interface AddressAction {
  type: 'none' | 'delete' | 'add' | 'update'
  address?: Address
  setToDefault?: boolean
}

export interface AddressPaneProps {
  nonprofitId: number
  initialAddress: Address
  isDefault?: boolean
  onClose?: (action: AddressAction) => void
  ApiManager?: ApiManager
}



interface FormOutput {
  address?: string
  city?: string
  state_code?: string
  zip_code?: string
  country?: string
}

interface ServerErrorInput {
  address?: Array<string>
  city?: Array<string>
  state_code?: Array<string>
  zip_code?: Array<string>
  country?: Array<string>
}
export class AddressPaneForm extends HoudiniForm {
  constructor(definition: initializationDefinition, options?: any) {
    super(definition, options)
  }

  @computed
  get serializedValue(): FormOutput {
    return {
      address: this.$('address').value,
      city: this.$('city').value,
      state_code: this.$('state_code').value,
      zip_code: this.$('zip_code').value,
      country: this.$('country').value
    }
  }


  @action.bound
  assignServerErrors(e: ServerErrorInput) {
    //reset our server status
    this.each((i: HoudiniField) => { i.resetServerValidation() })
    _.forOwn(e, (i, key) => {
      const errors = i.join(", ");
      (this.$(key) as HoudiniField).invalidateFromServer(errors)
    })
  }
}




class AddressPane extends React.Component<AddressPaneProps & InjectedIntlProps, {}> {

  form: AddressPaneForm

  public getForm(): AddressPaneForm {
    return this.form;
  }


  constructor(props: AddressPaneProps & InjectedIntlProps) {
    super(props)
    this.form = this.initialize(props.initialAddress)
    this.supporterApi = this.props.ApiManager.get(SupporterApi)
  }

  supporterApi: SupporterApi

  @computed
  get isAdd(): boolean {
    return !(this.form.has("id") && this.form.$('id').value)
  }

  @computed
  get supporterId(): number {
    return this.props.initialAddress && this.props.initialAddress.supporter && this.props.initialAddress.supporter.id
  }

  @action
  initialize(initialAddress?: Address) {
    let params: { [name: string]: FieldDefinition } = {
      'id': { name: 'id', value: this.shouldAdd ? undefined : initialAddress.id },
      'address': { name: 'address', value: this.shouldAdd ? undefined : initialAddress.address },
      'city': { name: 'city', value: this.shouldAdd ? undefined : initialAddress.city },
      'state_code': { name: 'state_code', value: this.shouldAdd ? undefined : initialAddress.state_code },
      'zip_code': { name: 'zip_code', value: this.shouldAdd ? undefined : initialAddress.zip_code },
      'country': { name: 'country', value: this.shouldAdd ? undefined : initialAddress.country },

      'is_default': { name: 'is_default', value: this.props.isDefault, type:'checkbox' }
    }

    return new AddressPaneForm({ fields: _.values(params) }, {
      hooks: {
        onSuccess: async (f: any) => {
          await this.tryToSubmitForm(f)
        }
      }
    })
  }

  close(action: AddressAction) {
    this.props.onClose && this.props.onClose(action)
  }

  @observable
  attemptDelete:boolean


  @action.bound
  async tryToSubmitForm(f: AddressPaneForm) {
    let input = f.serializedValue

    try {
      if (this.attemptDelete){
        await this.supporterApi.deleteCrmAddress(this.props.initialAddress.supporter.id, this.props.initialAddress.id)
        this.close({ type: 'delete', address: this.props.initialAddress })
      
      }
      else
      {

      
      if (this.isAdd) {
        const address = await this.supporterApi.createCrmAddress(this.supporterId, input)
        this.close({ type: 'add', address: address, setToDefault: f.$('is_default').value })
      }
      else {
        const address = await this.supporterApi.updateCrmAddress(this.supporterId, f.$('id').get('value'), input)

        this.close({ type: 'update', address: address, setToDefault: f.$('is_default').value })
      }
      }
    }
    catch (e) {
      if ( e instanceof TimeoutError) {
        this.form.invalidateFromServer("The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds.")
      }
      else {
        if (e instanceof ValidationErrorsException) {

        }
        

        this.form.invalidateFromServer(e['error'])
      }
    }
  }

  @computed
  get shouldAdd() {
    return !this.props.initialAddress || !this.props.initialAddress.id
  }

  
  @computed
  get modifiedEnoughToSubmit() : boolean {
    return this.form.isDirty && (this.form.$('address').isDirty 
    || this.form.$('city').isDirty 
    || this.form.$('state_code').isDirty 
    || this.form.$('zip_code').isDirty 
    || this.form.$('country').isDirty)
  }

  

  render() {
    return <div style={{
      // position: 'absolute',
      // width: '100%',
      // height: '100%',
      // right: '0px',
      // top: '0px',
      // backgroundColor: 'white',
      // display: 'flex',
      // flexDirection: 'column'
    }}>
      <div style={{ flex: 'auto' }}>
        <form>
          <BasicField field={this.form.$('address')} label={"Address"} />
          <BasicField field={this.form.$('city')} label={"City"} />
          <BasicField field={this.form.$('state_code')} label={"State Code/Region"} />
          <BasicField field={this.form.$('zip_code')} label={"Postal/Zip Code"} />
          <BasicField field={this.form.$('country')} label={"Country"} />
          <ReactCheckbox field={this.form.$('is_default')} label={"Set as Default Address"}/>
          
          {this.form.serverError ? <FormNotificationBlock 
            message={this.form.serverError}/> : ""}
        </form>
      </div>
      <div>

        <Button onClick={() => this.close({ type: 'none' })}>Close</Button>
        {this.shouldAdd ?
          <>
            <Button onClick={() => this.form.submit()} disabled={!this.modifiedEnoughToSubmit}>Add</Button>
          </> :
          <>
            <Button onClick={() => this.form.submit()} disabled={!this.modifiedEnoughToSubmit}>Save</Button>
            <Button onClick={() => {this.attemptDelete = true; this.form.submit();}}>Delete</Button>
          </>
        }
      </div>
    </div>
  }
}

export default injectIntl(observer(AddressPane))



