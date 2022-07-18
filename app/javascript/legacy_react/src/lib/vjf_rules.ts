// License: LGPL-3.0-or-later
import * as Regex from './regex'
import {Field, Form} from "mobx-react-form";
import moment from "moment";


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

  static isFilled({field, validator}:ValidationInput) :StringBoolTuple {
    return [
        !validator.isEmpty(field.value),
      `${field.label} must be filled out`
    ]
  }

  static isGreaterThanOrEqualTo(value:number) : ({field, validator}:ValidationInput) => StringBoolTuple
  {
    return ({field, validator}:ValidationInput) => {
      return [
        parseFloat(field.get('value')) >= value,
        `${field.label} must be at least ${value}`
      ]
    }
  }

  static isLessThanOrEqualTo(value:number, flip:boolean=false) : ({field, validator}:ValidationInput) => StringBoolTuple
  {
    return ({field, validator}:ValidationInput) => {
      let float = field.get('value')
      return [
        (flip ? -1 * float : float) <= value,
        `${field.label} must be no more than ${value}`
      ]
    }
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

  static isDate(format:string): ({field, validator}:ValidationInput) => StringBoolTuple  {
    return ({field, validator}:ValidationInput) => {
      let m = moment(field.value, format, true);
      return [
        m.isValid(),
        `${field.label} must be a date with format: ${format}`
      ]
    }
  }


}