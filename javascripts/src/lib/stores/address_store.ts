// License: LGPL-3.0-or-later
import { observable, computed, action } from "mobx";
import { Address, PutSupporterSupporterIdAddress, PostSupporterSupporterIdAddress, SupporterApi } from "../../../api";
import { ApiManager } from "../api_manager";
import _ = require("lodash");

export class AddressStore {

  constructor(private rootStore:{apiManager:ApiManager}){}

  @computed get supporterApi():SupporterApi {
    return this.rootStore.apiManager.get(SupporterApi)
  }

  @observable isLoading = false;
  @observable addressRegistry = observable.map<number, Address>();

  @computed get addresses(): ReadonlyArray<Address> {
    return _.values(this.addressRegistry.toPOJO())
  }

  @action.bound
  async loadCrmAddresses(supporterId:number) {
    this.isLoading = true;
    try {
      const addresses = await this.supporterApi.getCrmAddresses(supporterId)
      addresses.addresses.forEach((a:any) => this.addressRegistry.set(a.id, a))
    }
    finally {
      this.isLoading = false;
    }
  }

  @action.bound
  async loadCrmAddress(supporterId:number, id: number, { acceptCached = false } = {}) : Promise<Address> {
    if (acceptCached){
      const address = this.getAddress(id)
      if (address)
        return address
    }
    this.isLoading = true
    try {
      const address = await this.supporterApi.getCrmAddress(supporterId, id)
      this.addressRegistry.set(address.id, address)
      return address;
    }
    finally {
      this.isLoading = false
    }
  }

  @action.bound
  async createCrmAddress(supporterId:number, address: PostSupporterSupporterIdAddress) : Promise<Address> {
    const newAddress = await this.supporterApi.createCrmAddress(supporterId, address)
    this.addressRegistry.set(newAddress.id, newAddress)
    return newAddress
  }

  @action.bound
  async updateCrmAddress(supporterId:number, id:number, address: PutSupporterSupporterIdAddress) : Promise<Address> {
    const updatedAddress = await this.supporterApi.updateCrmAddress(supporterId, id, address)
    this.addressRegistry.set(id, updatedAddress)
    return updatedAddress;
  }

  @action
  async deleteCrmAddress(supporterId:number, id: number) {
    this.addressRegistry.delete(id)
    try {
      await this.supporterApi.deleteCrmAddress(supporterId, id)
    }
    catch(e) {
      this.loadCrmAddresses(supporterId)
      throw e;
    }
  }

  private clear() {
    this.addressRegistry.clear()
  }

  private getAddress(id: number) {
    return this.addressRegistry.get(id)
  }


}
