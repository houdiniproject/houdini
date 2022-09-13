// License: LGPL-3.0-or-later

import StateManager, {DonationResult, EventObjects}  from "./StateManager";

export default class DonationSubmitter implements EventTarget {

  
  private stateManager = new StateManager();

  private eventTarget = new EventTarget();

  constructor() {

    Object.bind(this, this.handleBeginSubmit);
    Object.bind(this, this.handleSavedCard);
    Object.bind(this, this.handleErrored);
    Object.bind(this, this.handleCompleted);

    this.stateManager.addEventListener('beginSubmit', (evt:Event) => this.handleBeginSubmit(evt));
    this.stateManager.addEventListener('savedCard', (evt:Event) => this.handleSavedCard(evt));
    this.stateManager.addEventListener('errored', (evt:Event) => this.handleErrored(evt));

    this.stateManager.addEventListener('completed', (evt:Event) => this.handleCompleted(evt));

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

  private handleCompleted(_evt: Event) {
    this.dispatchEvent(new Event('updated'));
  }
  
  private handleErrored(evt: Event) {
    this.dispatchEvent(new Event('updated'));
  }
  
  private handleSavedCard(evt: Event) {
    this.dispatchEvent(new Event('updated'));
  }
  
  private handleBeginSubmit(evt: Event) {
    this.dispatchEvent(new Event('updated'));
  }
}