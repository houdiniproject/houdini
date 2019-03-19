// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, Provider } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import Modal from '../common/Modal';
import SupporterPane from './SupporterPane';
import { ApiManager } from '../../lib/api_manager';
import { CSRFInterceptor } from '../../lib/csrf_interceptor';
import { APIS } from '../../../api/api/api';
import { SupporterAddressController } from './supporter_address_controller';


export interface EditSupporterModalProps {
  //from ModalProps
  onClose: () => void
  modalActive: boolean
  nonprofitId: number
  supporterId: number
}



class EditSupporterModal extends React.Component<EditSupporterModalProps & InjectedIntlProps, {}> {
  apiManager: ApiManager
  controller:SupporterAddressController
  constructor(props:EditSupporterModalProps & InjectedIntlProps){
    super(props)
    this.apiManager = new ApiManager(APIS, CSRFInterceptor)
    this.controller = new SupporterAddressController(props.supporterId, this.apiManager)
  }

  
  
  render() {
    return <Modal
      modalActive={this.props.modalActive}
      titleText={'Edit Supporter'}
      focusDialog={true}
      onClose={this.props.onClose}
      dialogStyle={{ minWidth: '768px', position: 'relative' }}
      childGenerator={() => {
        return <Provider ApiManager={this.apiManager}><SupporterPane nonprofitId={this.props.nonprofitId} supporterId={this.props.supporterId} onSave={this.props.onClose} key={1} SupporterAddressController={this.controller}/>
        </Provider>
      }}>
    </Modal>
  }
}

export default injectIntl(observer(EditSupporterModal))



