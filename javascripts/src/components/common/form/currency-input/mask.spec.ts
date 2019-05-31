// License: LGPL-3.0-or-later
// from: https://github.com/jsillitoe/react-currency-input/blob/master/test/mask.spec.js
import 'jest';
import {NumberFormatHelper} from './mask'

const nbsp = String.fromCharCode(160)

const enUS = NumberFormatHelper.initializeFromProps('en-us', {currency: 'USD', style: 'currency'});
const jaJP = NumberFormatHelper.initializeFromProps('ja-JP', { style: 'currency', currency: 'JPY' })

const enIN = NumberFormatHelper.initializeFromProps('en-IN', { style: 'currency', currency: 'INR' })

const deDE = NumberFormatHelper.initializeFromProps('de-DE', { style: 'currency', currency: 'EUR' })

describe('mask', function () {
  
  it('should return empty strings when value is not set"', function () {
    const { maskedValue, value } = enUS.mask();

    expect(maskedValue).toBe("");
    expect(value).toBe(0);
  });

  it('should return empty strings when value is empty string"', function () {
    const { maskedValue, value } =  enUS.mask("");

    expect(maskedValue).toBe("");
    expect(value).toBe(0);
  });

  it('should return empty strings when value is null"', function () {
    const { maskedValue, value } =  enUS.mask(null);

    expect(maskedValue).toBe("");
    expect(value).toBe(0);
  });

  it('should change "0" to "0.00"', function () {
    const { maskedValue, value } =  enUS.mask("0");

    expect(maskedValue).toBe("$0.00");
    expect(value).toBe(0);
  });

  it('should change "00" to "0.00"', function () {
    const { maskedValue, value } =  enUS.mask("00");

    expect(maskedValue).toBe("$0.00");
    expect(value).toBe(0);
  });

  it('should change "000" to "$0.00"', function () {
    const { maskedValue, value } =  enUS.mask("000");
    expect(maskedValue).toBe("$0.00");
    expect(value).toBe(0);
  });

  it('should change "0000" to "0.00"', function () {
    const { maskedValue, value } =  enUS.mask("0000");
    expect(maskedValue).toBe("$0.00");
    expect(value).toBe(0);
  });

  it('should change "0001" to "0.01"', function () {
    const { maskedValue, value } =  enUS.mask("0001");
    expect(maskedValue).toBe("$0.01");
    expect(value).toBe(0.01);
  });

  it('should change "1001" to "1$0.01"', function () {
    const { maskedValue, value } =  enUS.mask("1001");
    expect(maskedValue).toBe("$10.01");
    expect(value).toBe(10.01);
  });

  it('should change "123456789" to "1,234,567.89"', function () {
    const { maskedValue, value } =  enUS.mask("123456789");
    expect(maskedValue).toBe("$1,234,567.89");
    expect(value).toBe(1234567.89);
  });


  it('should change "100.1" to "100.10"', function () {
    const { maskedValue, value } =  enUS.mask("100.1");
    expect(maskedValue).toBe("$100.10");
    expect(value).toBe(100.1);
  });

  describe('jp', () => {

    it('should return empty strings when value is not set"', function () {
      const { maskedValue, value } = jaJP.mask();
  
      expect(maskedValue).toBe("");
      expect(value).toBe(0);
    });
  
    it('should return empty strings when value is empty string"', function () {
      const { maskedValue, value } =  jaJP.mask("");
  
      expect(maskedValue).toBe("");
      expect(value).toBe(0);
    });
  
    it('should return empty strings when value is null"', function () {
      const { maskedValue, value } =  jaJP.mask(null);
  
      expect(maskedValue).toBe("");
      expect(value).toBe(0);
    });
  
    it('should change "0" to "￥0"', function () {
      const { maskedValue, value } =  jaJP.mask("0");
  
      expect(maskedValue).toBe(`￥0`);
      expect(value).toBe(0);
    });
  
    it('should change "00" to "￥0"', function () {
      const { maskedValue, value } =  jaJP.mask("00");
  
      expect(maskedValue).toBe("￥0");
      expect(value).toBe(0);
    });
  
    it('should change "000" to "￥0"', function () {
      const { maskedValue, value } =  jaJP.mask("000");
      expect(maskedValue).toBe("￥0");
      expect(value).toBe(0);
    });
  
    it('should change "0000" to "￥0"', function () {
      const { maskedValue, value } =  jaJP.mask("0000");
      expect(maskedValue).toBe("￥0");
      expect(value).toBe(0);
    });
  
    it('should change "0001" to "￥1"', function () {
      const { maskedValue, value } =  jaJP.mask("0001");
      expect(maskedValue).toBe("￥1");
      expect(value).toBe(1);
    });
  
    it('should change "1001" to "￥1,001', function () {
      const { maskedValue, value } =  jaJP.mask("1001");
      expect(maskedValue).toBe("￥1,001");
      expect(value).toBe(1001);
    });
  
    it('should change "123456789" to "￥123,456,789"', function () {
      const { maskedValue, value } =  jaJP.mask("123456789");
      expect(maskedValue).toBe("￥123,456,789");
      expect(value).toBe(123456789);
    });

    it('should change "￥123,456,789" to "￥123,456,789"', function () {
      const { maskedValue, value } =  jaJP.mask("￥123,456,789");
      expect(maskedValue).toBe("￥123,456,789");
      expect(value).toBe(123456789);
    });

    it('should change "￥12,3,456,7,,89" to "￥123,456,789"', function () {
      const { maskedValue, value } =  jaJP.mask("￥123,456,789");
      expect(maskedValue).toBe("￥123,456,789");
      expect(value).toBe(123456789);
    });
  
  
    it('should change "100." to "￥100"', function () {
      const { maskedValue, value } =  jaJP.mask("100.");
      expect(maskedValue).toBe("￥100");
      expect(value).toBe(100);
    });

  })

  describe('in', () => {

    it('should return empty strings when value is not set"', function () {
      const { maskedValue, value } = enIN.mask();
  
      expect(maskedValue).toBe("");
      expect(value).toBe(0);
    });
  
    it('should return empty strings when value is empty string"', function () {
      const { maskedValue, value } =  enIN.mask("");
  
      expect(maskedValue).toBe("");
      expect(value).toBe(0);
    });
  
    it('should return empty strings when value is null"', function () {
      const { maskedValue, value } =  enIN.mask(null);
  
      expect(maskedValue).toBe("");
      expect(value).toBe(0);
    });
  
    it('should change "0" to "₹0.00"', function () {
      const { maskedValue, value } =  enIN.mask("0");
      expect(maskedValue).toBe(`₹${nbsp}0.00`);
      expect(value).toBe(0);
    });
  
    it('should change "00" to "₹0.00"', function () {
      const { maskedValue, value } =  enIN.mask("00");
  
      expect(maskedValue).toBe(`₹${nbsp}0.00`);
      expect(value).toBe(0);
    });
  
    it('should change "000" to "₹0.00"', function () {
      const { maskedValue, value } =  enIN.mask("000");
      expect(maskedValue).toBe(`₹${nbsp}0.00`);
      expect(value).toBe(0);
    });
  
    it('should change "0000" to "₹0.00"', function () {
      const { maskedValue, value } =  enIN.mask("0000");
      expect(maskedValue).toBe(`₹${nbsp}0.00`);
      expect(value).toBe(0);
    });
  
    it('should change "0001" to "₹0.00"', function () {
      const { maskedValue, value } =  enIN.mask("0001");
      expect(maskedValue).toBe(`₹${nbsp}0.01`);
      expect(value).toBe(0.01);
    });
  
    it('should change "1001" to "₹10.00', function () {
      const { maskedValue, value } =  enIN.mask("1001");
      expect(maskedValue).toBe(`₹${nbsp}10.01`);
      expect(value).toBe(10.01);
    });
  
    it('should change "123456789" to "₹12,34,567.89"', function () {
      const { maskedValue, value } =  enIN.mask("123456789");
      expect(maskedValue).toBe(`₹${nbsp}12,34,567.89`);
      expect(value).toBe(1234567.89);
    });

    it('should change "₹12,34,567.89" to "₹12,34,567.89"', function () {
      const { maskedValue, value } =  enIN.mask("₹12,34,567.89");
      expect(maskedValue).toBe(`₹${nbsp}12,34,567.89`);
      expect(value).toBe(1234567.89);
    });

    it('should change "₹12,34,56,,7.8.9" to "₹12,34,567.89"', function () {
      const { maskedValue, value } =  enIN.mask("￥123,456,789");
      expect(maskedValue).toBe(`₹${nbsp}12,34,567.89`);
      expect(value).toBe(1234567.89);
    });
  
  
    it('should change "100." to "₹100.00"', function () {
      const { maskedValue, value } =  enIN.mask("100.");
      expect(maskedValue).toBe(`₹${nbsp}100.00`);
      expect(value).toBe(100);
    });

  })


  describe('with separators', function () {

    // it('decimal:"," thousand:"." should change "123456789" to "1.234.567,89"', function () {
    //   const { maskedValue, value } = mask("123456789", 2, ",", ".");
    //   expect(maskedValue).toBe("1.234.567,89");
    //   expect(value).toBe(1234567.89);
    // });

    // it('zero length thousand separator should change "123456789" to "1234567.89"', function () {
    //   const { maskedValue, value } = mask("123456789", 2, ".", "");
    //   expect(maskedValue).toBe("1234567.89");
    //   expect(value).toBe(1234567.89);
    // });

    // it('zero length decimal separator should change "123456789" to "1,234,56789"', function () {
    //   const { maskedValue, value } = mask("123456789", 2, "", ",");
    //   expect(maskedValue).toBe("1,234,56789");
    //   expect(value).toBe(1234567.89);
    // });

  });


  describe('with precision', function () {

    // it('set to string value "3" should change "123456789" to "123,456.789"', function () {
    //   const { maskedValue, value } = mask("123456789", "3");
    //   expect(maskedValue).toBe("123,456.789");
    //   expect(value).toBe(123456.789)
    // });

    // it('set to 3 should change "123456789" to "123,456.789"', function () {
    //   const { maskedValue, value } = mask("123456789", 3);
    //   expect(maskedValue).toBe("123,456.789");
    //   expect(value).toBe(123456.789);
    // });

    // it('set to 3 should change "1234567.000" to "1,234,567.000"', function () {
    //   const { maskedValue, value } = mask("1234567.000", 3);
    //   expect(maskedValue).toBe("1,234,567.000");
    //   expect(value).toBe(1234567);
    // });

    // it('set to 0 should change "123456789" to "123,456,789"', function () {
    //   const { maskedValue, value } = mask("123456789", 0);
    //   expect(maskedValue).toBe("123,456,789");
    //   expect(value).toBe(123456789);
    // });

  });


  describe('negative numbers', function () {

    it('all "-" should be stripped out if allowNegative is false', function () {
      expect( enUS.mask("123456").maskedValue).toBe("$1,234.56");
      expect( enUS.mask("-123456").maskedValue).toBe("$1,234.56");
      expect( enUS.mask("--123456").maskedValue).toBe("$1,234.56");
      expect( enUS.mask("--123--456").maskedValue).toBe("$1,234.56");
      expect( enUS.mask("--123--456--").maskedValue).toBe("$1,234.56");
    });

    // it('single "-" anywhere in the string should result in a negative masked number', function () {
    //   expect(mask("-123456", "2", ".", ",", true).maskedValue).toBe("-1,234.56");
    //   expect(mask("123-456", "2", ".", ",", true).maskedValue).toBe("-1,234.56");
    //   expect(mask("123456-", "2", ".", ",", true).maskedValue).toBe("-1,234.56");
    // });

    // it('single "-" anywhere in the string should result in a negative unmasked number', function () {
    //   expect(mask("-123456", "2", ".", ",", true).value).toBe(-1234.56);
    //   expect(mask("123-456", "2", ".", ",", true).value).toBe(-1234.56);
    //   expect(mask("123456-", "2", ".", ",", true).value).toBe(-1234.56);
    // });

    // it('no or even number of "-" should result in a positive number', function () {
    //   expect(mask("123456", "2", ".", ",", true).maskedValue).toBe("1,234.56");
    //   expect(mask("--123456", "2", ".", ",", true).maskedValue).toBe("1,234.56");
    //   expect(mask("123--456", "2", ".", ",", true).maskedValue).toBe("1,234.56");
    //   expect(mask("123456--", "2", ".", ",", true).maskedValue).toBe("1,234.56");
    //   expect(mask("--123456--", "2", ".", ",", true).maskedValue).toBe("1,234.56");
    //   expect(mask("--123--456--", "2", ".", ",", true).maskedValue).toBe("1,234.56");
    //   expect(mask("--1--234--56--", "2", ".", ",", true).maskedValue).toBe("1,234.56");
    // });

    // it('odd number of "-" should result in a negative number', function () {
    //   expect(mask("-123456", "2", ".", ",", true).maskedValue).toBe("-1,234.56");
    //   expect(mask("123-456", "2", ".", ",", true).maskedValue).toBe("-1,234.56");
    //   expect(mask("123456-", "2", ".", ",", true).maskedValue).toBe("-1,234.56");
    //   expect(mask("-123-456-", "2", ".", ",", true).maskedValue).toBe("-1,234.56");
    //   expect(mask("-1-23-45-6-", "2", ".", ",", true).maskedValue).toBe("-1,234.56");
    //   expect(mask("-1-2-3-4-5-6-", "2", ".", ",", true).maskedValue).toBe("-1,234.56");
    // });

    // it('0 is never negative', function () {
    //   expect(mask("0", "2", ".", ",", true).maskedValue).toBe("0.00");
    //   expect(mask("-0", "2", ".", ",", true).maskedValue).toBe("0.00");
    //   expect(mask("-0-", "2", ".", ",", true).maskedValue).toBe("0.00");
    //   expect(mask("--0-", "2", ".", ",", true).maskedValue).toBe("0.00");
    // });

    // it('just "-" should result in 0.00', function () {
    //   expect(mask("-", "2", ".", ",", true).maskedValue).toBe("0.00");
    // });

  });



  describe('with currency symbol', function () {

    // it('"$" prefix should change "0" to "$0.00"', function () {
    //   expect(mask("0", "2", ".", ",", true, "$", "").maskedValue).toBe("$0.00");
    // });

    // it('"kr" suffix should change "0" to "0.00kr"', function () {
    //   expect(mask("0", "2", ".", ",", true, "", "kr").maskedValue).toBe("0.00kr");
    // });

    // it('can have both a prefix and a suffix', function () {
    //   expect(mask("0", "2", ".", ",", true, "$", "kr").maskedValue).toBe("$0.00kr");
    // });

    // it('does not strip whitespaces between amount and symbol', function () {
    //   expect(mask("0", "2", ".", ",", true, "$ ", "").maskedValue).toBe("$ 0.00");
    //   expect(mask("0", "2", ".", ",", true, "", " kr").maskedValue).toBe("0.00 kr");
    // });

    // it('strips whitespaces before and after value', function () {
    //   expect(mask("0", "2", ".", ",", true, "  $ ", "").maskedValue).toBe("$ 0.00");
    //   expect(mask("0", "2", ".", ",", true, "", " kr   ").maskedValue).toBe("0.00 kr");
    // });


    // it('"-" should come before the prefix', function () {
    //   expect(mask("-20.00", "2", ".", ",", true, "$", "").maskedValue).toBe("-$20.00");
    // });

  });

  // describe('with minValue', () => {
  //   it('increases to minValue if less than minValue', () => {
  //     const { maskedValue, value } = mask("1001", 2, '.', ',', false, '', '', 10.02);
  //     expect(maskedValue).toBe("10.02");
  //     expect(value).toBe(10.02);
  //   })
  // })

  // describe('with maxValue', () => {
  //   it('reduces to maxValue if greater than maxValue', () => {
  //     const { maskedValue, value } = mask("1001", 2, '.', ',', false, '', '', Number.MIN_VALUE, 10.00);
  //     expect(maskedValue).toBe("10.00");
  //     expect(value).toBe(10.00);
  //   })
  // });

 

  


});
