// License: LGPL-3.0-or-later

import StateManager from './StateManager';

describe('StateManager', () => {

  interface StateManagerMock {state: StateManager, beginSubmit:jest.Mock, errored: jest.Mock, savedCard:jest.Mock, completed:jest.Mock};
  function SetupStateManager(): StateManagerMock {
    const ret = {
      state: new StateManager(),
      beginSubmit: jest.fn(),
      errored: jest.fn(),
      savedCard: jest.fn(),
      completed:jest.fn(),
    };

    ret.state.addEventListener('beginSubmit', ret.beginSubmit)
    ret.state.addEventListener('errored', ret.errored)
    ret.state.addEventListener('savedCard', ret.savedCard)
    ret.state.addEventListener('completed', ret.completed)
    return ret;

  }
  describe("before anything happens", () => {

    function prepare(): StateManagerMock {
      return SetupStateManager();
    }
    it('is not loading', () => {
      const {state} = prepare()
      expect(state.loading).toBe(false);
    })

    it('has no result', () => {
      const {state} = prepare()

      expect(state.result).toBeUndefined();
    })

    it('is not completed', () => {
      const {state} = prepare()

      expect(state.completed).toEqual(false);
    })

    it('has no error', () => {
      const {state} = prepare()
      expect(state.error).toBeUndefined();
    })

    it('has no progress', () => {
      const {state} = prepare()
      expect(state.progress).toBeUndefined();
    })

    it("has not had an event fired", () => {
      const {beginSubmit, errored, completed, savedCard} = prepare()
      expect(beginSubmit).not.toHaveBeenCalled()
      expect(errored).not.toHaveBeenCalled()
      expect(completed).not.toHaveBeenCalled()
      expect(savedCard).not.toHaveBeenCalled()
    })
  })

  describe("when beginSubmit and then savedCard", () => {
    
    function prepare(): StateManagerMock {
      const mocked = SetupStateManager();
      mocked.state.reportBeginSubmit();
      mocked.state.reportSavedCard();
      return mocked;
    }

    it('is loading', () => {
      const {state} = prepare()
      
      expect(state.loading).toBe(true);
    })

    it('has no result', () => {
      const {state} = prepare()

      expect(state.result).toBeUndefined();
    })

    it('is not completed', () => {
      const {state} = prepare()

      expect(state.completed).toEqual(false);
    })

    it('has no error', () => {
      const {state} = prepare()

      expect(state.error).toBeUndefined();
    })

    it('has 100% progress', () => {
      const {state} = prepare()

      expect(state.progress).toBe(100);
    })

    it('has called beginSubmit and savedCard but nothing else', () => {
      const {beginSubmit, savedCard, completed, errored} = prepare();

      expect(beginSubmit).toHaveBeenCalledTimes(1);
      expect(savedCard).toHaveBeenCalledTimes(1)
      expect(completed).not.toHaveBeenCalled();
      expect(errored).not.toHaveBeenCalled();
    })

    it('calling savedCard twice only fires it once', () => {
      const {state, beginSubmit, savedCard, completed, errored} = prepare();
      state.reportSavedCard();

      expect(beginSubmit).toHaveBeenCalledTimes(1);
      expect(savedCard).toHaveBeenCalledTimes(1);
      expect(completed).not.toHaveBeenCalled();
      expect(errored).not.toHaveBeenCalled();
    })
  })

  describe("when beginSubmit and then completed", () => {
    
    const donationResult = {};
    function prepare(): StateManagerMock {
      const mocked = SetupStateManager();
      mocked.state.reportBeginSubmit();
      mocked.state.reportSavedCard();

      mocked.state.reportCompleted(donationResult)
      return mocked;
    }

    it('is loading', () => {
      const {state} = prepare()
      
      expect(state.loading).toBe(false);
    })

    it('has no result', () => {
      const {state} = prepare()

      expect(state.result).toBe(donationResult)
    })

    it('is not completed', () => {
      const {state} = prepare()

      expect(state.completed).toEqual(true);
    })

    it('has no error', () => {
      const {state} = prepare()

      expect(state.error).toBeUndefined();
    })

    it('has 100% progress', () => {
      const {state} = prepare()

      expect(state.progress).toBeUndefined();
    })

    it('has called beginSubmit, savedCard and completed', () => {
      const {beginSubmit, savedCard, completed, errored} = prepare();

      expect(beginSubmit).toHaveBeenCalledTimes(1);
      expect(savedCard).toHaveBeenCalledTimes(1)
      expect(completed).toHaveBeenCalledTimes(1);
      expect(errored).not.toHaveBeenCalled();
    })

    it('calling completed twice only fires it once', () => {
      const {state, beginSubmit, savedCard, completed, errored} = prepare();
      state.reportCompleted(donationResult);

      expect(beginSubmit).toHaveBeenCalledTimes(1);
      expect(savedCard).toHaveBeenCalledTimes(1);
      expect(completed).toHaveBeenCalledTimes(1);
      expect(errored).not.toHaveBeenCalled();
    })
  })

  describe("when beginSubmit and then errored", () => {
    
    const error = "Error message"

    function prepare(): StateManagerMock {
      const mocked = SetupStateManager();
      mocked.state.reportBeginSubmit();
      mocked.state.reportError(error);;
      return mocked;
    }

    it('is loading', () => {
      const {state} = prepare()

      expect(state.loading).toBe(false);
    })

    it('has no result', () => {
      const {state} = prepare()

      expect(state.result).toBeUndefined();
    })

    it('is not completed', () => {
      const {state} = prepare()

      expect(state.completed).toEqual(false);
    })

    it('has the error', () => {
      const {state} = prepare()

      expect(state.error).toBe(error);
    })

    it('has undefined', () => {
      const {state} = prepare()

      expect(state.progress).toBeUndefined
    })

    it('has called beginSubmit and error but nothing else', () => {
      const {beginSubmit, savedCard, completed, errored} = prepare();


      expect(beginSubmit).toHaveBeenCalledTimes(1);
      expect(savedCard).not.toHaveBeenCalled()
      expect(completed).not.toHaveBeenCalled();
      expect(errored).toHaveBeenCalledTimes(1);
    })

    it('calling reportError twice only fires it once', () => {
      const {state, beginSubmit, savedCard, completed, errored} = prepare();

      state.reportError(error);

      expect(beginSubmit).toHaveBeenCalledTimes(1);
      expect(savedCard).not.toHaveBeenCalled();
      expect(completed).not.toHaveBeenCalled();
      expect(errored).toHaveBeenCalledTimes(1);
    })
  })

  describe("when savedCard and then errored", () => {
    const error = "Error message"

    function prepare(): StateManagerMock {
      const mocked = SetupStateManager();
      mocked.state.reportBeginSubmit();
      mocked.state.reportSavedCard();
      mocked.state.reportError(error)
      return mocked;
    }

    it('is loading', () => {
      const {state} = prepare()

      expect(state.loading).toBe(false);
    })

    it('has no result', () => {
      const {state} = prepare()

      expect(state.result).toBeUndefined();
    })

    it('is not completed', () => {
      const {state} = prepare()

      expect(state.completed).toEqual(false);
    })

    it('has the error', () => {
      const {state} = prepare()

      expect(state.error).toBe(error);
    })

    it('has undefined', () => {
      const {state} = prepare()

      expect(state.progress).toBeUndefined
    })

    it('has called beginSubmit and error but nothing else', () => {
      const {beginSubmit, savedCard, completed, errored} = prepare();


      expect(beginSubmit).toHaveBeenCalledTimes(1);
      expect(savedCard).toHaveBeenCalledTimes(1);
      expect(completed).not.toHaveBeenCalled();
      expect(errored).toHaveBeenCalledTimes(1);
    })

    it('calling reportError twice only fires it once', () => {
      const {state, beginSubmit, savedCard, completed, errored} = prepare();

      state.reportError(error);

      expect(beginSubmit).toHaveBeenCalledTimes(1);
      expect(savedCard).toHaveBeenCalledTimes(1);
      expect(completed).not.toHaveBeenCalled();
      expect(errored).toHaveBeenCalledTimes(1);
    })
  });


  describe("when errored and then re-attempted", () => {
    const error = "Error message";
    
    function prepare(): StateManagerMock {
      const mocked = SetupStateManager();
      mocked.state.reportBeginSubmit();
      mocked.state.reportSavedCard();
      mocked.state.reportError(error);
      mocked.state.reportBeginSubmit();
      return mocked;
    }

    it('is loading', () => {
      const {state} = prepare()
      
      expect(state.loading).toBe(true);
    })

    it('has no result', () => {
      const {state} = prepare()

      expect(state.result).toBeUndefined();
    })

    it('is not completed', () => {
      const {state} = prepare()

      expect(state.completed).toEqual(false);
    })

    it('has no error', () => {
      const {state} = prepare()

      expect(state.error).toBeUndefined();
    })

    it('has 20% progress', () => {
      const {state} = prepare()

      expect(state.progress).toBe(20);
    })

    it('has called beginSubmit, savedCard and errored', () => {
      const {beginSubmit, savedCard, completed, errored} = prepare();

      expect(beginSubmit).toHaveBeenCalledTimes(2);
      expect(savedCard).toHaveBeenCalledTimes(1)
      expect(completed).not.toBeCalled();
      expect(errored).toHaveBeenCalledTimes(1)
    });
  })

  describe("when errored and then re-attempted", () => {
    const error = "Error message";
    const donationResult = {};
    function prepare(): StateManagerMock {
      const mocked = SetupStateManager();
      mocked.state.reportBeginSubmit();
      mocked.state.reportSavedCard();
      mocked.state.reportError(error);
      mocked.state.reportBeginSubmit();
      mocked.state.reportSavedCard();
      mocked.state.reportCompleted(donationResult);
      return mocked;
    }

    it('is loading', () => {
      const {state} = prepare()
      
      expect(state.loading).toBe(false);
    })

    it('has no result', () => {
      const {state} = prepare()

      expect(state.result).toBe(donationResult);
    })

    it('is not completed', () => {
      const {state} = prepare()

      expect(state.completed).toEqual(true);
    })

    it('has no error', () => {
      const {state} = prepare()

      expect(state.error).toBeUndefined();
    })

    it('has undefined progress', () => {
      const {state} = prepare()

      expect(state.progress).toBeUndefined();
    })

    it('has called beginSubmit, savedCard and errored', () => {
      const {beginSubmit, savedCard, completed, errored} = prepare();

      expect(beginSubmit).toHaveBeenCalledTimes(2);
      expect(savedCard).toHaveBeenCalledTimes(2)
      expect(completed).toHaveBeenCalledTimes(1);
      expect(errored).toHaveBeenCalledTimes(1)
    });
  })
})