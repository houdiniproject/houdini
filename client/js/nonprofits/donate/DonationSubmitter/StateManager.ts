// License: LGPL-3.0-or-later
import EventStack from "./EventStack";

export type DonationResult = {charge?: {amount?:number}}

export type EventObjects = {
  type: 'beginSubmit' |'savedCard' 
} | {
  type: 'errored', error:string
} | {
  type: 'completed',
  result: DonationResult,
};

function isCompletedEvent(event?:EventObjects|undefined): event is  {
  type: 'completed',
  result: DonationResult,
} {
  return !!(event && event.type === 'completed');

}

type StateEventTypes =  'beginSubmit'| 'savedCard' | 'completed' | 'errored'

export default class StateManager implements EventTarget{

  private events = new EventStack<EventObjects>();

  private eventTarget = new EventTarget();


  get loading(): boolean {
    const lastEvent = this.events.top;
    return !!(lastEvent && (lastEvent.type === 'beginSubmit' || lastEvent.type === 'savedCard'));
  }

  get error():string|undefined {
    const lastEvent = this.events.top;
    if (lastEvent && lastEvent.type === 'errored') {
      return lastEvent.error;
    }
    return undefined;
  }

  get completed(): boolean {
    const lastEvent = this.events.top
    return isCompletedEvent(lastEvent);
  }

  get result(): DonationResult | undefined {
    const lastEvent = this.events?.top;

    return isCompletedEvent(lastEvent) ? lastEvent.result : undefined;
  }

  get progress(): number|undefined {
    const lastEvent = this.events.top;
    if (lastEvent?.type === 'beginSubmit') {
      return 20;
    }
    else if (lastEvent?.type === 'savedCard') {
      return 100;
    }
    else {
      return undefined;
    }
  }

  public reportBeginSubmit():void {
    if (this.events.push({type: 'beginSubmit'})) {
      this.dispatchEvent(new Event('beginSubmit'));
    };
  }

  public reportError(error:string):void {
    if (this.events.push({type: 'errored', error})) {
      this.dispatchEvent(new Event('errored'));
    }
  }

  public reportSavedCard(): void {
    if (this.events.push({type: 'savedCard'})) {
      this.dispatchEvent(new Event('savedCard'));
    }
  }

  public reportCompleted(result:DonationResult): void {
    if (this.events.push({type: 'completed', result})) {
      this.dispatchEvent(new Event('completed'));
    }
  }

  addEventListener(type: StateEventTypes, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void {
    this.eventTarget.addEventListener(type, listener, options);
  }
  dispatchEvent(event: Event): boolean {
    return this.eventTarget.dispatchEvent(event);
  }
  removeEventListener(type: StateEventTypes, callback: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void {
    this.eventTarget.removeEventListener(type, callback, options);
  }

  
}