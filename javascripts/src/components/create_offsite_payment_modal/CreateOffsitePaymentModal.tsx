// License: LGPL-3.0-or-later
import * as React from 'react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import Modal, { ModalContext } from '../common/modal/Modal';
import { FundraiserInfo } from '../edit_payment_pane/types';
import CreateOffsitePaymentModalChildren from './CreateOffsitePaymentModalChildren';

export interface CreateOffsitePaymentModalProps
{
  events: FundraiserInfo[]
  campaigns: FundraiserInfo[]
  nonprofitId: number
  supporterId:number
  nonprofitTimezone?: string
  preupdateDonationAction:() => void
  postUpdateSuccess: () => void

  //from ModalProps
  onClose: () => void
  modalActive: boolean
}

class CreateOffsitePaymentModal extends React.Component<CreateOffsitePaymentModalProps & InjectedIntlProps, {}> {
  render() {
    return <Modal modalActive={this.props.modalActive} titleText={'Create Offsite Donation'}
      onClose={this.props.onClose} dialogStyle={{ minWidth: '768px', position: 'relative' }} render={(modal: ModalContext) =>
        <CreateOffsitePaymentModalChildren modal={modal} onClose={this.props.onClose}
          events={this.props.events}
          supporterId={this.props.supporterId}
          nonprofitId={this.props.nonprofitId}
          campaigns={this.props.campaigns}
          preupdateDonationAction={this.props.preupdateDonationAction}
          postUpdateSuccess={this.props.postUpdateSuccess}
        />
      } />
  }
}

export default injectIntl(CreateOffsitePaymentModal)



