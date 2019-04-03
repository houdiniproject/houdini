// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import SelectableTableRow from '../common/SelectableTableRow';
import Star from '../common/icons/Star';
import Button from '../common/form/Button';
import { computed } from 'mobx';
import AddressPane from './AddressPane';
import { TwoColumnFields } from '../common/layout';
import { BasicField } from '../common/fields';
import FailedToLoad from './FailedToLoad';
import Spinner from '../common/Spinner';
import { isFilled } from '../../lib/utils';
import { SupporterAddressStore } from './supporter_address_store';
import { SupporterPaneStore } from './supporter_pane_store';
import { LocalRootStore } from './local_root_store';

export interface SupporterPaneProps {
  nonprofitId: number
  supporterId: number
  onClose: () => void
  LocalRootStore?: LocalRootStore
}
class SupporterPane extends React.Component<SupporterPaneProps & InjectedIntlProps, {}> {

  constructor(props: SupporterPaneProps & InjectedIntlProps) {
    super(props)
  }

  @computed get supporterAddressStore(): SupporterAddressStore {
    return this.props.LocalRootStore.supporterAddressStore;
  }

  @computed get supporterPaneStore(): SupporterPaneStore {
    return this.props.LocalRootStore.supporterPaneStore;
  }

  async componentDidMount() {
    await this.supporterPaneStore.attemptInit()
  }

  render() {
    let pane;

    if (this.supporterPaneStore.loadFailure)
      pane = <FailedToLoad />
    else if (this.supporterPaneStore.editingAddress) {
      pane = <AddressPane
        onClose={this.supporterPaneStore.handleAddressAction}
        initialAddress={this.supporterPaneStore.addressToEdit}
        isDefault={this.supporterPaneStore.isSelectedAddressDefault} />
    }
    else if (!this.supporterPaneStore.loading) {
      pane = <form>
        <TwoColumnFields>
          <BasicField field={this.supporterPaneStore.form.$('name')} label={"Name"} />
          <BasicField field={this.supporterPaneStore.form.$('email')} label={"Email"} />

        </TwoColumnFields>
        <TwoColumnFields>
          <BasicField field={this.supporterPaneStore.form.$('phone')} label={"Phone"} />
          <BasicField field={this.supporterPaneStore.form.$('organization')} label={"Organization"} />
        </TwoColumnFields>

        <input {...this.supporterPaneStore.form.$('defaultAddressId').bind()} />

        {this.supporterAddressStore.addresses ?
          <table className={"clickable table--plaid"}>
            <thead>
              <tr>
                <th>Address</th>
                <th style={{ textAlign: 'center' }}>Default?</th>
              </tr>
            </thead>


            <tbody style={{ fontSize: '14px' }}>
              {this.supporterAddressStore.addresses.map((a) => {
                const address = [a.address, a.city, a.state_code, a.zip_code, a.country].filter((i) => isFilled(i)).join(", ")
                return <SelectableTableRow onSelect={() => this.supporterPaneStore.editAddress(a)} key={a.id}>
                  <td>{address}</td>
                  <td style={{ textAlign: "center" }}>{this.supporterPaneStore.isDefaultAddress(a.id) ? <Star /> : false}</td>
                </SelectableTableRow>
              })
              }

              <SelectableTableRow onSelect={this.supporterPaneStore.addAddress}>
                <td><Button onClick={this.supporterPaneStore.addAddress} buttonSize="tiny">Add Address</Button></td>
              </SelectableTableRow>
            </tbody>
          </table> : false}

        <Button type={'button'} onClick={this.props.onClose}>Close</Button>


        <Button type={'submit'}
          onClick={this.supporterPaneStore.form.onSubmit} >Save</Button>
      </form>
    }

    else {
      pane = <Spinner size="normal">Loading...</Spinner>
    }

    return <div className={"tw-bs"}>
      {pane}
    </div>
  }
}

export default injectIntl(inject('LocalRootStore')(observer(SupporterPane)))



