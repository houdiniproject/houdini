// License: LGPL-3.0-or-later
import {Field, FieldDefinition, Form, initializationDefinition} from "mobx-react-form";
import {action, computed, IValueDidChange, observable, runInAction} from 'mobx'
import * as _ from 'lodash'
import {ValidationErrorsException} from "../../api";
import validator = require("validator");


export class HoudiniForm extends Form {
  constructor(definition?:initializationDefinition, options?:any){
    //correct the bug where field initializations with just names don't work
    if (definition && definition.fields){
      definition.fields = definition.fields.map((i:FieldDefinition) =>
      {
        if (_.entries(i).length == 1)
        {
          i.extra = null
        }
        return i
      })
    }
    super(definition, options)
  }

  @observable
  private $serverError:string

  plugins() {
    return {
      vjf: validator
    };
  }

  public makeField(key:any, path:any, data:any, props:any, update:boolean, state:any) {
    return new HoudiniField(key, path, data, props, update, state);
  }

  @computed
  public get serverError():string {
    return this.$serverError
  }

  @computed
  public get hasServerError():boolean{
    return (this.$serverError && this.$serverError !== null && this.$serverError !== "") &&
        !this.submitting
  }

  @action
  invalidateFromServer(message:string) {
    this.invalidate()
    this.$serverError = message
  }

  @action
  clearServerErrors() {
    this.$serverError = null
  }
}


export class HoudiniField extends Field {
  constructor(...props:any[]) {
    super(...props)


    this.observe({
      key: 'areWeOrAnyParentSubmitting', call: (obj: { form: HoudiniForm,
        field: HoudiniField,
        change: IValueDidChange<boolean> }) => {
        if (obj.change.newValue) {
          this.$serverError = null
        }
      }
    })
  }

  @observable private $serverError:string

  @action
  invalidateFromServer(message:string) {
    this.$serverError = message
  }

  @computed
  public get serverError():string {
    return this.$serverError
  }

  @computed get areWeOrAnyParentSubmitting() :boolean {
    return areWeOrAnyParentSubmitting(this)
  }

  @computed
  public get hasServerError():boolean{
    return (this.$serverError && this.$serverError !== null && this.$serverError !== "")
  }





}



export function areWeOrAnyParentSubmitting(f:Field|Form ) : boolean
{
  let currentItem: Field|Form = f
  let isSubmitting:boolean = f.submitting
  while (!isSubmitting && currentItem && !(currentItem instanceof Form)){
    currentItem = currentItem.container()
    isSubmitting = currentItem.submitting
  }

  return isSubmitting
}




interface PathToFormField {
  [props: string]: string
}

type FormFieldToPath = PathToFormField

/**
 * tool for converting between the form's data structure
 * to the AJAX datastructure and properly assigning
 * errors if AJAX request fails
 * As an example for the, consider the the following form structure:
 * {
 *  // a tab in a Wizard
 *  nonprofitTab: {
 *    organization_name: {some field info}
 *  }
 * }
 *
 * We want to create a data structure for AJAX like so:
 *
 *  In the database
 *
 */
export class StaticFormToErrorAndBackConverter<T> {

  pathToForm: PathToFormField
  formToPath: FormFieldToPath


  constructor(pathToForm: PathToFormField) {
    this.pathToForm = pathToForm
    this.formToPath = _.invert(pathToForm)
  }

  convertFormToObject(form: HoudiniForm|Form): T {
    let output = {}
    let hForm = form as HoudiniForm
    for (let pathToFormKey in this.pathToForm) {
      if (this.pathToForm.hasOwnProperty(pathToFormKey)) {
        let formPath = this.pathToForm[pathToFormKey]
        if (hForm.$(formPath).value && _.trim(hForm.$(formPath).value) !== "")
          _.set(output, pathToFormKey,  hForm.$(formPath).value)
      }

    }

    return output as T

  }

  @action.bound
  convertErrorToForm(errorException: ValidationErrorsException, form: HoudiniForm|Form): void {
    runInAction(() => {
      let hForm = form as HoudiniForm
      errorException.item.errors?.forEach((error) => {
        const [field, messages] = error;
        let message = messages.join(", ")
        if (this.pathToForm[field]) {
          (hForm.$(this.pathToForm[field]) as HoudiniField).invalidateFromServer(message)
        }
        else {
          console.warn(`We couldn't find a form element for path: "${field}"`)
        }
      })
    })
  }
}


