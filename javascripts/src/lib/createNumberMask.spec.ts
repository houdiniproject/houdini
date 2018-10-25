//from: https://github.com/text-mask/text-mask/pull/760/commits/f66c81b62c4894b7da43862bee5943f659dc7537
// under: Unlicense
import createNumberMask from './createNumberMask'
describe('createNumberMask', () => {
  it('can returns a configured currency mask', () => {
    let numberMask = createNumberMask()

    expect(typeof numberMask).toBe('function')
  })

  it('takes a prefix', () => {
    let numberMask = createNumberMask({prefix: '$'})

    expect(numberMask('12')).toEqual(['$', /\d/, /\d/])
  })

  it('takes a suffix', () => {
    let numberMask = createNumberMask({suffix: ' $', prefix: ''})

    expect(numberMask('12')).toEqual([/\d/, /\d/, ' ', '$'])
  })

  it('works when the prefix contains numbers', () => {
    let numberMask = createNumberMask({prefix: 'm2 '})

    expect(numberMask('m2 1')).toEqual(['m', '2', ' ', /\d/])
  })

  it('works when the suffix contains numbers', () => {
    let numberMask = createNumberMask({prefix: '', suffix: ' m2'})

    expect(numberMask('1 m2')).toEqual([/\d/, ' ', 'm', '2'])
  })

  it('works when there is a decimal and the suffix contains numbers', () => {
    let numberMask = createNumberMask({prefix: '', suffix: ' m2', allowDecimal: true})

    expect(numberMask('1.2 m2')).toEqual([/\d/, '[]', '.', '[]', /\d/, ' ', 'm', '2'])
  })

  it('can be configured to add a thousands separator or not', () => {
    let numberMaskWithoutThousandsSeparator = createNumberMask({includeThousandsSeparator: false})
    expect(numberMaskWithoutThousandsSeparator('1000')).toEqual(['$', /\d/, /\d/, /\d/, /\d/])

    let numberMaskWithThousandsSeparator = createNumberMask()
    expect(numberMaskWithThousandsSeparator('1000')).toEqual(['$', /\d/, ',', /\d/, /\d/, /\d/])
  })

  it('can be configured with a custom character for the thousands separator', () => {
    let numberMask = createNumberMask({thousandsSeparatorSymbol: '.'})

    expect(numberMask('1000')).toEqual(['$', /\d/, '.', /\d/, /\d/, /\d/])
  })

  it('can be configured to accept a fraction and returns the fraction separator with caret traps', () => {
    let numberMask = createNumberMask({allowDecimal: true})

    expect(numberMask('1000.')).toEqual(['$', /\d/, ',', /\d/, /\d/, /\d/, '[]', '.', '[]'])
  })

  it('rejects fractions by default', () => {
    let numberMask = createNumberMask()

    expect(numberMask('1000.')).toEqual(['$', /\d/, ',', /\d/, /\d/, /\d/])
  })

  it('can be configured with a custom character for the fraction separator', () => {
    let numberMask = createNumberMask({
      allowDecimal: true,
      decimalSymbol: ',',
      thousandsSeparatorSymbol: '.'
    })

    expect(numberMask('1000,')).toEqual(['$', /\d/, '.', /\d/, /\d/, /\d/, '[]', ',', '[]'])
  })

  it('can limit the length of the fraction', () => {
    let numberMask = createNumberMask({allowDecimal: true, decimalLimit: 2})

    expect(numberMask('1000.3823')).toEqual(['$', /\d/, ',', /\d/, /\d/, /\d/, '[]', '.', '[]', /\d/, /\d/])
  })

  it('can require a fraction', () => {
    let numberMask = createNumberMask({requireDecimal: true})

    expect(numberMask('1000')).toEqual(['$', /\d/, ',', /\d/, /\d/, /\d/, '[]', '.', '[]'])
  })

  it('accepts negative integers', function() {
    let numberMask = createNumberMask({allowNegative: true})
    expect(numberMask('-$12')).toEqual([/-/, '$', /\d/, /\d/])
  })

  it('ignores multiple minus signs', function() {
    let numberMask = createNumberMask({allowNegative: true})
    expect(numberMask('--$12')).toEqual([/-/, '$', /\d/, /\d/])
  })

  it('adds a digit placeholder if the input is nothing but a minus sign in order to attract the caret', () => {
    let numberMask = createNumberMask({allowNegative: true})
    expect(numberMask('-')).toEqual([/-/, '$', /\d/])
  })

  it('starts with dot should be considered as decimal input', () => {
    let numberMask = createNumberMask({prefix: '$', allowDecimal: true})
    expect(numberMask('.')).toEqual(['$', '0', '.', /\d/])

    numberMask = createNumberMask({prefix: '#', allowDecimal: true})
    expect(numberMask('.')).toEqual(['#', '0', '.', /\d/])

    numberMask = createNumberMask({prefix: '', allowDecimal: true})
    expect(numberMask('.')).toEqual(['0', '.', /\d/])

    numberMask = createNumberMask({allowDecimal: false})
    expect(numberMask('.')).toEqual(['$'])

    numberMask = createNumberMask({prefix: '', suffix: '$', allowDecimal: true})
    expect(numberMask('.')).toEqual(['0', '.', /\d/, '$'])
  })

  it('can allow leading zeroes', function() {
    let numberMask = createNumberMask({allowLeadingZeroes: true})
    expect(numberMask('012')).toEqual(['$', /\d/, /\d/, /\d/])
  })

  it('works with large numbers when leading zeroes is false', function() {
    let numberMask = createNumberMask({allowLeadingZeroes: false})
    expect(numberMask('111111111111111111111111')).toEqual([
      '$', /\d/, /\d/, /\d/, ',', /\d/, /\d/, /\d/, ',', /\d/, /\d/, /\d/, ',', /\d/, /\d/, /\d/, ',',
      /\d/, /\d/, /\d/, ',', /\d/, /\d/, /\d/, ',', /\d/, /\d/, /\d/, ',', /\d/, /\d/, /\d/
    ])
  })

  describe('integer limiting', () => {
    it('can limit the length of the integer part', () => {
      let numberMask = createNumberMask({integerLimit: 3})
      expect(numberMask('1999')).toEqual(['$', /\d/, /\d/, /\d/])
    })

    it('works when there is a prefix', () => {
      let numberMask = createNumberMask({integerLimit: 3, prefix: '$'})
      expect(numberMask('$1999')).toEqual(['$', /\d/, /\d/, /\d/])
    })

    it('works when there is a thousands separator', () => {
      expect(createNumberMask({integerLimit: 4, prefix: ''})('1,9995'))
        .toEqual([/\d/, ',', /\d/, /\d/, /\d/])

      expect(createNumberMask({integerLimit: 7, prefix: ''})('1,000,0001'))
        .toEqual([/\d/, ',', /\d/, /\d/, /\d/, ',', /\d/, /\d/, /\d/])
    })

    it('works when there is a decimal and a prefix', () => {
      let numberMask = createNumberMask({integerLimit: 3, allowDecimal: true})
      expect(numberMask('$199.34')).toEqual(['$', /\d/, /\d/, /\d/, '[]', '.', '[]', /\d/, /\d/])
    })

    it('works when there is a decimal and no prefix', () => {
      let numberMask = createNumberMask({integerLimit: 3, allowDecimal: true, prefix: ''})
      expect(numberMask('199.34')).toEqual([/\d/, /\d/, /\d/, '[]', '.', '[]', /\d/, /\d/])
    })

    it('works when thousandsSeparatorSymbol is a period', () => {
      let numberMask = createNumberMask({
        prefix: '',
        thousandsSeparatorSymbol: '.',
        decimalSymbol: ',',
        allowDecimal: true,
        requireDecimal: true,
        integerLimit: 5,
        decimalLimit: 3,
      })
      expect(numberMask('1234567890,12345678'))
        .toEqual([/\d/, /\d/, '.', /\d/, /\d/, /\d/, '[]', ',', '[]', /\d/, /\d/, /\d/])
    })
  })

  describe('numberMask default behavior', () => {
    let numberMask:ReturnType<typeof createNumberMask> = null

    beforeEach(() => {
      numberMask = createNumberMask()
    })

    it('returns a mask that has the same number of digits as the given number', () => {
      expect(numberMask('20382')).toEqual(['$', /\d/, /\d/, ',', /\d/, /\d/, /\d/])
    })

    it('uses the dollar symbol as the default prefix', () => {
      expect(numberMask('1')).toEqual(['$', /\d/])
    })

    it('adds no suffix by default', () => {
      expect(numberMask('1')).toEqual(['$', /\d/])
    })

    it('returns a mask that appends the currency symbol', () => {
      expect(numberMask('1')).toEqual(['$', /\d/])
    })

    it('adds adds a comma after a thousand', () => {
      expect(numberMask('1000')).toEqual(['$', /\d/, ',', /\d/, /\d/, /\d/])
    })

    it('adds as many commas as needed', () => {
      expect(numberMask('23984209342084'))
        .toEqual(
          ['$', /\d/, /\d/, ',', /\d/, /\d/, /\d/, ',', /\d/, /\d/, /\d/, ',', /\d/, /\d/, /\d/, ',', /\d/, /\d/, /\d/]
        )
    })

    it('accepts any string and strips out any non-digit characters', () => {
      expect(numberMask('h4x0r sp43k')).toEqual(['$', /\d/, ',', /\d/, /\d/, /\d/])
    })

    it('does not allow leading zeroes', function() {
      let numberMask = createNumberMask()
      expect(numberMask('012')).toEqual(['$', /\d/, /\d/])
    })

    it('allows one leading zero followed by a fraction', function() {
      let numberMask = createNumberMask({allowDecimal: true})
      expect(numberMask('0.12')).toEqual(['$', /\d/, '[]', '.', '[]', /\d/, /\d/])
    })

    it('ignores fixedDecimalScale when requireDecimal:false', () => {
      let numberMask = createNumberMask({allowDecimal: true, fixedDecimalScale:true})
      expect(numberMask('0.1')).toEqual(['$', /\d/, '[]', '.', '[]', /\d/])
    })

    it('fixedDecimalScale expands decimal', () => {
      let numberMask = createNumberMask({requireDecimal: true, fixedDecimalScale:true})
      expect(numberMask('0.1')).toEqual(['$', /\d/, '[]', '.', '[]', /\d/, /\d/])
    })
  })
})