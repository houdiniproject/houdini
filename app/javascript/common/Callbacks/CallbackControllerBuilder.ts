// License: LGPL-3.0-or-later
import CallbackController from "./CallbackController";

/**
 * Builds your {@link CallbackController} in a type-safe way
 *
 * @example <caption>Create a CallbackController to manage the callbacks for `validate` and `update` actions</caption>
 * // the an object containing properties to pass into your callbacks
 * type ResultHolder = {resultObject?: TResultObject} // TResultObject is an arbrary type
 * type CallbackPropsType = { inputObject: {givenName:string, familyName: string}}
 *
 * const props: CallbackPropsType = {
 * 	inputObject: {givenName: "Penelope", familyName: "Schultz"}
 * 	result: {resultObject: null}
 * }
 *
 * const controller = new CallbackControllerBuilder('create', 'update').withInputType<typeof props>();
 *
 * controller.addBeforeCallback('validate', CleanupDataBeforeValidation) // CleanupDataBeforeValidation is a class you created
 * controller.addBeforeCallback('validate', LogValidationAttempt) // LogValidationAttempt is a class you created
 * controller.addBeforeCallback('update', PrepareForUpdate) //  PrepareForUpdate is a class you created
 * controller.addAfterCallback('update', LogAfterUpdate) // LogAfterUpdate is a class you created
 *
 *
 * async function performUpdate(props:CallbackPropsType): Promise<void> {
 *   controller.run('validate', props, () => {
 * 	    // run validation action
 *   })
 *
 *   controller.run('update', props, async () => {
 * 	   // run update to get a result Object
 * 		 const result:TResultObject = await update(props)
 * 	   props.result.resultObject = result
 *   })
 * }
 *
 * await performUpdate(props:CallbackPropsType)
 * // This runs the following in order:
 * // * before callbacks for the 'validate' action:
 * //   * CleanupDataBeforeValidation.run if CleanupDataBeforeValidation.canRun() is true
 * //   * LogValidationAttempt.run if LogValidationAttempt.canRun() is true
 * // * the action passed into run with "validate"
 * // * after callbacks for 'validate' action(but not are set so nothing to run)
 * // * before callbacks for 'update' action
 * //   * PrepareForUpdate.run if PrepareForUpdate.canRun() is true
 * // * the action passed into run with "update"
 * // * after callbacks for 'update' action'
 * //   * LogAfterUpdate if LogAfterUpdate.canRun() is true
 */
export default class CallbackControllerBuilder<ActionNames extends string> {
	private readonly actionNames: ActionNames[];

	/**
	 *
	 * @param actionNames the various actions whose callbacks you want managed
	 */
	constructor(...actionNames: ActionNames[]) {
		this.actionNames = actionNames;
	}

	/**
	 * A helper method to safely type a {@link CallbackController}. You will need to explicitly set the
	 * 	{@link TInputProps} type.
	 * @template TInputProps the type of properties passed into every {@link Callback} created by the
	 * 	{@link CallbackController}
	 * @returns a strongly typed {@link CallbackController<TInputProps, ActionNames>}
	 */
	withInputType<TInputProps>(): CallbackController<TInputProps, ActionNames> {
		return new CallbackController(this.actionNames);
	}
}
