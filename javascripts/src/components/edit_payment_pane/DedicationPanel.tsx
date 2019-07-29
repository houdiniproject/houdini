// License: LGPL-3.0-or-later
import * as React from 'react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { HoudiniFormikProps, FormikHelpers } from '../common/HoudiniFormik';
import { FieldCreator } from '../common/form/FieldCreator';
import FormikSelectField from '../common/FormikSelectField';
import TableLabeledBasicField from './TableLabeledBasicField';
import FormikTextareaField from '../common/FormikTextareaField';
import FormikHiddenField from '../common/FormikHiddenField';
import Panel from '../common/bootstrap/Panel';
import { isFilled } from '../../lib/utils';

export interface DedicationPanelProps {

}

type DedicationValues = SelectedDedicationValues | UnselectedDedicationValues

interface SelectedDedicationValues {
  dedication: {
    type: 'honor' | 'memory',
    name?: string,
    supporter_id?: number,
    phone?: string,
    email?: string,
    full_address?: string,
    note?: string
  }
}

interface UnselectedDedicationValues {
  dedication: {
    type: '' | null | undefined
  }
}


type DedicationPropType = { formik: HoudiniFormikProps<DedicationValues> }
type SelectedDedicationPropType = { formik: HoudiniFormikProps<SelectedDedicationValues> }

class DedicationPanel extends React.Component<DedicationPropType & InjectedIntlProps> {
  render() {
    return <Panel headerRender={() => <label>Dedication</label>}
      render={() => <>
        <FieldCreator component={FormikSelectField} label={"Dedication Type"} name={"dedication.type"} options={[{ value: null, label: '' }, { value: 'honor', label: 'In honor of' }, {
          value: 'memory',
          label: 'In memory of'
        }]} inputId={FormikHelpers.createId(this.props.formik, 'dedication.type')}/>
        <ConditionalDedicationDetails formik={this.props.formik} />
      </>
      } />
  }
}

class ConditionalDedicationDetails extends React.Component<DedicationPropType>{

  render() {
    if (isFilled(this.props.formik.values.dedication.type)) {
      const formikType = this.props.formik as HoudiniFormikProps<SelectedDedicationValues>
      return <DedicationDetails formik={formikType} />

    }
    else {
      return null;
    }
  }
}

class DedicationDetails extends React.Component<SelectedDedicationPropType> {
  render() {
    return <Panel headerRender={() => <label>Dedicated to:</label>}
      render={() => <>
        <table className='table--small u-marginBottom--10'>
          <tbody>
            <FieldCreator component={TableLabeledBasicField} name={'dedication.dedication.name'} label={'Name'} inputId={FormikHelpers.createId(this.props.formik, 'dedication.dedication.name')} />
            <tr>

              <th> Supporter
                ID
                  </th>
              <td>{this.props.formik.values.dedication.supporter_id}<FieldCreator component={FormikHiddenField} name={'dedication.dedication.supporter_id'} /></td>
            </tr>

            <FieldCreator component={TableLabeledBasicField} name={'dedication.dedication.full_address'} label={'Full address'} inputId={FormikHelpers.createId(this.props.formik, 'dedication.dedication.full_address')} />
            <FieldCreator component={TableLabeledBasicField} name={'dedication.dedication.phone'} inputId={FormikHelpers.createId(this.props.formik, 'dedication.dedication.phone')} />
            <FieldCreator component={TableLabeledBasicField} name={'dedication.dedication.email'} inputId={FormikHelpers.createId(this.props.formik, 'dedication.dedication.email')} />
          </tbody>
        </table>

        <FieldCreator component={FormikTextareaField} placeholder={'Dedication'} name={'dedication.dedication.note'} label={"Dedication Note"} rows={3} inputId={FormikHelpers.createId(this.props.formik, 'dedication.dedication.note')} />
      </>
      } />

  }
}

export default injectIntl(DedicationPanel)



