// License: LGPL-3.0-or-later
import last from 'lodash/last';
import isEqual from 'lodash/isEqual'


interface EventObjectBase {
  type: string
}

/**
 * A simple class for recording the list of events that occurred for a system
 */
export default class EventStack<TEventObjects extends EventObjectBase> {

  private events:Array<TEventObjects> = []

  push(event: TEventObjects): TEventObjects | undefined {
    if (!this.top) {
      this.events.push(event)
      return event;
    }
    else if (!isEqual(this.top, event)) {
      this.events.push(event);
      return event;
    }
    return undefined;
  }

  get top(): TEventObjects | undefined {
    return last(this.events);
  }


}