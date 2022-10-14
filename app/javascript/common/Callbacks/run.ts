// License: LGPL-3.0-or-later
import Callback from "./Callback";


/**
 * A very simple function for conditionally running callbacks. Move into own file because we can mock it for CallbackController
 * @param input The input properties to every callback
 * @param callbacks callbacks to be run
 */
export default async function run<TCallbackInput>(input: TCallbackInput, callbacks: ReadonlyArray<{ new(input: TCallbackInput): Callback<TCallbackInput> }>): Promise<void> {
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