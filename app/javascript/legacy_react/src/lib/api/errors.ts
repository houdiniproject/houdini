
// License: LGPL-3.0-or-later
export class SignInError extends Error {
	public readonly data?: { error: string[] };
	public readonly status?: number;
	constructor({ status, data }: { data?: { error: string[]|string }, status?: number }) {
		super(`status: ${status}, data: ${JSON.stringify(data)}`);
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
