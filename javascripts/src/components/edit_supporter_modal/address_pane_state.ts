// License: LGPL-3.0-or-later
import { action, computed, observable } from "mobx";
import { Address } from "../../../api";
import { FieldDefinition } from "mobx-react-form";
import { AddressPaneForm } from "./address_pane_form";
import * as _ from 'lodash';
import { SupporterAddressStore } from "./supporter_address_store";
import { FormOutput, AddressAction } from "./AddressPane";

export class AddressPaneState {
  constructor(
    private initialAddress: Address, 
    private isDefault: boolean, 
    private rootStore: { supporterAddressStore: SupporterAddressStore }, readonly onClose?: (action: AddressAction) => void, 
    form?:AddressPaneForm
    ) {
    this.form = form
    if (!this.form)
      this.initialize(initialAddress)
  }

  form: AddressPaneForm;

  @observable
  attemptDelete: boolean;

  @computed
  get supporterAddressStore(): SupporterAddressStore {
    return this.rootStore.supporterAddressStore;
  }

  @computed
  get isAdd(): boolean {
    return !(this.form.has("id") && this.form.$('id').value);
  }

  @computed
  get canDelete(): boolean {
    return !this.isAdd
  }

  @computed
  get supporterId(): number {
    return this.initialAddress && this.initialAddress.supporter && this.initialAddress.supporter.id;
  }

  @computed
  get shouldAdd() {
    return !this.initialAddress || !this.initialAddress.id;
  }
  

  @computed
  get modifiedEnoughToSubmit(): boolean {
    //needs to NOT just be is_default
    return this.form.isDirty && !(this.form.$('is_default').isDirty && (this.form.$('address').isEmpty
      && this.form.$('city').isEmpty
      && this.form.$('state_code').isEmpty
      && this.form.$('zip_code').isEmpty
      && this.form.$('country').isEmpty));
  }

  @action.bound
  initialize(initialAddress?: Address) {
    let params: {
      [name: string]: FieldDefinition;
    } = {
      'id': { name: 'id', value: this.shouldAdd ? undefined : initialAddress.id },
      'address': { name: 'address', value: this.shouldAdd ? undefined : initialAddress.address },
      'city': { name: 'city', value: this.shouldAdd ? undefined : initialAddress.city },
      'state_code': { name: 'state_code', value: this.shouldAdd ? undefined : initialAddress.state_code },
      'zip_code': { name: 'zip_code', value: this.shouldAdd ? undefined : initialAddress.zip_code },
      'country': { name: 'country', value: this.shouldAdd ? undefined : initialAddress.country },
      'is_default': { name: 'is_default', value: this.isDefault, type: 'checkbox' }
    };
    this.form = new AddressPaneForm({ fields: _.values(params) }, {
      submissionFunction: this.submissionFunction
    });
  }

  @action.bound
  async submissionFunction(input: FormOutput) {
    if (this.attemptDelete) {
      try {
        await this.supporterAddressStore.deleteAddress(this.initialAddress.id)
        this.close({ type: 'delete', address: this.initialAddress })
      }
      finally {
        this.attemptDelete = false;
      }
    }
    else {

      if (this.isAdd) {
        const address = await this.supporterAddressStore.createAddress(input)

        this.close({ type: 'add', address: address, setToDefault: this.form.$('is_default').value })
      }
      else {
        const address = await this.supporterAddressStore.updateAddress(this.form.$('id').get('value'), input)

        this.close({ type: 'update', address: address, setToDefault: this.form.$('is_default').value })
      }
    }
  }

  close(address:AddressAction) {
    this.onClose && this.onClose(address)
  }

  @action.bound
  onDelete(...a: any[]){
    this.attemptDelete = true;
    this.form.onSubmit(...a) 
  }

  @action.bound
  delete(){
    this.attemptDelete = true;
    this.form.submit()
  }



}
