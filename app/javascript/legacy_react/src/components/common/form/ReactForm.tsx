// License: LGPL-3.0-or-later
import * as React from 'react';
import { observer, Provider } from 'mobx-react';
import {Field, Form} from "mobx-react-form";
import {observable, action, toJS} from 'mobx';

export interface ReactFormProps
{
  form:Form
}

///Mostly useless class but, at some point, will replace all our form elements
@observer
export class ReactForm extends React.Component<ReactFormProps, {}> {



  @observable
  form:Form

  @action.bound
  componentWillMount()
  {
    this.form = this.props.form
  }




  componentDidUpdate(){


  }

  componentWillUnmount(){
  }


  render() {

     return <form >
          {this.props.children}
      </form>
  }
}




