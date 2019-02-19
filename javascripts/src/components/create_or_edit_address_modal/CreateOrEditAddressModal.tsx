// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import Modal from '../common/Modal';
import { TwoColumnFields } from '../common/layout';
import { BasicField } from '../common/fields';
import { observable, action } from 'mobx';
import { Address } from '../../../api/model/Address';

export interface CreateOrEditAddressModalProps {
  //from ModalProps
  onClose: () => void
  modalActive: boolean
}

class CreateOrEditAddressModal extends React.Component<CreateOrEditAddressModalProps & InjectedIntlProps, {}> {

  @observable
  addresses:Array<Address>

  render() {

    let coverpane = this.selectedAddress ? <div style={{
      position:'absolute',
      width: '100%',
      height: '100%',
      right:'0px',
      top:'0px'
    }}>
      <button onClick={this.closePane}>Close</button>
      {this.selectedAddress.address}
      {this.selectedAddress.city}
      {this.selectedAddress.state_code}
      {this.selectedAddress.zip_code}
      {this.selectedAddress.country}

      <button>Save</button>
      <button>Set as default</button>
      <button>Delete</button>
    </div> : false
    return <Modal modalActive={this.props.modalActive} titleText={'Create Offsite Donation'} focusDialog={true}
      onClose={this.props.onClose} dialogStyle={{ minWidth: '768px' }} childGenerator={() => {
        return <div className={"tw-bs"}>
          {coverpane}
          <form className='u-marginTop--20'>
            <TwoColumnFields>
              <BasicField field={'name'} />
              <BasicField field={'email'} />
              <BasicField field={'phone'} />
              <BasicField field={'organization'} />
            </TwoColumnFields>

            <hr />

          </form>
        </div>
      }}>
    </Modal>
  }
}

export default injectIntl(observer(CreateOrEditAddressModal))



