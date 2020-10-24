export * from 'yup';
export * from './yup';

/**
 * NEVER CALL THIS FUNCTION FROM YOUR CODE. IT WILL THROW AN EXCEPTION
 *
 * setLocale is handled in `app/javascripts/common/yup/yup.ts`
 * @throws Error
 */
// eslint-disable-next-line @typescript-eslint/no-empty-function
export function setLocale():never {
	throw new Error('setLocale is handled in `app/javascripts/common/yup/yup.ts`. NEVER call this function from your code');
}
