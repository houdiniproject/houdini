// License: LGPL-3.0-or-later
import * as React from 'react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import ModalBody from '../common/modal/ModalBody';
import ModalFooter from '../common/modal/ModalFooter';
import Button from '../common/form/Button';
import { ModalContext } from '../common/modal/Modal';
import { boundMethod } from 'autobind-decorator';
import EditPaymentFormik from './EditPaymentFormik';
import { PaymentData, FundraiserInfo } from './types';

export interface EditPaymentModalChildrenProps
{
  modal:ModalContext
  onClose:() => void

  data: PaymentData
  events: FundraiserInfo[]
  campaigns: FundraiserInfo[]
  nonprofitTimezone?: string
  preupdateDonationAction: () => void
  postUpdateSuccess: () => void
}

interface EditPaymentModalChildrenState {

  disableSave?:boolean
  disableClose?:boolean
  closeAction?:()=> void
  formId?:string
}

export interface EditPaymentModalController extends EditPaymentModalChildrenState {
  setCanClose: (canClose:() => boolean|Promise<boolean>) => void
  setFormId: (formId:string) => void
  setDisableSave: (disableSave:boolean) => void
  setDisableClose: (disableClose:boolean) => void
}

class EditPaymentModalChildren extends React.Component<EditPaymentModalChildrenProps & 
InjectedIntlProps, EditPaymentModalChildrenState> {
  constructor(props:EditPaymentModalChildrenProps & 
    InjectedIntlProps) {
      super(props)
      this.state = this.initializeState()
  }

  private initializeState(): EditPaymentModalChildrenState {
    return {
      disableSave:false,
      disableClose:false,
      formId:null
    }
  }

  @boundMethod
  cancel() {
    this.props.modal.cancel()
  }

  componentDidMount() {
    this.props.modal.setHandleCancel(() => this.props.onClose())
  }

  componentDidUpdate() {
    this.props.modal.setHandleCancel(() => this.props.onClose())
  }

  createModalController() : EditPaymentModalController {
    return {...this.state,
      setCanClose: (canClose:() => boolean|Promise<boolean>) => this.props.modal.setCanClose(canClose),
      setFormId: (formId:string) => this.setState({formId}),
      setDisableSave: (disableSave:boolean) => this.setState({disableSave}),
      setDisableClose: (disableClose:boolean) => this.setState({disableClose})
    }
  }

  render() {
    const controller = this.createModalController()
     return <>
     <ModalBody>
        <EditPaymentFormik data={this.props.data} campaigns={this.props.campaigns} events={this.props.events}preupdateDonationAction={this.props.preupdateDonationAction} postUpdateSuccess={this.props.postUpdateSuccess} editPaymentModalController={controller}  onClose={this.props.onClose}/>
     </ModalBody>
     <ModalFooter>
       <Button type="button" onClick={this.cancel} disabled={this.state.disableClose}>
         Close
       </Button>
       <Button type="submit"
         disabled={this.state.disableSave} form={this.state.formId}>Save
       </Button>
     </ModalFooter>
   </>;
  }
}

export default injectIntl(EditPaymentModalChildren)



