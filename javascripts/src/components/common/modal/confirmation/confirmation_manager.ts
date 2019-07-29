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
  public confirmationExited(confirmation: Confirmation){
    this.confirmations.remove(confirmation)
  }


  @action.bound
  private addConfirmation(confirmationDesc: ConfirmationWithPromise): string {
    const key = _.uniqueId();
    this.confirmations.push({ ...confirmationDesc, key: key, isOpen:true });
    return key;
  }
}
