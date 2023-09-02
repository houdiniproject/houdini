// License: LGPL-3.0-or-later
import getAmt from "./amt";

describe('.getAmt', () => {
  it('returns {amount:, highlight:false} when passed number', () => {
    expect(getAmt(500)).toStrictEqual({ amount: 500, highlight: false });
  });

  it('returns {amount:, highlight:\'star\'} when passed {amount:, highlight: true}', () => {
    expect(getAmt({ amount: 500, highlight: true })).toStrictEqual({ amount: 500, highlight: 'star' });
  });

  it('returns {amount:, highlight:str} when passed {amount:, highlight: str}', () => {
    expect(getAmt({ amount: 500, highlight: 'house' })).toStrictEqual({ amount: 500, highlight: 'house' });
  });

  it('returns {amount:, highlight:false} when passed {amount:, highlight: false}', () => {
    expect(getAmt({ amount: 500, highlight: false})).toStrictEqual({ amount: 500, highlight: false});
  });
});
