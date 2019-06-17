// License: LGPL-3.0-or-later
// based on: https://github.com/jquense/yup/blob/master/src/locale.js
export default interface YupLocaleValues {
    mixed: {
        default: string,
        required: string,
        oneOf: string,
        notOneOf: string,
        notType: ({path, type, value, originalValue}:{path:string, type:string, value:any, originalValue:any}) => string
    }

    string: {
        length: string,
        min: string,
        max: string,
        matches: string,
        email: string,
        url: string,
        trim: string,
        lowercase: string,
        uppercase: string,
    }
      
    number: {
        min: string,
        max: string,
        lessThan: string,
        moreThan: string,
        notEqual: string,
        positive: string,
        negative: string,
        integer: string,
      };
      
      date:{
        min: string,
        max:string,
      };
      
      boolean:{};
      
      object: {
        noUnknown: string,
      };
      
      array: {
        min: string,
        max: string,
      };
}