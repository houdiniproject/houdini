// License: LGPL-3.0-or-later
// based upon https://github.com/davidkalosi/js-money
import BigNumber from 'bignumber.js';
import has from 'lodash/has';

/**
 * Forces BigNumber to throw an error if it receives an invalid numerical value.
 */
function bigNumberDebug<T>(func: () => T):T {
	const previousDebug = BigNumber.DEBUG;
	try {
		BigNumber.DEBUG = true;
		return func();
	}
	finally {
		BigNumber.DEBUG = previousDebug;
	}
}

function assertSameCurrency(left: Money, right: Operand) {
	if (right instanceof Money && left.currency !== right.currency)
		throw new TypeError('Different currencies');
}

function innerCoerceToBigNumber(operand:unknown):BigNumber {
	if (operand instanceof Money) {
		return operand.toBigNumber();
	}
	else if (operand instanceof BigNumber) {
		return new BigNumber(operand);
	}
	else if (typeof operand === 'object') {
		//it's MoneyAsJson
		return  new BigNumber((operand as MoneyAsJson).cents);
	}
	else if(typeof operand === 'string') {
		return bigNumberDebug(() => {
			return  new BigNumber(operand);
		});
	}
	else if (typeof operand === 'number') {
		return bigNumberDebug(() => {
			return new BigNumber(operand);
		});
	}
	else {
		throw new TypeError('Operand must be coercible to a BigNumber');
	}
}


function coerceToBigNumber(operand:unknown, mustBeInteger=false): BigNumber {
	const bigNumber = innerCoerceToBigNumber(operand);
	if (mustBeInteger && !bigNumber.isInteger()) {
		throw new TypeError('Operand must be an integer');
	}

	return bigNumber;
}

function includesCurrency(amount:number | BigNumber | string | Money | MoneyAsJson | StringyMoneyAsJson) : amount is Money | MoneyAsJson | StringyMoneyAsJson {
	return typeof amount == 'object' && (amount instanceof Money || has(amount, 'currency'));
}

function coerceToCurrencyWithObj(amount:Money | MoneyAsJson | StringyMoneyAsJson) {
	return amount.currency;
}

function coerceToCurrency(amount:number | BigNumber | Money | MoneyAsJson | string | StringyMoneyAsJson, currency?:string): string {
	if (includesCurrency(amount)) {
		return coerceToCurrencyWithObj(amount);
	} else {
		if (!currency) {
			throw new Error("you must provide a currency here but this should never happen");
		}
		return currency;
	}
}

export type MoneyAsJson = { cents: number, currency: string };
type StringyMoneyAsJson = { cents:string, currency: string };

export type Operand = number | Money | BigNumber | string;

export enum RoundingMode {
	/** Rounds away from zero. */
	Up = 0,

	/** Rounds towards zero. */
	Down,

	/** Rounds towards Infinity. */
	Ceil,

	/** Rounds towards -Infinity. */
	Floor,

	/** Rounds towards nearest neighbour. If equidistant, rounds away from zero . */
	HalfUp,

	/** Rounds towards nearest neighbour. If equidistant, rounds towards zero. */
	HalfDown,

	/** Rounds towards nearest neighbour. If equidistant, rounds towards even neighbour. */
	HalfEven,

	/** Rounds towards nearest neighbour. If equidistant, rounds towards Infinity. */
	HalfCeil,

	/** Rounds towards nearest neighbour. If equidistant, rounds towards -Infinity. */
	HalfFloor,
}

/**
 * Represents a monetary amount. For safety, all Money objects are immutable. All of the functions in this class create a new Money object.
 *
 * Money always represents a whole number of the smallest monetary unit. It can never be fractional. Multiplication and division always rounds to
 * and integer (see the `RoundingMode` )
 *
 *
 * To create a new Money object is to use the `fromCents` function.
 * @export
 * @class Money
 */
export class Money {



	/**
	* Create a `Money` object with the given number if smallest monetary units and the ISO currency. Another name for the `fromCents` function.
	* @static
	* @memberof Money
	*/
	static fromSMU = Money.fromCents;

	/**
	 * The currency of the monetary value, always in lower case.
	 */
	readonly currency: string;

	protected constructor(readonly cents: number, currency: string) {
		this.currency = currency.toLowerCase();
		const methodsToBind = [this.equals, this.add, this.subtract, this.multiply, this.divide,
			this.compare, this.greaterThan, this.greaterThanOrEqual, this.lessThan,
			this.lessThanOrEqual, this.isZero, this.isPositive, this.isNegative,
			this.toJSON];
		methodsToBind.forEach((func) => Object.bind(func));

		Object.freeze(this);
	}

	/**
	 * Create a new money object
	 * @param amount the value of Money as an object of type {amount:number, currency:string}. `amount` must be an integer
	 * or `TypeError` will be thrown.
	 */
	static fromCents(amount: MoneyAsJson): Money;

	/**
	 * Create a new money object
	 * @param amount  the value of Money as an object of type {amount:string, currency:string}. `amount` must contain an integer
	 * or `TypeError` will be thrown.
	 */
	static fromCents(amount: StringyMoneyAsJson): Money;
	/**
	 * Create a new money object
	 * @param amount a Money object that will be replicated to create a new Money object
	 */
	static fromCents(amount: Money): Money;
	/**
	 * Create a new money object.
	 * @param amount an integer representing the amount of the new Money object. If you pass a non-integer, `TypeError` will be thrown.
	 * @param currency the currency of the new Money object
	 */
	static fromCents(amount: number, currency: string): Money;
	/**
	 * Create a new money object
	 * @param amount a string containing the integer of the amount of the new Money object. If you pass a non-integer, `TypeError` will be thrown.
	 * @param currency the currency of the new Money object
	 */
	static fromCents(amount: string, currency: string): Money;
	/**
	 *
	 * @param amount a BigNumber containing the integer of the amount of the new Money object. If you pass a non-integer, `TypeError` will be thrown.
	 * @param currency the currency of the new Money object
	 */
	static fromCents(amount: BigNumber, currency: string): Money;
	/**
	 * The overloaded function that allows all of the previous constructors
	 */
	static fromCents(amount: number | BigNumber | Money | MoneyAsJson | string | StringyMoneyAsJson, currency?: string): Money {
		return new Money(coerceToBigNumber(amount, true).toNumber(), coerceToCurrency(amount, currency));
	}

	/**
	* Adds the two objects together creating a new Money instance that holds the result of the operation.
	*
	* @param other an object represented an integer value to add the current Money object. If it's a Money object,
	* the currency must match or `TypeError` will be thrown. If not, it must be an integer or `TypeError` is thrown.
	*/
	add(other: Operand): Money {

		const bigNumber = coerceToBigNumber(other, true);
		assertSameCurrency(this, other);

		return new Money(this.toBigNumberWithNoDecimals().plus(bigNumber).toNumber(), this.currency);
	}

	/**
	* Compares another numerical value with this Money object.
	*
	* @param other the numerical value to compare against this Money object. If `other` is a `Money` object,
	* the currencies must match or a `TypeError` is thrown.
	* @returns -1 if smaller than other, 0 if equal to other, 1 if greater than other.
	*/
	compare(other: Operand): number {


		const bigNumber = coerceToBigNumber(other);
		assertSameCurrency(this, other);

		return this.toBigNumberWithNoDecimals().comparedTo(bigNumber);
	}

	/**
	 * Divides the object by the divisor returning a new Money instance that holds the result of the operation.
	 *
	 * @param divisor an object represented a numerical value to divide the current Money object by. If it's a Money object,
	 * the currency must match or `TypeError` will be thrown.
	 * @param roundingMode the rounding mode to use if the result of the division would otherwise lead to a non-integer Money value. By default,
	 * we use the `RoundingMode.HalfUp` mode.
	 */
	divide(divisor: Operand, roundingMode: RoundingMode = RoundingMode.HalfUp): Money {
		assertSameCurrency(this, divisor);
		return new Money(this.toBigNumberWithNoDecimals(roundingMode).dividedBy(coerceToBigNumber(divisor)).toNumber(), this.currency);
	}


	/**
	* Returns true if the two instances of Money are equal, false otherwise.
	*
	* @param other an object represented a numerical value to compare to the current Money object to. If `other` is
	* a `Money` object, the currency must match for this to return true.
	*/
	equals(other: Operand): boolean {
		return this.toBigNumberWithNoDecimals().isEqualTo(coerceToBigNumber(other)) &&
			(other instanceof Money ? this.currency === other.currency : false);
	}

	/**
	* Checks whether the value represented by this object is greater than the other.
	*
	* @param other an object represented a numerical value to compare to the current Money object to. If `other`
	* is a Money instance, the currency must match or `TypeError` will be thrown.
	*/
	greaterThan(other: Operand): boolean {
		assertSameCurrency(this, other);
		return this.toBigNumberWithNoDecimals().isGreaterThan(coerceToBigNumber(other));
	}

	/**
	* Checks whether the value represented by this object is greater or equal to the other.
	*
	* @param other an object represented a numerical value to compare to the current Money object to. If `other`
	* is a Money instance, the currency must match or `TypeError` will be thrown.
	*/
	greaterThanOrEqual(other: Operand): boolean {
		assertSameCurrency(this, other);
		return this.toBigNumberWithNoDecimals().isGreaterThanOrEqualTo(coerceToBigNumber(other));
	}

	/**
	 * Returns true if the amount is negative
	 *
	 */
	isNegative(): boolean {
		return this.toBigNumberWithNoDecimals().isNegative();
	}

	/**
	* Returns true if the amount is positive.
	*
	*/
	isPositive(): boolean {
		return this.toBigNumberWithNoDecimals().isPositive();
	}

	/**
	* Returns true if the amount is zero.
	*/
	isZero(): boolean {
		return this.toBigNumberWithNoDecimals().isZero();
	}

	/**
	* Checks whether the value represented by this object is less than the other.
	*
	* @param other an object represented a numerical value to compare to the current Money object to. If `other`
	* is a Money instance, the currency must match or `TypeError` will be thrown.
	*/
	lessThan(other: Operand): boolean {

		assertSameCurrency(this, other);
		return this.toBigNumberWithNoDecimals().isLessThan(coerceToBigNumber(other));
	}

	/**
	* Checks whether the value represented by this object is less than or equal to the other.
	*
	* @param other an object represented a numerical value to compare to the current Money object to. If `other`
	* is a Money instance, the currency must match or `TypeError` will be thrown.
	*/
	lessThanOrEqual(other: Money): boolean {
		assertSameCurrency(this, other);
		return this.toBigNumberWithNoDecimals().isLessThanOrEqualTo(coerceToBigNumber(other));
	}

	/**
	 * Multiplies the object by the multiplier returning a new Money instance that holds the result of the operation.
	 *
	 * @param multiplier an object represented a numerical value to multiply the current Money object by. If it's a Money object,
	 * the currency must match or `TypeError` will be thrown.
	 * @param roundingMode the rounding mode to use if the result of the multiplication would otherwise lead to a non-integer Money value. By default,
	 * we use the `RoundingMode.HalfUp` mode.
	 */
	multiply(multiplier: Operand, roundingMode: RoundingMode = RoundingMode.HalfUp): Money {
		assertSameCurrency(this, multiplier);
		const unrounded = this.toBigNumberWithNoDecimals(roundingMode).multipliedBy(coerceToBigNumber(multiplier));

		return new Money(unrounded.decimalPlaces(0, roundingMode).toNumber(), this.currency);
	}

	/**
	 * Subtracts the two objects creating a new Money instance that holds the result of the operation.
	 *
	 * @param other an object represented an integer value to subtract from the current Money object. If it's a Money object,
	 * the currency must match or `TypeError` will be thrown. If not, it must be an integer or `TypeError` is thrown.
	 */
	subtract(other: Operand): Money {
		assertSameCurrency(this, other);
		return new Money(this.toBigNumberWithNoDecimals().minus(coerceToBigNumber(other, true)).toNumber(), this.currency);
	}

	/**
	 * Get the amount of the Money instance as a `BigNumber`.
	 */
	toBigNumber() : BigNumber {
		return new BigNumber(this.cents);
	}

	/**
	* Returns a serialized version of the instance.
	*
	* @returns {{amount: number, currency: string}}
	*/
	toJSON(): MoneyAsJson {
		return {
			cents: this.cents,
			currency: this.currency,
		};
	}

	private toBigNumberWithNoDecimals(roundingMode?:RoundingMode) : BigNumber {
		const config:BigNumber.Config = {
			DECIMAL_PLACES: 0,
		};

		if (roundingMode) {
			config.ROUNDING_MODE = roundingMode;
		}

		return  new (BigNumber.clone(config))(this.toBigNumber());
	}
}