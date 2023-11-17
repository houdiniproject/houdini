class StepManager implements EventTarget {
  private eventTarget = new EventTarget();
  private _currentStep = 0;
  
  get currentStep(): number {
    return this._currentStep;
  }

  private set currentStep(newStep:number) {
    this._currentStep = newStep
  }

  next = () => {
    this.currentStep = this._currentStep + 1;
  }

  reset = () =>  {
    this.currentStep = 0;
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