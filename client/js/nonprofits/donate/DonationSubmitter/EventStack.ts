// License: LGPL-3.0-or-later
import last from 'lodash/last';
import isEqual from 'lodash/isEqual'

/**
 * EventStack is a simple class that records objects based upon their type property. One way of using it is
 * to record events and their associated data. Each object has a type property
 */
export default class EventStack<TEventObject extends {type:string}> {

  private events:Array<TEventObject> = []
  
  /**
   * Add an event to the top of the stack. If the top of the stack already has an object with the same type, then don't add it.
   * @param event an object which will be added to the top of the stack if no object with the same type is already there.
   * @returns When the top of the stack is not an object with the same type as event, then return event. Otherwise, returns undefined;
   */
  push(event: TEventObject): TEventObject | undefined {
    if (!this.top || this.top.type !== event?.type) {
      this.events.push(event)
      return event;
    }
    return undefined;
  }

  /**
   * The top event on the stack. If no events have been added, returns undefined
   */
  get top(): TEventObject | undefined {
    return last(this.events);
  }


}