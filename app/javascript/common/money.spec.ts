import {Money} from './money'
import 'jest';

describe("Money", () => {
    describe('Money.fromCents',() => {
        it('succeeds from a old Money object', () => {
            const old = Money.fromCents(333, 'eur')

            const result = Money.fromCents(old)
            expect(result).toEqual(old)

            expect(result).not.toBe(old)
        })
        it('succeeds from a json', () => {
            const old = {amount:333, currency:'eur'}

            const result = Money.fromCents(old)
            expect(result).toEqual(old)

            expect(result).toBeInstanceOf(Money)
        })

        it('succeeds from function parameters', () => {
            const result = Money.fromCents(333, 'eur')
            expect(result).toEqual({amount:333, currency:'eur'})

            expect(result).toBeInstanceOf(Money)
        })
    })
})
