// License: LGPL-3.0-or-later
import Callback from "./Callback";

// eslint-disable-next-line @typescript-eslint/no-unused-vars -- used for doc
import type CallbackController from "./CallbackController";


export type CallbackClass<CallbackProps> = typeof Callback<CallbackProps>;


/**
 * Contains the {@link CallbackClass}'s to be run before or after an action occurs. These callback are run in order for
 * each filter type
 * @template TCallbackClass the superclass of all the Classes to be run.
 */

export interface CallbackFilters<TCallbackClass> {

  /**
   * The callbacks to run before the action occurs.
   */
  readonly after: readonly TCallbackClass[];

  /**
   * The callback to run after the action occurs
   */
  readonly before: readonly TCallbackClass[];
}

export type CallbackMap<CallbackProps, ActionNames extends string> = ReadonlyMap<ActionNames, CallbackFilters<CallbackClass<CallbackProps>>>;

/**
 * Get callbacks handled by an object. {@link CallbackController} implements this but it's possible you might have a class that
 * contains a {@link CallbackController} and implements this by proxying it to CallbackController.
 *
 * @template CallbackProps the type available in each {@link Callback} at {@link Callback.props}
 * @template ActionNames the names of the various actions which callbacks will occur on.
 * @hideConstructor
 */
export interface CallbackAccessor<CallbackInput extends unknown, // eslint-disable-line @typescript-eslint/no-unnecessary-type-constraint
  ActionNames extends string> {

  /**
   * All callbacks registered on an object. Either part of a controller but might also be
   */
  callbacks(): CallbackMap<CallbackInput, ActionNames>;
  callbacks(actionName: ActionNames): CallbackFilters<CallbackClass<CallbackInput>> | undefined;
  callbacks(actionName?: ActionNames): CallbackMap<CallbackInput, ActionNames> | CallbackFilters<CallbackClass<CallbackInput>> | undefined;
}



