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
        <FieldCreator component={FormikSelectField} label={"Dedication Type"} name={"dedication.type"} options={[{ id: null, name: '' }, { id: 'honor', name: 'In honor of' }, {
          id: 'memory',
          name: 'In memory of'
        }]} />
        <ConditionalDedicationDetails formik={this.props.formik} />
      </>
      } />
  }
}

class ConditionalDedicationDetails extends React.Component<DedicationPropType>{

  render() {
    if (this.props.formik.values.dedication.type != '') {
      const formikType = this.props.formik as HoudiniFormikProps<SelectedDedicationValues>
      return <DedicationDetails formik={formikType} />

    }
    else {
      return undefined;
    }
  }
}

class DedicationDetails extends React.Component<SelectedDedicationPropType> {
  render() {
    return <Panel headerRender={() => <label>Dedicated to:</label>}
      render={() => <>
        <table className='table--small u-marginBottom--10'>
          <tbody>
            <FieldCreator component={TableLabeledBasicField} name={'dedication.name'} label={'Name'} inputId={FormikHelpers.createId(this.props.formik, 'dedication.name')} />
            <tr>

              <th> Supporter
                ID
                  </th>
              <td>{this.props.formik.values.dedication.supporter_id}<FieldCreator component={FormikHiddenField} name={'dedication.supporter_id'} /></td>
            </tr>

            <FieldCreator component={TableLabeledBasicField} name={'dedication.full_address'} label={'Full address'} inputId={FormikHelpers.createId(this.props.formik, 'dedication.name')} />
            <FieldCreator component={TableLabeledBasicField} name={'dedication.phone'} inputId={FormikHelpers.createId(this.props.formik, 'dedication.phone')} />
            <FieldCreator component={TableLabeledBasicField} name={'dedication.email'} inputId={FormikHelpers.createId(this.props.formik, 'dedication.email')} />
          </tbody>
        </table>

        <FieldCreator component={FormikTextareaField} placeholder={'Dedication'} name={'dedication.note'} label={"Dedication Note"} rows={3} inputId={FormikHelpers.createId(this.props.formik, 'dedication.note')} />
      </>
      } />

  }
}

export default injectIntl(DedicationPanel)



