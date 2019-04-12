// License: LGPL-3.0-or-later
import { FormikActions } from 'formik';
import { observer } from 'mobx-react';
import * as React from 'react';
import { Address, Supporter } from '../../../api';
import HoudiniFormik from '../common/HoudiniFormik';
import LoadedPane from './LoadedPane';
import _ = require('lodash');
import { OnCloseType } from './SupporterModalBase';

export interface LoadedPaneProps {
  supporterId: number
  initialValues: Supporter
  addresses: Address[]
  onSubmit: (values: Supporter, formikActions: FormikActions<Supporter>) => void;
  onClose: OnCloseType
}

class LoadedPaneFormik extends React.Component<LoadedPaneProps, {}> {
  render() {
    return <HoudiniFormik initialValues={this.props.initialValues} onSubmit={this.props.onSubmit} render={(props) => {
      return <LoadedPane formik={props} addresses={this.props.addresses} onClose={this.props.onClose} supporterId={this.props.supporterId}/>
    }} />

  }
}

export default (observer(LoadedPaneFormik))



