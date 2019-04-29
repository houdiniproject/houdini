// License: LGPL-3.0-or-later
import { action, observable } from "mobx";
import _ = require("lodash");
import { ConfirmationAccessor, Confirmer, Confirmation, ConfirmationDescription, ConfirmationWithPromise } from "./types";

export class ConfirmationManager implements ConfirmationAccessor, Confirmer {

  confirmations = observable.array<Confirmation>();

  async confirm(confirmDescription: ConfirmationDescription): Promise<boolean> {
    let resolver: (value?: boolean | PromiseLike<boolean>) => void;

    let promise = new Promise<boolean>((resolve, reject) => {
      resolver = resolve;
    });
    
    const key = this.addConfirmation({ ...confirmDescription, ...{ onComplete: promise, resolver: resolver } });
    
    //Return promise
    let result = await promise;
    
    return result;
  }

  @action.bound
  private addConfirmation(confirmationDesc: ConfirmationWithPromise): string {
    const key = _.uniqueId();
    this.confirmations.push({ ...confirmationDesc, key: key, isOpen:true });
    return key;
  }
  
  // @action.bound
  // removeConfirmation(key: string) {
  //   const confIndex = this.confirmations.findIndex((i) => i.key === key);
  //   let  confirmation  = this.confirmations[confIndex]
  //   confirmation.isOpen = false;
  //   this.confirmations.splice(confIndex, 1, confirmation)
  // }
}
