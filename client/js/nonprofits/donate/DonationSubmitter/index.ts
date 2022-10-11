// License: LGPL-3.0-or-later

import StateManager, {DonationResult, EventObjects}  from "./StateManager";

export default class DonationSubmitter implements EventTarget {

  
  private stateManager = new StateManager();

  private eventTarget = new EventTarget();

  constructor() {

    this.stateManager.addEventListener('beginSubmit', this.handleBeginSubmit);
    this.stateManager.addEventListener('savedCard', this.handleSavedCard);
    this.stateManager.addEventListener('errored', this.handleErrored);

    this.stateManager.addEventListener('completed', this.handleCompleted);

  }


  get loading(): boolean {
    return this.stateManager.loading;
  }

  get error():string|undefined {
    return this.stateManager.error;
  }

  get progress(): number|undefined {
    return this.stateManager.progress;
  }

  get completed(): boolean {
    return this.stateManager.completed;
  }

  get result(): DonationResult|undefined {
    return this.stateManager.result;
  }

  public reportBeginSubmit():void {
    this.stateManager.reportBeginSubmit();
  }

  public reportError(error:string):void {
    this.stateManager.reportError(error);
  }

  public reportSavedCard(): void {
    this.stateManager.reportSavedCard();
  }

  public reportCompleted(result:DonationResult): void {
    this.stateManager.reportCompleted(result);
  }

  addEventListener(type: 'updated', listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions): void {
    this.eventTarget.addEventListener(type, listener, options);
  }
  dispatchEvent(event: Event): boolean {
    return this.eventTarget.dispatchEvent(event);
  }
  removeEventListener(type: 'updated', callback: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions): void {
    this.eventTarget.removeEventListener(type, callback, options);
  }

  private handleCompleted = (_evt: Event) => {
    this.dispatchEvent(new Event('updated'));
  }
  
  private handleErrored = (_evt: Event) => {
    this.dispatchEvent(new Event('updated'));
  }
  
  private handleSavedCard = (_evt: Event) => {
    this.dispatchEvent(new Event('updated'));
  }
  
  private handleBeginSubmit = (_evt: Event) => {
    this.dispatchEvent(new Event('updated'));
  }
}