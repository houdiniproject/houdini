// License: LGPL-3.0-or-later
import { action, observable, computed } from "mobx";
import { Supporter, Address, PutSupporter } from "../../../api";
import { AddressAction } from "./AddressPane";
import * as _  from "lodash"
import { ApiManager } from "../../lib/api_manager";
import { SupporterApi } from "../../../api/api/api";
import { updateLocale } from "moment";

// TODO: we only get the first 100 addresses. We will get more in the future (probably with rxjs) but seriously, you shouldn't have that many
const PageLength = 100

export class SupporterAddressController
{
  constructor(supporterId:number, ApiManager:ApiManager) {
    this.supporterId = supporterId
    this.SupporterApi = ApiManager.get(SupporterApi)
  }
  
  supporterId:number
  SupporterApi: SupporterApi
  
  @observable
  supporter:Supporter 

  public async init() {
    await this.load() 
    await this.loadAddresses()
  }

  @observable 
  loadingCount:number = 0
  
  @observable 
  savingCount:number = 0

  @observable
  addresses:Array<Address>
  

  @computed
  get defaultAddressId() : number {
    return this.supporter 
      && this.supporter.default_address 
      && this.supporter.default_address.id
  }
  
  @computed
  get loading():boolean {
    return this.loadingCount > 0;
  }
  
  @computed
  get saving():boolean {
    return this.savingCount > 0;
  }

  isDefaultAddress(address:Address):boolean {
    return address.id && address.id === this.defaultAddressId
  }

  @action.bound
  async handleAddressAction(action:AddressAction)
  {
    switch(action.type) {
      case 'add':
        await this.handleAddedAddress(action)
        break;
      case 'delete':
       await  this.handleDeletedAddress(action)
        break;
      case 'update':
        await this.handleUpdatedAddress(action)
        break;
      case 'none':
        break;
    }
  }

  async updateSupporter(supporter:PutSupporter) {
    
     await this.update(supporter)

  }

  @action.bound
  private async load(){
   try {
    this.loadingCount++
    this.supporter = await this.SupporterApi.getSupporter(this.supporterId)
   }
   finally {
    this.loadingCount--
   }
  }

  
  @action.bound
  private async loadAddresses()  {
    try {
      this.loadingCount++
      const addresses = await this.SupporterApi.getCrmAddresses(this.supporterId, 'CRM', PageLength)

      this.addresses = addresses.addresses
    }
    finally {
      this.loadingCount--;
    }
  }

  @action.bound
  private async handleAddedAddress(action:AddressAction) {
    this.addresses.push(action.address)
    if (action.setToDefault){
      this.supporter.default_address = {id: action.address.id}
      await this.update(this.supporter as PutSupporter)
    }
    else {
      await this.load()
    }
  }

  @action.bound
  private async handleDeletedAddress(action:AddressAction) {
    _.remove(this.addresses, (a) => a.id === action.address.id)
    await this.load()
 
  }

  @action.bound
  private async handleUpdatedAddress(action:AddressAction) {
    const index = _.findIndex(this.addresses, (a) => a.id === action.address.id)
    this.addresses.splice(index, 1, action.address)
    if (action.setToDefault){
      this.supporter.default_address = {id: action.address.id}
      try {
        this.savingCount++;
        await this.update(this.supporter as PutSupporter)
      }
      finally { 
        this.savingCount--;
      }
    }
    else {
      await this.load()
    }
    
  }

  @action.bound
  private async update(s:PutSupporter){
    try {
      this.savingCount++;
      this.supporter = await this.SupporterApi.updateSupporter(this.supporterId, s)
    }
    finally {
      this.savingCount--;
    }
  }
  
}