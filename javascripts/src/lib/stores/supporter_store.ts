// License: LGPL-3.0-or-later
import { observable, computed, action } from "mobx";
import { Supporter, SupporterApi, PutSupporter, Address } from "../../../api";
import _ = require("lodash");
import { ApiManager } from "../api_manager";

export class SupporterStore {

  constructor(private rootStore:{apiManager:ApiManager}){}
  
  @computed get supporterApi():SupporterApi {
    return this.rootStore.apiManager.get(SupporterApi)
  }

  @observable isLoading = false;
  @observable supporterRegistry = observable.map<number, Supporter>();

  @computed get supporters(): ReadonlyArray<Supporter> {
    return new Array(this.supporterRegistry.values())
  }

  @action.bound
  async loadSupporter(id: number, { acceptCached = false } = {}): Promise<Supporter> {
    if (acceptCached) {
      const supporter = this.getSupporter(id)
      if (supporter)
        return supporter
    }
    this.isLoading = true
    try {
      const supporter = await this.supporterApi.getSupporter(id)
      this.supporterRegistry.set(supporter.id, supporter)
      return supporter;
    }
    finally {
      this.isLoading = false
    }
  }

  @action.bound
  async updateSupporter(id: number, supporter: PutSupporter): Promise<Supporter> {
    const updatedSupporter = await this.supporterApi.updateSupporter(id, supporter)
    this.supporterRegistry.set(id, updatedSupporter)
    return updatedSupporter;
  }

  private getSupporter(id: number) {
    return this.supporterRegistry.get(id)
  }
}
