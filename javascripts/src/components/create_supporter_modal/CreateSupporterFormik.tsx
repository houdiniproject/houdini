// License: LGPL-3.0-or-later
import { boundMethod } from 'autobind-decorator';
import { FormikActions } from 'formik';
import { action, computed, observable } from 'mobx';
import { observer } from 'mobx-react';
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import * as yup from 'yup';
import { Address, PostSupporterSupporterIdAddress, Supporter, TimeoutError, ValidationErrorsException } from '../../../api';
import { CreateSupporter, CreateSupporterModel } from '../../lib/api/create_supporter';
import { ApiManager } from '../../lib/api_manager';
import { AddressStore } from '../../lib/stores/address_store';
import HoudiniFormik, { FormikHelpers, HoudiniFormikServerStatus } from '../common/HoudiniFormik';
import { ModalContext } from '../common/modal/Modal';
import { OnCloseType } from '../edit_supporter_modal/SupporterModalBase';
import { SupporterModalState } from './CreateSupporterModal';
import CreateSupporterPane from './CreateSupporterPane';
import _ = require('lodash');
import { RootStore } from '../../lib/stores/root_store';
import { isEmpty } from 'lodash';

export const validationSchema = yup.object()

type InitialValuesType = any

const initialValues: InitialValuesType = {
  name: "",
  email: "",
  organization: "",
  phone: "",
  address: "",
  state_code: "",
  zip_code: "",
  city: "",
  country: ""
}

const filterToSupporterValues = (values: InitialValuesType) => {
  return _.pick(values, ['name', 'email', 'organization', 'phone'])
}

const filterToAddressValues = (values: InitialValuesType) => {
  return _.pick(values, ['address', 'state_code', 'zip_code', 'city', 'country'])
}

/**
 * Describes the current state of the submission
 * @enum {number}
 */
export enum SubmitPhase {
  /**
   * We haven't created the supporter yet even
   */
  HAVE_NOTHING,
  /**
   * We've created the supporter but we haven't created the address
   */
  HAVE_SUPPORTER,
  
  /**
   * We've created the supporter and address. We're done!
   */
  HAVE_SUPPORTER_AND_ADDRESS
}

export async function onSubmit(
  values: any,
  action: FormikActions<any>,
  createSupporter: (supporter: any) => Promise<{ id: number }>,
  addAddress: (supporterId: number, address: PostSupporterSupporterIdAddress) => Promise<Address>,
  createSupporterFormikState: CreateSupporterFormikState,
  onClose: OnCloseType
) {
  let status: HoudiniFormikServerStatus<Supporter> = {}
  try {
    if (createSupporterFormikState.phase === SubmitPhase.HAVE_NOTHING) {
      //we create our supporter
      const supporter = await createSupporter(filterToSupporterValues(values))
      createSupporterFormikState.setSupporter(supporter)
      createSupporterFormikState.setPhase(SubmitPhase.HAVE_SUPPORTER)
    }
    if (createSupporterFormikState.phase === SubmitPhase.HAVE_SUPPORTER) {
      const supporter = createSupporterFormikState.supporter
      //supporter is set
      const addressValues = filterToAddressValues(values)
      if (_.some(['address', 'city', 'state_code', 'zip_code', 'country'], (i) => {!isEmpty(_.get(addressValues, i))})) {
        const address = await addAddress(supporter.id, filterToAddressValues(values))
      }
      action.setStatus({})
      createSupporterFormikState.setPhase(SubmitPhase.HAVE_SUPPORTER_AND_ADDRESS)
      //we can close(s.id)
      onClose(supporter.id)
    }
  }
  catch (e) {
    if (createSupporterFormikState.phase == SubmitPhase.HAVE_NOTHING){
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
    else if (createSupporterFormikState.phase == SubmitPhase.HAVE_SUPPORTER){
      if (e instanceof TimeoutError) {
        status.form = <>We've already saved your supporter but weren't able to save your address<br/><br/>The website couldn't be contacted. Make sure you're connected to the internet and try again in a few seconds.</>
      }
      else {
        if (e instanceof ValidationErrorsException) {
          status.fields = FormikHelpers.convertServerValidationToFieldStatus(e)
        }
  
        status.form = e['error']
      }
    }
    
    action.setStatus(status) 
  }
}
export interface CreateSupporterFormikProps {
  supporterModalState: SupporterModalState
  nonprofitId: number
  onClose: OnCloseType
  modal: ModalContext
  rootStore: RootStore
}

export class CreateSupporterFormikState {

  @observable
  private innerSupporter: Supporter

  @computed get supporter(): Supporter {
    return this.innerSupporter;
  }

  @action.bound
  setSupporter(supporter: Supporter) {
    this.innerSupporter = supporter;
  }

  @observable
  private innerPhase: SubmitPhase = SubmitPhase.HAVE_NOTHING

  @computed get phase(): SubmitPhase {
    return this.innerPhase;
  }

  @action.bound
  setPhase(phase: SubmitPhase) {
    this.innerPhase = phase;
  }
}


class CreateSupporterFormik extends React.Component<CreateSupporterFormikProps & InjectedIntlProps, {}> {

  createSupporterFormikState = new CreateSupporterFormikState()

  @boundMethod
  async addAddress(supporterId:number, 
    address:PostSupporterSupporterIdAddress ): Promise<Address>
  {
    return this.props.rootStore.addressStore.createCrmAddress(supporterId, address);
  }

  @boundMethod
  async createSupporter(supporterModel:CreateSupporterModel){
    const supporter = await this.props.rootStore.apiManager.get(CreateSupporter).createSupporter(supporterModel, this.props.nonprofitId)
    return supporter
  }

  @boundMethod
  async onSubmit(values: any, action: FormikActions<any>) {
    await onSubmit(values, action, this.createSupporter, this.addAddress, this.createSupporterFormikState, this.props.onClose)
  }

  render() {
    return <HoudiniFormik initialValues={{}} onSubmit={this.onSubmit} validationSchema={validationSchema} render={(props) => {
      return <CreateSupporterPane formik={props} supporterModalState={this.props.supporterModalState} modal={this.props.modal} createSupporterFormikState={this.createSupporterFormikState} onClose={this.props.onClose}/>
    }} />;
  }
}

export default injectIntl(observer(CreateSupporterFormik))



