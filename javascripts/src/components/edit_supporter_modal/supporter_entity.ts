// License: LGPL-3.0-or-later
import { observable, computed, action } from "mobx";
import { SupporterStore } from "../../lib/stores/supporter_store";
import { AddressStore } from "../../lib/stores/address_store";
import * as _ from "lodash";
import { Supporter, PutSupporter, Address, PostSupporterSupporterIdAddress } from "../../../api";
import { boundMethod } from "autobind-decorator";

export function toFormSupporter(s:Supporter):Supporter {
  if (!s)
    return s;
  
  s = _.cloneDeep(s)
  return  _.mapValues(s, (i) => {
    return _.isNull(i) ? "" : i
  }) as Supporter
}

export function fromFormSupporter(s:Supporter):PutSupporter {
  if (!s)
    return s as PutSupporter;
  
  s = _.cloneDeep(s)
  return  _.mapValues(s, (i) => {
    return _.isEmpty(i) ? undefined : i
  }) as PutSupporter
}

export class SupporterEntity {
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

  @boundMethod
  updateSupporter(supporter: PutSupporter|Supporter): Promise<Supporter> {
    return this.supporterStore.updateSupporter(this.supporterId, supporter as PutSupporter);
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
    return this.addressStore.deleteCrmAddress(this.supporterId, id);
  }

}