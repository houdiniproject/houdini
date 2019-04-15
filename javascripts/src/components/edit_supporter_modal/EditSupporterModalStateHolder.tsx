// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, Provider } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import Modal from '../common/Modal';
import SupporterModalBase, { OnCloseType } from './SupporterModalBase';
import { LocalRootStore } from './local_root_store';
import { RootStore } from '../../lib/stores/root_store';


export interface EditSupporterModalStateHolderProps {
  //from ModalProps
  onClose: OnCloseType
  nonprofitId: number
  supporterId: number
}

class EditSupporterModalStateHolder extends React.Component<EditSupporterModalStateHolderProps, {}> {

  rootStore: RootStore
  localRootStore: LocalRootStore;

  constructor(props: EditSupporterModalStateHolderProps & InjectedIntlProps) {
    super(props)
    this.rootStore = new RootStore()
    this.localRootStore = new LocalRootStore(props.supporterId, this.rootStore)
  }

  render() {
    return <Provider RootStore={this.rootStore}>
      <Provider LocalRootStore={this.localRootStore}>
        <SupporterModalBase nonprofitId={this.props.nonprofitId} supporterId={this.props.supporterId} onClose={this.props.onClose} key={1} />
      </Provider>
    </Provider>
  }
}

export default observer(EditSupporterModalStateHolder)



