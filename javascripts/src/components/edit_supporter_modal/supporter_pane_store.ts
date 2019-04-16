// License: LGPL-3.0-or-later
import * as _ from "lodash";
import { observable, computed, action } from "mobx";
import { SupporterEntity } from "./supporter_entity";

export class SupporterPaneStore {
  constructor(
    private supporterEntity: SupporterEntity
  ) {}

  @observable
  loaded: boolean = false

  @observable
  loadFailure: boolean


  @computed
  get loading(): boolean {
    return !this.loaded
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
      this.loadFailure = true;
    }
  }

  @action.bound
  async init() {
    await this.supporterEntity.loadSupporter()
    await this.supporterEntity.loadAddresses();
  }
}
