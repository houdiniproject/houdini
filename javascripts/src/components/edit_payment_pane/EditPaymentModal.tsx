// License: LGPL-3.0-or-later
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import Modal, { ModalContext } from '../common/modal/Modal';
import { PaymentData, FundraiserInfo } from './types';
import EditPaymentModalChildren from './EditPaymentModalChildren';

export interface EditPaymentModalProps {
  data: PaymentData
  events: FundraiserInfo[]
  campaigns: FundraiserInfo[]

  nonprofitTimezone?: string
  preupdateDonationAction: () => void
  postUpdateSuccess: () => void

  //from ModalProps
  onClose: () => void
  modalActive: boolean
}

class EditPaymentModal extends React.Component<EditPaymentModalProps & InjectedIntlProps, {}> {
  render() {
    return <Modal modalActive={this.props.modalActive} titleText={'Edit Donation'}
      onClose={this.props.onClose} dialogStyle={{ minWidth: '768px', position: 'relative' }} render={(modal: ModalContext) =>
        <EditPaymentModalChildren modal={modal} onClose={this.props.onClose}
          data={this.props.data} events={this.props.events}
          campaigns={this.props.campaigns}
          preupdateDonationAction={this.props.preupdateDonationAction}
          postUpdateSuccess={this.props.postUpdateSuccess}
        />
      } />
  }
}

export default injectIntl(EditPaymentModal)



