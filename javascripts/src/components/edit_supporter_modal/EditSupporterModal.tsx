// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, Provider } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import Modal from '../common/Modal';
import SupporterPane from './SupporterPane';
import { LocalRootStore } from './local_root_store';
import { RootStore } from '../../lib/stores/root_store';


export interface EditSupporterModalProps {
  //from ModalProps
  onClose: () => void
  modalActive: boolean
  nonprofitId: number
  supporterId: number
}

class EditSupporterModal extends React.Component<EditSupporterModalProps & InjectedIntlProps, {}> {

  rootStore: RootStore
  localRootStore: LocalRootStore;

  constructor(props: EditSupporterModalProps & InjectedIntlProps) {
    super(props)
    this.rootStore = new RootStore()
    this.localRootStore = new LocalRootStore(props.supporterId, this.rootStore)
  }



  render() {
    return <Modal
      modalActive={this.props.modalActive}
      titleText={'Edit Supporter'}
      focusDialog={true}
      onClose={this.props.onClose}
      dialogStyle={{ minWidth: '768px', position: 'relative' }}
      childGenerator={() => {
        return <Provider RootStore={this.rootStore}>
          <Provider LocalRootStore={this.localRootStore}>
            <SupporterPane nonprofitId={this.props.nonprofitId} supporterId={this.props.supporterId} onClose={this.props.onClose} key={1} />
          </Provider>
        </Provider>
      }}>
    </Modal>
  }
}

export default injectIntl(observer(EditSupporterModal))



