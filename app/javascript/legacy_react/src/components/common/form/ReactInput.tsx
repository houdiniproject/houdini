// License: LGPL-3.0-or-later
import  * as React from 'react';
import { observer } from 'mobx-react';
import {Field} from "mobx-react-form";
import {observable, action} from 'mobx';
import {InputHTMLAttributes} from 'react';
import {ReactInputProps} from "./react_input_props";
import {castToNullIfUndef} from "../../../lib/utils";


type InputTypes = ReactInputProps &
  InputHTMLAttributes<HTMLInputElement>

class ReactInput extends React.Component<InputTypes, {}> {

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
      return <input {...this.winnowProps()} {...this.field.bind()}/>
  }
}

export default observer(ReactInput)



