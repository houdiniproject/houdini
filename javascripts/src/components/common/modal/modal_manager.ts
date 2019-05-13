// License: LGPL-3.0-or-later
import { action, computed, observable } from "mobx";
import _ = require("lodash");

export interface ModalManagerInterface {
  top: string
  push(key: string): void
  remove(key: string): void
}

export class ModalManager implements ModalManagerInterface {
  @observable
  modals = observable.array<string>()

  @computed
  get top(): string | undefined {
    return _.last(this.modals)
  }

  @action.bound
  push(key: string) {
    this.modals.push(key)
  }

  @action.bound
  remove(key: string) {
    this.modals.remove(key)
  }
}