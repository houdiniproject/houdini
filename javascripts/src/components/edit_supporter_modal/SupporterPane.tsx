// License: LGPL-3.0-or-later
import { observer } from 'mobx-react';
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { Address } from '../../../api';
import { isFilled } from '../../lib/utils';
import Button from '../common/form/Button';
import { FieldCreator } from '../common/form/FieldCreator';
import HoudiniFormikForm from '../common/form/HoudiniFormikForm';
import FormikBasicField from '../common/FormikBasicField';
import FormikHiddenField from '../common/FormikHiddenField';
import { FormikHelpers, HoudiniFormikProps } from '../common/HoudiniFormik';
import Star from '../common/icons/Star';
import { TwoColumnFields } from '../common/layout';
import SelectableTableRow from '../common/selectable_table_row/SelectableTableRow';

export interface SupporterPaneProps {
  formik: HoudiniFormikProps<any>
  addresses: Address[]
  editAddress: (address?: Address) => void
  isDefaultAddress: (addressId:number) => boolean
  addAddress: () => void
}
class SupporterPane extends React.Component<SupporterPaneProps & InjectedIntlProps, {}> {

  render() {
    const formik = this.props.formik

    return <HoudiniFormikForm formik={formik}>
      <TwoColumnFields>
        <FieldCreator component={FormikBasicField} name={'name'} label={'Name'} inputId={FormikHelpers.createId(formik, 'name')} />
        <FieldCreator component={FormikBasicField} name={'email'} label={'Email'} inputId={FormikHelpers.createId(formik, 'email')} />
      </TwoColumnFields>
      <TwoColumnFields>
        <FieldCreator component={FormikBasicField} name={'phone'} label={'Phone'} inputId={FormikHelpers.createId(formik, 'phone')}/>
        <FieldCreator component={FormikBasicField} name={'organization'} label={'Organization'} inputId={FormikHelpers.createId(formik, 'organization')}/>
      </TwoColumnFields>

      <FieldCreator component={FormikHiddenField} name="default_address.id"/>

      {this.props.addresses ?
        <table className={"clickable table--plaid"}>
          <thead>
            <tr>
              <th>Address <Button type="button" onClick={this.props.addAddress} buttonSize="tiny">Add Address</Button></th>
              {this.props.addresses.length > 0 ? <th style={{ textAlign: 'center' }}>Default?</th> : undefined }
            </tr>
          </thead>

          <tbody style={{ fontSize: '14px' }}>
            {this.props.addresses.map((a) => {
              const address = [a.address, a.city, a.state_code, a.zip_code, a.country].filter((i) => isFilled(i)).join(", ")
              return <SelectableTableRow onSelect={() => this.props.editAddress(a)} key={a.id}>
                <td>{address}</td>
                <td style={{ textAlign: "center" }}>{this.props.isDefaultAddress(a.id) ? <Star /> : false}</td>
              </SelectableTableRow>
            })
            }
          </tbody>
        </table> : false}
    </HoudiniFormikForm>

  }
}

export default injectIntl(observer(SupporterPane))



