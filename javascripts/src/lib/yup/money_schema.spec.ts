import 'jest';
import { MoneySchema } from "./money_schema";
import { Money } from '../money';
import {number as locale} from 'yup/lib/locale'
describe('MoneySchema', () => {

  it('valid object works', async () => {

    let schema = new MoneySchema()
    await schema.validate(Money.fromCents(100, 'usd'))
  })

  describe('.negative', () => {
    const schema = new MoneySchema().negative()
    it('null value is true', () => {
      expect(schema.isValidSync(null)).toBeTruthy()
    })

    it('empty number value is false', () => {
      expect(schema.isValidSync({currency: 'nns'})).toBeFalsy()
    })

    it('negative number is true', () => {
      expect(schema.isValidSync(Money.fromCents(-1, 'usd'))).toBeTruthy()
    })

    it('zero is false', () => {
      expect(schema.isValidSync(Money.fromCents(0, 'usd'))).toBeFalsy()
    })

    it('postive number is false', () => {
      expect(schema.isValidSync(Money.fromCents(1, 'usd'))).toBeFalsy()
    })

    it('errors correctly', () => {
        expect(() => schema.validateSync(Money.fromCents(1, 'usd'))).toThrowError(locale.negative.replace('${path}', 'this')) 
    })
  })

  describe('.positive', () => {
    const schema = new MoneySchema().positive()
    it('null value is true', () => {
      expect(schema.isValidSync(null)).toBeTruthy()
    })

    it('empty number value is false', () => {
      expect(schema.isValidSync({currency: 'nns'})).toBeFalsy()
    })

    it('positive number is true', () => {
      expect(schema.isValidSync(Money.fromCents(1, 'usd'))).toBeTruthy()
    })

    it('zero is false', () => {
      expect(schema.isValidSync(Money.fromCents(0, 'usd'))).toBeFalsy()
    })

    it('negative number is false', () => {
      expect(schema.isValidSync(Money.fromCents(-1, 'usd'))).toBeFalsy()
    })
    
    it('errors correctly', () => {
      expect(() => schema.validateSync(Money.fromCents(-1, 'usd'))).toThrowError(locale.positive.replace('${path}', 'this')) 
    })

  })

  describe('.max', () => {
    const schema = new MoneySchema().max(400)
    it('null value is true', () => {
      expect(schema.isValidSync(null)).toBeTruthy()
    })

    it('empty number value is false', () => {
      expect(schema.isValidSync({currency: 'nns'})).toBeFalsy()
    })

    it('less than 4 is true', () => {
      expect(schema.isValidSync(Money.fromCents(300, 'usd'))).toBeTruthy()
    })

    it('4 is true', () => {
      expect(schema.isValidSync(Money.fromCents(400, 'usd'))).toBeTruthy()
    })

    it('5 is false', () => {
      expect(schema.isValidSync(Money.fromCents(500, 'usd'))).toBeFalsy()
    })

    it('errors correctly', () => {
      expect(() => schema.validateSync(Money.fromCents(500, 'usd'))).toThrowError(locale.max.replace('${path}', 'this').replace('${max}', '$4.00')) 
    })
  })


  describe('.min', () => {
    const schema = new MoneySchema().min(400)
    it('null value is true', () => {
      expect(schema.isValidSync(null)).toBeTruthy()
    })

    it('empty number value is false', () => {
      expect(schema.isValidSync({currency: 'nns'})).toBeFalsy()
    })

    it('less than 4 is false', () => {
      expect(schema.isValidSync(Money.fromCents(300, 'usd'))).toBeFalsy()
    })

    it('4 is true', () => {
      expect(schema.isValidSync(Money.fromCents(400, 'usd'))).toBeTruthy()
    })

    it('5 is true', () => {
      expect(schema.isValidSync(Money.fromCents(500, 'usd'))).toBeTruthy()
    })

    it('errors correctly', () => {
      expect(() => schema.validateSync(Money.fromCents(300, 'usd'))).toThrowError(locale.min.replace('${path}', 'this').replace('${min}', "$4.00")) 
    })
  })


  describe('.lessThan', () => {
    const schema = new MoneySchema().lessThan(400)
    it('null value is true', () => {
      expect(schema.isValidSync(null)).toBeTruthy()
    })

    it('empty number value is false', () => {
      expect(schema.isValidSync({currency: 'nns'})).toBeFalsy()
    })

    it('less than 4 is true', () => {
      expect(schema.isValidSync(Money.fromCents(300, 'usd'))).toBeTruthy()
    })

    it('4 is false', () => {
      expect(schema.isValidSync(Money.fromCents(400, 'usd'))).toBeFalsy()
    })

    it('5 is false', () => {
      expect(schema.isValidSync(Money.fromCents(500, 'usd'))).toBeFalsy()
    })

    it('errors correctly', () => {
      expect(() => schema.validateSync(Money.fromCents(500, 'usd'))).toThrowError(locale.lessThan.replace('${path}', 'this').replace('${less}', '$4.00')) 
    })
  })


  describe('.lessThan', () => {
    const schema = new MoneySchema().moreThan(400)
    it('null value is true', () => {
      expect(schema.isValidSync(null)).toBeTruthy()
    })

    it('empty number value is false', () => {
      expect(schema.isValidSync({currency: 'nns'})).toBeFalsy()
    })

    it('less than 4 is false', () => {
      expect(schema.isValidSync(Money.fromCents(300, 'usd'))).toBeFalsy()
    })

    it('4 is false', () => {
      expect(schema.isValidSync(Money.fromCents(400, 'usd'))).toBeFalsy()
    })

    it('5 is true', () => {
      expect(schema.isValidSync(Money.fromCents(500, 'usd'))).toBeTruthy()
    })

    it('errors correctly', () => {
      expect(() => schema.validateSync(Money.fromCents(300, 'usd'))).toThrowError(locale.moreThan.replace('${path}', 'this').replace('${more}', '$4.00')) 
    })
  })
})
