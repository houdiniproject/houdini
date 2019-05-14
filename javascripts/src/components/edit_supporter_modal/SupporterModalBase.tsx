// License: LGPL-3.0-or-later
import { boundMethod } from 'autobind-decorator';
import { FormikActions } from 'formik';
import { computed } from 'mobx';
import { inject, observer } from 'mobx-react';
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { PutSupporter, Supporter, TimeoutError, ValidationErrorsException } from '../../../api';
import BootstrapWrapper from '../common/BootstrapWrapper';
import { FormikHelpers, HoudiniFormikServerStatus } from '../common/HoudiniFormik';
import Spinner from '../common/Spinner';
import { SupporterModalState } from './EditSupporterModal';
import FailedToLoad from './FailedToLoad';
import LoadedPaneFormik from './LoadedPaneFormik';
import { LocalRootStore } from './local_root_store';
import { SupporterEntity, toFormSupporter } from './supporter_entity';
import { SupporterPaneStore } from './supporter_pane_store';
import * as yup from 'yup'

export type OnCloseType = (supporterId?:number) => void

export interface SupporterModalBaseProps {
  nonprofitId: number
  supporterId: number
  onClose: OnCloseType
  LocalRootStore?: LocalRootStore
  supporterModalState:SupporterModalState
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

export function createYup({name, organization, email, phone}: {name:string, organization:string, email:string, phone: string})  {
  return yup.object().shape({
    id: yup.number().required(),
    name: yup.string().label(name),
    organization: yup.string().label(organization),
    email: yup.string().email().label(email),
    phone: yup.string().label(phone),
    default_address: yup.mixed().transform((value:any) => {
      if (typeof value === 'string'){
        return undefined
      }
      else if (typeof value === 'object' && !value.id) {
        return undefined;
      }
      else
        return value
    })
  })
}
class SupporterModalBase extends React.Component<SupporterModalBaseProps & InjectedIntlProps, {}> {

  @computed get supporterAddressStore(): SupporterEntity {
    return this.props.LocalRootStore.supporterEntity;
  }

  @computed get supporterPaneStore(): SupporterPaneStore {
    return this.props.LocalRootStore.supporterPaneStore;
  }

  async componentDidMount() {
    await this.supporterPaneStore.attemptInit()
  }

  @boundMethod
  async onSubmit(values:Supporter, action:FormikActions<Supporter>, schema:ReturnType<typeof createYup>){
    await onSubmit(schema.cast(values), action, this.supporterAddressStore.updateSupporter, this.props.onClose)
  }

  @boundMethod
  async innerOnSubmit(values:Supporter, action:FormikActions<Supporter>) {
    return this.onSubmit(values, action, this.schema)
  }


  schema = createYup({name: 'Name', organization: "Organization", email: "Email", phone: "Phone"})

  render() {
    let pane;

    if (this.supporterPaneStore.loadFailure)
      pane = <FailedToLoad />
    else if (!this.supporterPaneStore.loading) {
      const addresses = this.supporterAddressStore.addresses
      
      pane = <LoadedPaneFormik
       addresses={addresses}
        initialValues={toFormSupporter(this.supporterAddressStore.supporter)}
        onClose={this.props.onClose}
        onSubmit={this.innerOnSubmit}
        supporterId={this.props.supporterId} supporterModalState={this.props.supporterModalState} validationSchema={this.schema}/>
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



