// License: LGPL-3.0-or-later
import { FormikActions } from 'formik';
import { action, computed } from 'mobx';
import { inject, observer } from 'mobx-react';
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { PutSupporter, Supporter, TimeoutError, ValidationErrorsException } from '../../../api';
import BootstrapWrapper from '../common/BootstrapWrapper';
import { FormikHelpers, HoudiniFormikServerStatus } from '../common/HoudiniFormik';
import Spinner from '../common/Spinner';
import FailedToLoad from './FailedToLoad';
import LoadedPaneFormik from './LoadedPaneFormik';
import { LocalRootStore } from './local_root_store';
import { SupporterEntity } from './supporter_entity';
import { SupporterPaneStore } from './supporter_pane_store';
import {boundMethod} from 'autobind-decorator'

export type OnCloseType = (supporterId?:number) => void

export interface SupporterModalBaseProps {
  nonprofitId: number
  supporterId: number
  onClose: OnCloseType
  LocalRootStore?: LocalRootStore
}


export async function onSubmit(
    values:Supporter, 
    action:FormikActions<Supporter>, 
    updateSupporter:(supporter: PutSupporter|Supporter) => Promise<Supporter>, onClose:OnCloseType
  ){
  let status: HoudiniFormikServerStatus<Supporter> = {}
  try {
    const s = await updateSupporter(values)
    action.setStatus({})
    onClose(s.id)
  }
  catch(e) {
    if (e instanceof TimeoutError) {
      status.form = "The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds."
    }
    else {
      if (e instanceof ValidationErrorsException) {
        status.fields = FormikHelpers.convertServerValidationToFieldStatus(e)
      }

      status.form = e['error']
    }

    action.setStatus(status)
  }
}


class SupporterModalBase extends React.Component<SupporterModalBaseProps & InjectedIntlProps, {}> {

  @computed get supporterAddressStore(): SupporterEntity {
    return this.props.LocalRootStore.supporterAddressStore;
  }

  @computed get supporterPaneStore(): SupporterPaneStore {
    return this.props.LocalRootStore.supporterPaneStore;
  }

  async componentDidMount() {
    await this.supporterPaneStore.attemptInit()
  }

  @boundMethod
  async onSubmit(values:Supporter, action:FormikActions<Supporter>){
    await onSubmit(values, action, this.supporterAddressStore.updateSupporter, this.props.onClose)
  }

  render() {
    let pane;

    if (this.supporterPaneStore.loadFailure)
      pane = <FailedToLoad />
    else if (!this.supporterPaneStore.loading) {
      const addresses = this.supporterAddressStore.addresses
      pane = <LoadedPaneFormik
       addresses={addresses}
        initialValues={this.supporterAddressStore.supporter}
        onClose={this.props.onClose}
        onSubmit={this.onSubmit}
        supporterId={this.props.supporterId}/>
    }
    else {
      pane = <Spinner size="normal">Loading...</Spinner>
    }

    return <BootstrapWrapper>
      {pane}
    </BootstrapWrapper>
  }
}

export default injectIntl(inject('LocalRootStore')(observer(SupporterModalBase)))



