// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, inject } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import SelectableTableRow from '../common/SelectableTableRow';
import Star from '../common/icons/Star';
import Button from '../common/form/Button';
import { TwoColumnFields } from '../common/layout';
import { isFilled } from '../../lib/utils';
import { HoudiniFormikProps, FormikHelpers } from '../common/HoudiniFormik';
import FormikBasicField from '../common/FormikBasicField';
import { FieldCreator } from '../common/form/FieldCreator';
import FormikHiddenField from '../common/FormikHiddenField';
import { Address } from '../../../api';

export interface SupporterPaneProps {
  formik: HoudiniFormikProps<any>
  addresses: Address[]
  editAddress: (address?: Address) => void
  isDefaultAddress: (addressId:number) => boolean
  addAddress: () => void
  onClose: () => void
}
class SupporterPane extends React.Component<SupporterPaneProps & InjectedIntlProps, {}> {

  render() {
    const formik = this.props.formik

    return <form onSubmit={formik.handleSubmit} onReset={formik.handleReset}>
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
              <th>Address</th>
              <th style={{ textAlign: 'center' }}>Default?</th>
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

            <SelectableTableRow onSelect={this.props.addAddress}>
              <td colSpan={2}><Button onClick={this.props.addAddress} buttonSize="tiny">Add Address</Button></td>
            </SelectableTableRow>
          </tbody>
        </table> : false}

      <Button type={'button'} onClick={() => this.props.onClose()}>Close</Button>

      <Button type={'submit'}>Save</Button>
    </form>

  }
}

export default injectIntl(observer(SupporterPane))



