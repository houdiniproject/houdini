// License: LGPL-3.0-or-later
import amount_button_contents from "./amount_button_contents";

describe('.amount_button_contents', () => {
  it('does not include a highlight when highlight is false', () => {
    expect(amount_button_contents("$", {amount: 100, highlight: false})).toHaveLength(2);
  });

  it('does include a highlight when highlight is a string', () => {
    expect(amount_button_contents("$", {amount: 100, highlight: 'house'})).toHaveLength(3);
  });
});