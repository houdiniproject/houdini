// License: LGPL-3.0-or-later
import has from 'lodash/has';
import { parse } from 'json5';
import { CustomFieldDescription } from '../customField';

function isCustomFieldDesc(item:unknown) : item is CustomFieldDescription {
  return typeof item == 'object' && has(item, 'name') && has(item, 'label');
}
export default class JsonStringParser {
  public error:SyntaxError = null;
  public readonly results: CustomFieldDescription[] = [];
  constructor(public readonly fieldsString:string) {
    this._parse();
  }

  get isValid(): boolean {
    return !!this.error
  }


  private _parse = (): void => {
    try {
      const result = parse(this.fieldsString)
      if (result instanceof Array) {
        result.filter(isCustomFieldDesc).forEach((i) => {
          this.results.push({ ...i});
        });
      }
    }
    catch(e:any) {
      this.error = e;
    }
  }
}

