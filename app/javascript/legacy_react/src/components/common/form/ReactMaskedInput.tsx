// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer } from 'mobx-react';
import {ReactInputProps} from "./react_input_props";
import {InputHTMLAttributes} from "react";
import {action, observable} from "mobx";
import {Field} from "mobx-react-form";
import {castToNullIfUndef} from "../../../lib/utils";
import MaskedInput, {Mask} from "react-text-mask";
import omit from 'lodash/omit'

type InputTypes = ReactInputProps &
  InputHTMLAttributes<HTMLInputElement> & {
  mask?: Mask | ((value: string) => Mask);

  guide?: boolean;

  placeholderChar?: string;

  keepCharPositions?: boolean;

  pipe?: (
    conformedValue: string,
    config: any
  ) => false | string | { value: string; indexesOfPipedChars: number[] };

  showMask?: boolean;
}

class ReactMaskedInput extends React.Component<InputTypes, {}> {

  constructor(props:InputTypes){
    super(props)
  }

  @observable
  field:Field|undefined


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
    this.field?.set('label', castToNullIfUndef(this.props.label))
    this.field?.set('placeholder', castToNullIfUndef(this.props.placeholder))
  }

  ///Removes the properties we don't want to put into the input element
  @action.bound
  winnowProps(): Omit<InputTypes, 'field'|'value'> {
    return omit(this.props, ['field', 'value']);
  }

  render() {
    return <MaskedInput {
      ...this.winnowProps() as any //This typing should work but for some reason, it's not. So I'm updating?
    } 
    {...this.field?.bind()}/>
  }
}

export default observer(ReactMaskedInput)




