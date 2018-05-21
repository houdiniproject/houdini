// License: LGPL-3.0-or-later
import {Form} from "mobx-react-form";
import {action, runInAction} from 'mobx'
import validator = require("validator")
import * as _ from 'lodash'
import {ValidationErrorsException} from "../../api";


export class HoudiniForm extends Form {
  plugins() {
    return {
      vjf: validator


    };
  }
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

  convertFormToObject(form: Form): T {
    let output = {}
    for (let pathToFormKey in this.pathToForm) {
      if (this.pathToForm.hasOwnProperty(pathToFormKey)) {
        let formPath = this.pathToForm[pathToFormKey]
        if (form.$(formPath).value && _.trim(form.$(formPath).value) !== "")
          _.set(output, pathToFormKey,  form.$(formPath).value)
      }

    }

    return output as T

  }

  @action.bound
  convertErrorToForm(errorException: ValidationErrorsException, form: Form): void {
    runInAction(() => {
      _.forEach(errorException.item.errors, (error) => {
        let message = error.messages.join(", ")
        _.forEach(error.params, (p) => {
          if (this.pathToForm[p])
            form.$(this.pathToForm[p]).invalidate(message)
          else {
            console.warn(`We couldn't find a form element for path: "${p}"`)
          }

        })

      })
    })
  }
}