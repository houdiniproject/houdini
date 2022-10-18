// License: LGPL-3.0-or-later
import type { CallbackClass } from "./types";


/**
 * A very simple function for conditionally running callbacks. Move into own file because we can mock it for CallbackController
 * @param input The input properties to every callback
 * @param callbacks callbacks as classes to be run
 * @template TCallbackProps the properties to be passed into the constructor of each Callback
 * @returns {Promise<void>} a promise resolving on completion of all of the callbacks. Doesn't currently ever reject.
 */
export default async function run<TCallbackProps>(input: TCallbackProps, callbacks: readonly CallbackClass<TCallbackProps>[]): Promise<void> {
	try {
		for (const callback of callbacks) {
			const obj = new callback(input);

			if (obj.canRun()) {
				try {
					await obj.run();
				}
				catch (e) {
					obj.catchError(e);
				}
			}
		}
	}
	catch (e) {
		console.error(`Runner failed with ${e}`);
	}

}