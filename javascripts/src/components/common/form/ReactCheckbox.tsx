// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import { InjectedIntlProps, injectIntl } from 'react-intl';
import { ReactInputProps } from './react_input_props';
import { action, observable } from 'mobx';
import { Field } from 'mobx-react-form';
import { castToNullIfUndef } from '../../../lib/utils';

export interface ReactCheckboxProps {
  field: Field
  label?: string
}


type InputTypes = ReactCheckboxProps &
  React.InputHTMLAttributes<HTMLInputElement>

class ReactCheckbox extends React.Component<InputTypes, {}> {

  constructor(props: InputTypes) {
    super(props)
  }

  @observable
  field: Field

  @action.bound
  componentWillMount() {

    this.field = this.props.field


    this.updateProps()
  }

  @action.bound
  updateProps() {
    this.field.set('label', castToNullIfUndef(  this.props.label))
    this.field.set('placeholder', castToNullIfUndef(this.props.placeholder))
  }

  @action.bound
  winnowProps(): InputTypes {
    let ourProps = { ...this.props }
    delete ourProps.field
    delete ourProps.value
    return ourProps
  }

  render() {
    return <fieldset className="form-group reactCheckbox">
      <label>
        <input type="checkbox" {...this.winnowProps()} {...this.field.bind()} /><span className='cr'/>{this.props.label}
      </label>
    </fieldset>;
  }
}

export default observer(ReactCheckbox)



