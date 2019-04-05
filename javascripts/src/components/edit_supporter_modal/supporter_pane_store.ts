// License: LGPL-3.0-or-later
import { Address, Supporter, PutSupporter } from "../../../api";
import { SupporterAddressStore } from "./supporter_address_store";
import { observable, computed, action } from "mobx";
import { createFieldDefinition } from "../../lib/mobx_utils";
import { EditSupporterForm } from "./supporter_form";
import { AddressAction } from "./AddressPane";
import * as _ from "lodash";
import { DefaultAddressStrategy } from "./default_address_strategy";

export class SupporterPaneStore {
  constructor(
    private supporterAddressStore: SupporterAddressStore
  ) {
    this.defaultAddressStrategy = new DefaultAddressStrategy(
      () => this.supporterAddressStore.addresses,
      () => this.defaultAddressId,
      (addressId: number) => {
        this.form.$('defaultAddressId').set(addressId)
      });
  }

  defaultAddressStrategy: DefaultAddressStrategy

  @observable
  loaded: boolean = false

  @observable
  loadFailure: boolean

  @observable
  addressToEdit: Address

  @observable
  form: EditSupporterForm

  @observable
  anAddressWasEdited: boolean

  @computed
  get loading(): boolean {
    return !this.loaded
  }

  @computed
  get editingAddress(): boolean {
    return !!this.addressToEdit;
  }
  @computed
  get defaultAddressId(): number {
    return this.form.$('defaultAddressId').value
  }

  @computed
  get isSelectedAddressDefault(): boolean {
    return this.defaultAddressId &&
      this.isDefaultAddress(this.defaultAddressId)
  }

  @action.bound
  editAddress(address?: Address) {
    this.addressToEdit = address || { supporter: { id: this.supporterAddressStore.supporter.id } }
  }

  @action.bound
  addAddress() {
    this.editAddress();
  }

  @action.bound
  async attemptInit() {
    try {
      this.loadFailure = false
      this.loaded = false
      await this.init()
      this.loaded = true;
    }
    catch (e) {
      console.error(e)
      this.loadFailure = true;
    }
  }

  @action.bound
  async init() {
    const supporter = await this.supporterAddressStore.loadSupporter()
    await this.supporterAddressStore.loadAddresses();
    this.form = SupporterPaneStore.initializeSupporterForm(this.supporterAddressStore.updateSupporter, supporter)
  }

  static initializeSupporterForm(updateSupporter:(supporter: PutSupporter) => Promise<Supporter>, supporter:Supporter):EditSupporterForm {
    let params = [
      createFieldDefinition({ name: 'name', label: 'Name', value: supporter.name }),
      createFieldDefinition({ name: 'email', label: 'Email', value: supporter.email }),
      createFieldDefinition({ name: 'phone', label: 'Phone', value: supporter.phone }),
      createFieldDefinition({ name: 'organization', label: 'Organization', value: supporter.organization }),

      createFieldDefinition({ name: 'defaultAddressId', type: 'hidden', value: (supporter.default_address && supporter.default_address.id) || null })
    ]


    return new EditSupporterForm(updateSupporter, { fields: params })
  }

  @action.bound
  handleAddressAction(action: AddressAction) {
    this.editAddress = null;
    this.defaultAddressStrategy.handleAddressAction(action)
    if (action.type !== 'none')
    {
      this.anAddressWasEdited = true;
    }
  }
  
  isDefaultAddress(address: Address | number): boolean {
    let addressId = address
    if (typeof address !== 'number') {
      addressId = address.id
    }

    return this.defaultAddressId && addressId && addressId === this.defaultAddressId;
  }

}
