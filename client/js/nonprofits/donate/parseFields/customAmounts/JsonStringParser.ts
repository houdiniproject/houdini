// License: LGPL-3.0-or-later
import has from 'lodash/has';
import { parse } from 'json5';
import { Amount, CustomAmount } from '../customAmounts';

function isCustomAmountObject(item: unknown): item is CustomAmount {
  return typeof item == 'object' && has(item, 'amount');
}
export default class JsonStringParser {
  public errors: SyntaxError[] = [];
  public readonly results: Amount[] = [];
  constructor(public readonly fieldsString: string) {
    this._parse();
  }

  get isValid(): boolean {
    return this.errors.length == 0;
  }

  private _parse = (): void => {
    try {
      const result = parse(this.fieldsString);
      if (result instanceof Array) {
        result.forEach((i) => {
          if (isCustomAmountObject(i)) {
            this.results.push({ ...i });
          } else if (typeof i == 'number') {
            this.results.push(i);
          } else {
            this.errors.push(new SyntaxError(JSON.stringify(i) + ' is not a valid custom amount'));
          }
        });
      } else {
        this.errors.push(new SyntaxError('Input did not parse to an array'));
      }
    } catch (e: any) {
      this.errors.push(e);
    }
  };
}
