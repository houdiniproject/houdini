
// License: LGPL-3.0-or-later

export class NetworkError extends Error {
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
	public readonly status?: number;
	constructor({ status, data }: { data?: { error: string[]|string }, status?: number }) {
		super({data, status});
		Object.setPrototypeOf(this, new.target.prototype);
		this.status = status;
		if (data) {
			if (data.error instanceof Array){
				this.data = {...data, ...{error: data.error as string[]}};
			}
			else {
				this.data = {...data, ...{error: [data.error]}};
			}
		}
		Object.freeze(this);
	}
}
