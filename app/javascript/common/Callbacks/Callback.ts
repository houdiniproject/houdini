// License: LGPL-3.0-or-later

/**
 * Describes an callback for some sort of change in an object. Kind of similar ActiveSupport::Callbacks
 */
export default class Callback<T> {
	constructor(public readonly props: T) {

	}

	/**
   * A boolean method deciding whether .run should be called. By default it's true but can be overriden in subclasses.
	 * @returns true if this callback should be run, false if it should not.
   */
	canRun(): boolean {
		return true;
	}

	/**
   * Catches any errors thrown when running .run. By default, this simply rethrows the error.
   * Child classes could use this to suppress some errors or rethrow a different error
   *
   * @param e the error caught
   */
	catchError(e: unknown) {
		throw e;
	}

	/**
   * Runs the callback itself. Must be implemented in a child class.
   * @return a Promise<void> or void
   */
	run(): Promise<void> | void {
		throw new Error("You need to implement 'run' in your child class");
	}
}