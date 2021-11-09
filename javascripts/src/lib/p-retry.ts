// License: MIT
// From: https://github.com/sindresorhus/p-retry/blob/master/index.js
const retry = require('retry');

export class AbortError extends Error {
    originalError:any
	constructor(message:any) {
		super();

		if (message instanceof Error) {
			this.originalError = message;
			({message} = message);
		} else {
			this.originalError = new Error(message);
			this.originalError.stack = this.stack;
		}

		this.name = 'AbortError';
		this.message = message;
	}
}

const decorateErrorWithCounts = (error:any, attemptNumber:number, options:any) => {
	// Minus 1 from attemptNumber because the first attempt does not count as a retry
	const retriesLeft = options.retries - (attemptNumber - 1);

	error.attemptNumber = attemptNumber;
	error.retriesLeft = retriesLeft;
	return error;
};

const pRetry = <T>(input:(attemptNumber:number)=>Promise<T>, options:any) => new Promise<T>((resolve, reject) => {
	options = {
		onFailedAttempt: () => {},
		retries: 10,
		factor: 1,
		...options
	};

	const operation = retry.operation(options);

	operation.attempt(async (attemptNumber:any) => {
		try {
			resolve(await input(attemptNumber));
		} catch (error) {
			if (!(error instanceof Error)) {
				reject(new TypeError(`Non-error was thrown: "${error}". You should only throw errors.`));
				return;
			}

			if (error instanceof AbortError) {
				operation.stop();
				reject(error.originalError);
			} else if (error instanceof TypeError) {
				operation.stop();
				reject(error);
			} else {
				decorateErrorWithCounts(error, attemptNumber, options);

				try {
					await options.onFailedAttempt(error);
				} catch (error) {
					reject(error);
					return;
				}

				if (!operation.retry(error)) {
					reject(operation.mainError());
				}
			}
		}
	});
});

export default pRetry;