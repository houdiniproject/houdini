// License: LGPL-3.0-or-later
import  * as React from 'react';
import { observer, inject, Provider } from 'mobx-react';
import {InjectedIntlProps, injectIntl} from 'react-intl';
import {Field} from "mobx-react-form";
import {observable, action, toJS, runInAction} from 'mobx';
import {InputHTMLAttributes} from 'react';

export interface ReactInputProps
{
  field:Field
  label?:string
  placeholder?:string
  children: React.ReactElement<InputHTMLAttributes<HTMLInputElement>>
}

function castToNullIfUndef(i:any){
  return i === undefined ? null : i
}


class ReactInput extends React.Component<ReactInputProps & InputHTMLAttributes<HTMLInputElement>, {}> {

  constructor(props:ReactInputProps){
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


  componentDidUpdate(prevProps: Readonly<ReactInputProps>, prevState: Readonly<{}>): void {
    this.updateProps()
  }

  @action.bound
  updateProps() {
      this.field.set('label', castToNullIfUndef(this.props.label))
      this.field.set('placeholder', castToNullIfUndef(this.props.placeholder))
  }

  @action.bound
  renderChildren(){
    let ourProps = this.winnowProps()
    let elem =  React.cloneElement(this.props.children as React.ReactElement<any>,
      {...ourProps, ...this.field.bind() })
    return elem

  }

  ///Removes the properties we don't want to put into the input element
  @action.bound
  winnowProps(): ReactInputProps & InputHTMLAttributes<HTMLInputElement> {
    let ourProps = {...this.props}
    delete ourProps.field
    delete ourProps.value
    return ourProps

  }

  render() {

    if (this.props.children)
    {
      return this.renderChildren()
    }
    else {
      return <input {...this.winnowProps()} {...this.field.bind()}/>
    }
  }
}

export default observer(ReactInput)



