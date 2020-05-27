// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import {Field} from "../../../../../../../types/mobx-react-form";
import {InputHTMLAttributes, ReactText, TextareaHTMLAttributes} from "react";
import {action, observable} from "mobx";
import {ReactInputProps} from "./react_input_props";
import {castToNullIfUndef} from "../../../lib/utils";

type InputTypes = ReactInputProps & TextareaHTMLAttributes<HTMLTextAreaElement>


class ReactTextarea extends React.Component<InputTypes, {}> {

  constructor(props:InputTypes){
    super(props)
  }

  @observable
  field:Field


  @action.bound
  componentWillMount(){

    this.field = this.props.field


    this.updateProps()
  }

  componentWillUnmount(){
  }


  componentDidUpdate(prevProps: Readonly<InputTypes>, prevState: Readonly<{}>): void {
    this.updateProps()
  }

  @action.bound
  updateProps() {
    this.field.set('label', castToNullIfUndef(this.props.label))
    this.field.set('placeholder', castToNullIfUndef(this.props.placeholder))
  }

  ///Removes the properties we don't want to put into the input element
  @action.bound
  winnowProps(): InputTypes {
    let ourProps = {...this.props}
    delete ourProps.field
    delete ourProps.value
    return ourProps

  }

  render() {
    return <textarea {...this.winnowProps()} {...this.field.bind()}/>
  }
}

export default observer(ReactTextarea)



