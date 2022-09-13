// License: LGPL-3.0-or-later

import EventStack from './EventStack';

describe('EventStack', () => {
  const firstEvent = {type:"first"}
  describe('.top', () => {
    it('returns undefined if no events have been added', () => {
      const stack = new EventStack();
      expect(stack.top).toBeUndefined();
    })

    it('returns the top event after an event is pushed', () => {
      const stack = new EventStack();
      stack.push(firstEvent)
      expect(stack.top).toEqual(firstEvent);
    })
  })

  describe('.push', () => {
    it("returns event when an event is added", () => {
      const stack = new EventStack();
      expect(stack.push(firstEvent)).toEqual(firstEvent)
      
    });

    it ("returns undefined when the event isn't added because it's already the top", () => {
      const stack = new EventStack();
      stack.push(firstEvent)
      expect(stack.push(firstEvent)).toBeUndefined();
    })

    it("returns and adds event when it doesn't match another object based on deep comparison", () => {
      const stack = new EventStack();
      stack.push(firstEvent)

      const secondEvent = {type:"first", but:"different"}
      expect(stack.push(secondEvent)).toEqual(secondEvent);
    })
  })

})