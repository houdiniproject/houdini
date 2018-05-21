// License: LGPL-3.0-or-later
import * as Regex from './regex'
import {Field, Form} from "mobx-react-form";


interface ValidationInput {
  field: Field
  validator?: ValidatorJS.ValidatorStatic
  form?: Form

}

interface StringBoolTuple extends Array<boolean|string>{0:boolean, 1:string}

interface Validation {
  (input:ValidationInput): StringBoolTuple
}


export class Validations  {
  static isEmail({field}:ValidationInput) : StringBoolTuple {
    return [field.value.match(Regex.Email) !== null,
      `${field.label} is not a valid email`]
  }

  static shouldBeEqualTo (targetPath: string): Validation {
    return ({field, form}:ValidationInput) => {
      const fieldsAreEquals = (form.$(targetPath).value === field.value);
      return [fieldsAreEquals, `${field.label} and ${form.$(targetPath).label} must be the same`]
  }
  }

  static isUrl({field, validator}:ValidationInput):StringBoolTuple {
    return [validator.isURL(field.value),
    `${field.label} must be a valid URL`]
  }

  static isFilled({field, validator}:ValidationInput) :StringBoolTuple {
    return [
        !validator.isEmpty(field.value),
      `${field.label} must be filled out`
    ]
  }

  static optional(validation:Validation) : Validation {
    return ({field, form, validator}:ValidationInput) => {
      if (!field.value || validator.isEmpty(field.value)){
        return [true, ""]
      }
      else{
        return validation({field: field, form: form, validator: validator})
      }
    };
  }


}