// License: LGPL-3.0-or-later
import { observer } from 'mobx-react';
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import Modal from '../common/modal/Modal';
import EditSupporterModalStateHolder from './EditSupporterModalStateHolder';
import { OnCloseType } from './SupporterModalBase';


export interface EditSupporterModalProps {
  //from ModalProps
  onClose: OnCloseType
  modalActive: boolean
  nonprofitId: number
  supporterId: number
}

class EditSupporterModal extends React.Component<EditSupporterModalProps & InjectedIntlProps, {}> {

  render() {
    const children = {
      body: <EditSupporterModalStateHolder nonprofitId={this.props.nonprofitId} supporterId={this.props.supporterId}
      onClose={this.props.onClose}  /> 
    }

    return <Modal
      modalActive={this.props.modalActive}
      titleText={'Edit Supporter'}
      focusDialog={true}
      onClose={this.props.onClose}
      dialogStyle={{ minWidth: '768px', position: 'relative' }}
      >{children}
    </Modal>
  }
}

export default injectIntl(observer(EditSupporterModal))



