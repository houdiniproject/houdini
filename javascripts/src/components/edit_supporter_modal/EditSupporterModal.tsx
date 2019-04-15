// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, Provider } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import Modal from '../common/Modal';
import SupporterModalBase, { OnCloseType } from './SupporterModalBase';
import { LocalRootStore } from './local_root_store';
import { RootStore } from '../../lib/stores/root_store';
import EditSupporterModalStateHolder from './EditSupporterModalStateHolder';
import { tsParenthesizedType } from '@babel/types';


export interface EditSupporterModalProps {
  //from ModalProps
  onClose: OnCloseType
  modalActive: boolean
  nonprofitId: number
  supporterId: number
}

class EditSupporterModal extends React.Component<EditSupporterModalProps & InjectedIntlProps, {}> {

  render() {
    return <Modal
      modalActive={this.props.modalActive}
      titleText={'Edit Supporter'}
      focusDialog={true}
      onClose={this.props.onClose}
      dialogStyle={{ minWidth: '768px', position: 'relative' }}
      childGenerator={() => {
        return <EditSupporterModalStateHolder nonprofitId={this.props.nonprofitId} supporterId={this.props.supporterId}
        onClose={this.props.onClose}  />  
      }}>
    </Modal>
  }
}

export default injectIntl(observer(EditSupporterModal))



