// License: LGPL-3.0-or-later
import { IObservableArray } from "mobx";

export interface ConfirmationDescription {
  titleText: string
  confirmationText: string
  confirmButtonText: string
  abortButtonText: string
}

export interface ConfirmationWithPromise extends ConfirmationDescription {
  onComplete: Promise<boolean>
  resolver: (value?: boolean | PromiseLike<boolean>) => void
}

export interface Confirmation extends ConfirmationWithPromise {
  key: string
  isOpen: boolean
}

export interface ConfirmationAccessor {
  confirmations: IObservableArray<Confirmation>
}

export interface Confirmer {
  confirm(confirmDescription: ConfirmationDescription): Promise<boolean>
}

export interface ConfirmationWrapperProps {
  confirmationAccessor: ConfirmationAccessor
}

export interface ConfirmationModalProps {
  confirmation: ConfirmationWithPromise
}


