// License: LGPL-3.0-or-later
import { parse } from 'json5';
import { CustomAmount, isCustomAmountObject } from '../customAmount';

export default class JsonStringParser {
  public errors: SyntaxError[] = [];
  public readonly results: CustomAmount[] = [];
  constructor(public readonly fieldsString: string) {
    this._parse();
  }

  get isValid(): boolean {
    return this.errors.length == 0;
  }

  private _parse = (): void => {
    try {
      const result = parse(this.fieldsString);
      const emptyCustomAmount = { highlight: false };
      if (result instanceof Array) {
        result.forEach((i) => {
          if (isCustomAmountObject(i)) {
            this.results.push({ ...emptyCustomAmount, ...i });
          } else if (typeof i == 'number') {
            this.results.push({ amount: i, highlight: false });
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
