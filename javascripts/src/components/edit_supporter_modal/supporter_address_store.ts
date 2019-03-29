// License: LGPL-3.0-or-later
import { observable, computed, action } from "mobx";
import { SupporterStore } from "../../lib/stores/supporter_store";
import { AddressStore } from "../../lib/stores/address_store";
import * as _ from "lodash";
import { Supporter, PutSupporter, Address, PostSupporterSupporterIdAddress } from "../../../api";

export class SupporterAddressStore {
  constructor(
    private supporterId?: number,
    private supporterStore?: SupporterStore,
    private addressStore?: AddressStore,
  ) { }

  @computed get loading(): boolean {
    return this.supporterLoading
      || this.addressLoading;
  }

  @computed get supporterLoading(): boolean {
    return this.supporterStore.isLoading
  }

  @computed get addressLoading(): boolean {
    return this.addressStore.isLoading;
  }

  @computed get supporter(): Supporter {
    return _.find(this.supporterStore.supporters,
      (s: Supporter) => s.id === this.supporterId)
  }

  @computed get addresses() {
    return _.filter(this.addressStore.addresses, (a: Address) => a.supporter.id === this.supporterId)
  }

  loadSupporter({ acceptCached = false } = {}): Promise<Supporter> {
    return this.supporterStore.loadSupporter(this.supporterId, { acceptCached })
  }

  updateSupporter(supporter: PutSupporter): Promise<Supporter> {
    return this.supporterStore.updateSupporter(this.supporterId, supporter);
  }

  loadAddresses() {
    return this.addressStore.loadCrmAddresses(this.supporterId)
  }

  loadAddress(id: number, { acceptCached = false } = {}): Promise<Address> {
    return this.addressStore.loadCrmAddress(this.supporterId, id, { acceptCached });
  }

  createAddress(address: PostSupporterSupporterIdAddress): Promise<Address> {
    return this.addressStore.createCrmAddress(this.supporterId, address)
  }

  updateAddress(id: number, address: PostSupporterSupporterIdAddress): Promise<Address> {
    return this.addressStore.updateCrmAddress(this.supporterId, id, address);
  }

  deleteAddress(id: number) {
    this.addressStore.deleteCrmAddress(this.supporterId, id);
  }
}