// License: LGPL-3.0-or-later
import React = require("react");
import { observable, IObservableArray, action } from "mobx";
import _ = require("lodash");
import { observer } from "mobx-react";
import { boundMethod } from "autobind-decorator";
import Modal from "./Modal";
import Button from "./form/Button";

interface ConfirmationDescription {
  titleText:string
  confirmationText:string
  confirmButtonText:string
  abortButtonText:string
}

interface ConfirmationWithPromise extends ConfirmationDescription{
  onComplete:Promise<boolean>
  resolver: (value?: boolean | PromiseLike<boolean>) => void
}

interface Confirmation extends ConfirmationWithPromise {
  key:string
  
}

interface ConfirmationAccessor {
  confirmations:IObservableArray<Confirmation>
}

export interface Confirmer {
  confirm(confirmDescription: ConfirmationDescription):Promise<boolean>
}

export class ConfirmationManager implements ConfirmationAccessor, Confirmer {
  confirmations = observable.array<Confirmation>()

  async confirm(confirmDescription: ConfirmationDescription): Promise<boolean> {
    //create new Promise

    let resolver : (value?: boolean | PromiseLike<boolean>) => void
    let promise  = new Promise<boolean>(( resolve, reject) => {
      resolver = resolve;
    })
    
    const key = this.addConfirmation({...confirmDescription, ...{onComplete: promise, resolver: resolver}})

    //Return promise
    let result = await promise;

    this.removeConfirmation(key)
    return result
  }

  @action.bound
  private addConfirmation(confirmationDesc:ConfirmationWithPromise) :string {
    const key = _.uniqueId()
    this.confirmations.push({...confirmationDesc, key: key})
    return key

  }

  @action.bound
  removeConfirmation(key:string){
    const confItem = this.confirmations.find((i) => i.key === key)

    this.confirmations.remove(confItem)
  }
}

interface ConfirmationWrapperProps{
  confirmationAccessor: ConfirmationAccessor
}

@observer
export class ConfirmationWrapper extends React.Component<ConfirmationWrapperProps, {}> {
  render() {
    return this.props.confirmationAccessor.confirmations.map((i) => {
      return <ConfirmationModal confirmation={i} key={i.key}/>
      }
    )
    
  }
}

interface ConfirmationModalProps{
  confirmation:ConfirmationWithPromise
}

@observer
export class ConfirmationModal extends React.Component<ConfirmationModalProps, {}> {
  @observable modalActive:boolean = true
  @action.bound
  confirm(){
    this.modalActive = false
    this.props.confirmation.resolver(true)
  }

  @action.bound
  abort() {
    this.modalActive = false
    this.props.confirmation.resolver(false)
  }

  render() {
    return <Modal titleText={this.props.confirmation.titleText} showCloseButton={false} escapeExits={false} alert={true} underlayClickExits={false} modalActive={this.modalActive}
    buttons={[<Button onClick={this.confirm}>
      {this.props.confirmation.confirmButtonText}
    </Button>,
    <Button onClick={this.abort}>{this.props.confirmation.abortButtonText}</Button>]}  childGenerator={() => {
      {this.props.confirmation.confirmationText}
    }}/>
  }
}











