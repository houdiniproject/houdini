// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import * as _ from 'lodash';
import { Address } from '../../../api';
import { BasicField } from '../common/fields';
import ReactCheckbox from '../common/form/ReactCheckbox';
import FormNotificationBlock from '../common/form/FormNotificationBlock';
import Button from '../common/form/Button';
import { TwoColumnFields } from '../common/layout';
import { LocalRootStore } from './local_root_store';
import { AddressPaneState } from './address_pane_state';

export interface AddressAction {
  type: 'none' | 'delete' | 'add' | 'update'
  address?: Address
  setToDefault?: boolean
}

export interface AddressPaneProps {
  initialAddress: Address
  isDefault?: boolean
  onClose?: (action: AddressAction) => void
  LocalRootStore?: LocalRootStore
}

export interface FormOutput {
  address?: string
  city?: string
  state_code?: string
  zip_code?: string
  country?: string
}

export interface ServerErrorInput {
  address?: Array<string>
  city?: Array<string>
  state_code?: Array<string>
  zip_code?: Array<string>
  country?: Array<string>
}

class AddressPane extends React.Component<AddressPaneProps & InjectedIntlProps, {}> {


  constructor(props: AddressPaneProps & InjectedIntlProps) {
    super(props)
    this.addressPaneState = new AddressPaneState(props.initialAddress, props.isDefault, props.LocalRootStore, props.onClose)
  }

  addressPaneState: AddressPaneState

  render() {
    return <div>
      <div>
        <form>
          <TwoColumnFields>
            <BasicField field={this.addressPaneState.form.$('address')} label={"Address"} />
            <BasicField field={this.addressPaneState.form.$('city')} label={"City"} />
          </TwoColumnFields>
          <TwoColumnFields>
            <BasicField field={this.addressPaneState.form.$('state_code')} label={"State Code/Region"} />
            <BasicField field={this.addressPaneState.form.$('zip_code')} label={"Postal/Zip Code"} />
          </TwoColumnFields>
          <TwoColumnFields>
            <BasicField field={this.addressPaneState.form.$('country')} label={"Country"} />
          </TwoColumnFields>
          <ReactCheckbox field={this.addressPaneState.form.$('is_default')} label={"Set as Default Address"} />

          {this.addressPaneState.form.serverError ? <FormNotificationBlock
            message={this.addressPaneState.form.serverError} /> : ""}
        </form>
      </div>
      <div>

        <Button onClick={() => this.addressPaneState.close({ type: 'none' })}>Close</Button>
        {this.addressPaneState.shouldAdd ?
          <>
            <Button onClick={this.addressPaneState.form.onSubmit} disabled={!this.addressPaneState.modifiedEnoughToSubmit} type="submit">Add</Button>
          </> :
          <>
            <Button onClick={this.addressPaneState.form.onSubmit} disabled={!this.addressPaneState.modifiedEnoughToSubmit} type="submit">Save</Button>
            <Button onClick={this.addressPaneState.delete}>Delete</Button>
          </>
        }
      </div>
    </div>
  }
}

export default injectIntl(inject('LocalRootStore')(observer(AddressPane)))



