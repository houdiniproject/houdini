// License: LGPL-3.0-or-later
import { FormikActions } from 'formik';
import { observer, disposeOnUnmount } from 'mobx-react';
import * as React from 'react';
import { Address, Supporter } from '../../../api';
import HoudiniFormik from '../common/HoudiniFormik';
import LoadedPane from './LoadedPane';
import _ = require('lodash');
import { OnCloseType, createYup } from './SupporterModalBase';
import { SupporterModalState } from './EditSupporterModal';
import * as yup from 'yup';
import { injectIntl, InjectedIntlProps } from 'react-intl';




export interface LoadedPaneProps {
  supporterId: number
  initialValues: Supporter
  addresses: Address[]
  onSubmit: (values: Supporter, formikActions: FormikActions<Supporter>) => void;
  onClose: OnCloseType
  supporterModalState:SupporterModalState
  validationSchema: ReturnType<typeof createYup>
}

class LoadedPaneFormik extends React.Component<LoadedPaneProps & InjectedIntlProps, {}> {
  render() {
    return <HoudiniFormik initialValues={this.props.initialValues} onSubmit={this.props.onSubmit} validationSchema={this.props.validationSchema} render={(props) => {
      return <LoadedPane formik={props} addresses={this.props.addresses} onClose={this.props.onClose} supporterId={this.props.supporterId} supporterModalState={this.props.supporterModalState}/>
    }} />

  }
}

export default injectIntl(observer(LoadedPaneFormik))



