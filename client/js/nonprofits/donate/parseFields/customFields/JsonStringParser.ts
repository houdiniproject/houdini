// License: LGPL-3.0-or-later
import { parse } from 'json5';
import { CustomFieldDescription, isCustomFieldDescription } from '../customField';


export default class JsonStringParser {
  public errors:SyntaxError[] = [];
  public readonly results: CustomFieldDescription[] = [];
  constructor(public readonly fieldsString:string) {
    this._parse();
  }

  get isValid(): boolean {
    return this.errors.length == 0;
  }


  private _parse = (): void => {
    try {
      const result = parse(this.fieldsString)
      if (result instanceof Array) {
        result.forEach((i) => {
          if (isCustomFieldDescription(i)) {
            this.results.push({ ...i});
          }
          
          else {
            this.errors.push(new SyntaxError(JSON.stringify(i) + " is not a valid custom field description"))
          }
        });
      }
      else {
        this.errors.push(new SyntaxError("Input did not parse to an array"))
      }
    }
    catch(e:any) {
      this.errors.push(e)
    }
  }
}

