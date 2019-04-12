// License: LGPL-3.0-or-later
import { Formik, FormikActions, FormikComputedProps, FormikConfig, FormikErrors, FormikHandlers, FormikRegistration, FormikSharedConfig, FormikState } from 'formik';
import * as React from 'react';
import { ValidationError, ValidationErrors, ValidationErrorsException } from '../../../api';
import { ObjectDiff } from '../../lib/types';
import _ = require('lodash');



export interface HoudiniFormikServerStatus<Values> {
  form?:any
  fields?: FormikErrors<Values>
  
}

export interface HoudiniStatus<Values> extends HoudiniFormikServerStatus<Values>{
  id:string
}

export type HoudiniFormikActions<Values> = ObjectDiff<FormikActions<Values>, {'setStatus':any}> ;

export interface HoudiniFormikState<Values> extends FormikState<Values> {
  status?: HoudiniFormikServerStatus<Values>;
}

export interface HoudiniFormikConfig<Values> extends FormikConfig<Values> {
  component?: React.ComponentType<HoudiniFormikProps<Values>> | React.ReactNode;
  render?: ((props: HoudiniFormikProps<Values>) => React.ReactNode);
  children?: ((props: HoudiniFormikProps<Values>) => React.ReactNode) | React.ReactNode;
  onSubmit: (values: Values, formikActions: FormikActions<Values>) => void;
}

export type HoudiniFormikProps<Values> = FormikSharedConfig & HoudiniFormikState<Values> & HoudiniFormikActions<Values> & FormikHandlers & FormikComputedProps<Values> & FormikRegistration;

export interface HoudiniFormikFieldProps<V = any> {
  field: {
      onChange: FormikHandlers['handleChange'];
      onBlur: FormikHandlers['handleBlur'];
      value: any;
      name: string;
  };
  form: HoudiniFormikProps<V>;
}

export const FormikHelpers = {
  
  convertServerValidationToFieldStatus<Values>(errors:ValidationErrorsException|ValidationErrors|Array<ValidationError>) : FormikErrors<Values> {
    let errorArray:Array<ValidationError>
    if (errors instanceof ValidationErrorsException)
    {
      errorArray = errors.item.errors
    }
    else if (errors instanceof Array)
    {
      errorArray = errors
    }
    else {
      errorArray = errors.errors
    }

    let output:FormikErrors<Values> = {}
    errorArray.forEach(error => {
      error.params.forEach(p => {
        if(!_.has(output, p))
        {
          _.set(output, p, new Array<string>())
        }
        error.messages.forEach(m => {
          (_.get(output, p) as string[]).push(m)
        })
      })
      
    });

    return output;
  },

  isDirty<Values>(path:string, props:HoudiniFormikProps<Values> ){
    return _.get(props.initialValues, path) === _.get(props.values, path)
  },

  isEmpty(value:string) {
    return !value ||  _.trim(value) === ''
  },

  setStatus<Values>({ status, action }: { status?: HoudiniFormikServerStatus<Values>; action: HoudiniFormikActions<Values>; })
  {
    const id = (action as any).status && (action as any).status.id

    const newStatus = _.merge({id: id}, status as any) as any

    (action as any).setStatus(newStatus)
  },

  getIdBase<V>(props:HoudiniFormikProps<V>):string {
    return (props.status as any).id;
  },

  createId<V>(props:HoudiniFormikProps<V>, path:string):string {
    return FormikHelpers.getIdBase(props) + "---" + path
  }
}


export default class HoudiniFormik<Values> extends React.Component<HoudiniFormikConfig<Values>, HoudiniFormikState<Values>> {
  constructor(props:HoudiniFormikConfig<Values>)
  {
    super(props)
    this.id = _.uniqueId()
  }
  id:string
  render() {
    return <Formik {...this.props} initialStatus={{...this.props.initialStatus, id:this.id}} onSubmit={(values, action) => {
        const convertedAction = _.clone(action)
        convertedAction.setStatus = (status) => {FormikHelpers.setStatus({status:status, action:action})}
        return this.props.onSubmit(values, convertedAction);
    }}
        />
  }

}

