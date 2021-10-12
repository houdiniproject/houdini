
// License: LGPL-3.0-or-later

export function IsNetworkError(err:unknown): err is NetworkErrorLike {
	return err instanceof NetworkError || Object.prototype.hasOwnProperty.call(err, 'status');
}

interface NetworkErrorLike {
	readonly data?: unknown;
	readonly status?: number;
}

export class NetworkError extends Error implements NetworkErrorLike {
	public readonly data?: unknown;
	public readonly status?: number;

	constructor(response: { data?: unknown, status?: number }) {
		super(`status: ${response.status}${response.data ? `, data: ${JSON.stringify(response.data)}` : ''}`);
		Object.setPrototypeOf(this, new.target.prototype);
		this.status = response.status;
		this.data = response.data;
		Object.freeze(this);
	}
}


export class SignInError extends NetworkError {
	public readonly data?: { error: string[] };
	constructor({ status, data }: { data?: { error: string[]|string }, status?: number }) {
		if (data) {
			if (data.error instanceof Array){
				data = {...data, ...{error: data.error as string[]}};
			}
			else {
				data = {...data, ...{error: [data.error]}};
			}
		}
		super({data, status});
		Object.setPrototypeOf(this, new.target.prototype);
		Object.freeze(this);
	}
}
