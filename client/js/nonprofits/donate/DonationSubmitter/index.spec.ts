// License: LGPL-3.0-or-later
import DonationSubmitter from '.';

describe('DonationSubmitter', () => {

  
  function SetupDonationSubmitter(updated=jest.fn()) {
    const ret = {
      submitter: new DonationSubmitter(),
      updated,
    };

    ret.submitter.addEventListener('updated', ret.updated)
    
    
    return ret;

  }
  describe("before anything happens", () => {

    function prepare(): ReturnType<typeof SetupDonationSubmitter> {
      return SetupDonationSubmitter();
    }
    it('is not loading', () => {
      const {submitter: state} = prepare()
      expect(state.loading).toBe(false);
    })

    it('has no result', () => {
      const {submitter: state} = prepare()

      expect(state.result).toBeUndefined();
    })

    it('is not completed', () => {
      const {submitter: state} = prepare()

      expect(state.completed).toEqual(false);
    })

    it('has no error', () => {
      const {submitter: state} = prepare()
      expect(state.error).toBeUndefined();
    })

    it('has no progress', () => {
      const {submitter: state} = prepare()
      expect(state.progress).toBeUndefined();
    })

    it("has not had an event fired", () => {
      const {updated} = prepare()
      expect(updated).not.toHaveBeenCalled()
    })
  })

  describe("when beginSubmit and then savedCard", () => {
    
    function prepare(): ReturnType<typeof SetupDonationSubmitter> {
      const func = jest.fn(() => {
      })
      const mocked = SetupDonationSubmitter(func);
      mocked.submitter.reportBeginSubmit();
      mocked.submitter.reportSavedCard();
      return mocked;
    }

    it('is loading', () => {
      const {submitter: state} = prepare()
      
      expect(state.loading).toBe(true);
    })

    it('has no result', () => {
      const {submitter: state} = prepare()

      expect(state.result).toBeUndefined();
    })

    it('is not completed', () => {
      const {submitter: state} = prepare()

      expect(state.completed).toEqual(false);
    })

    it('has no error', () => {
      const {submitter: state} = prepare()

      expect(state.error).toBeUndefined();
    })

    it('has 100% progress', () => {
      const {submitter: state} = prepare()

      expect(state.progress).toBe(100);
    })

    it('has called beginSubmit and savedCard but nothing else', async () => {
      const {updated} = prepare();
      expect(updated).toHaveBeenCalledTimes(2);
    })

    it('calling savedCard twice only fires it once', () => {
      const {submitter: state, updated} = prepare();
      state.reportSavedCard();

      expect(updated).toHaveBeenCalledTimes(2);
    })
  })

  describe("when beginSubmit and then completed", () => {
    
    const donationResult = { };
    function prepare(): ReturnType<typeof SetupDonationSubmitter> {
      const mocked = SetupDonationSubmitter();
      mocked.submitter.reportBeginSubmit();
      mocked.submitter.reportSavedCard();

      mocked.submitter.reportCompleted(donationResult)
      return mocked;
    }

    it('is loading', () => {
      const {submitter: state} = prepare()
      
      expect(state.loading).toBe(false);
    })

    it('has no result', () => {
      const {submitter: state} = prepare()

      expect(state.result).toBe(donationResult)
    })

    it('is not completed', () => {
      const {submitter: state} = prepare()

      expect(state.completed).toEqual(true);
    })

    it('has no error', () => {
      const {submitter: state} = prepare()

      expect(state.error).toBeUndefined();
    })

    it('has 100% progress', () => {
      const {submitter: state} = prepare()

      expect(state.progress).toBeUndefined();
    })

    it('has called beginSubmit, savedCard and completed', () => {
      const {updated} = prepare();

      expect(updated).toHaveBeenCalledTimes(3);
    })

    it('calling completed twice only fires it once', () => {
      const {submitter: state, updated} = prepare();
      state.reportCompleted(donationResult);

      expect(updated).toHaveBeenCalledTimes(3)
    })

  })

  describe("when beginSubmit and then errored", () => {
    
    const error = "Error message"

    function prepare(): ReturnType<typeof SetupDonationSubmitter> {
      const mocked = SetupDonationSubmitter();
      mocked.submitter.reportBeginSubmit();
      mocked.submitter.reportError(error);;
      return mocked;
    }

    it('is loading', () => {
      const {submitter: state} = prepare()

      expect(state.loading).toBe(false);
    })

    it('has no result', () => {
      const {submitter: state} = prepare()

      expect(state.result).toBeUndefined();
    })

    it('is not completed', () => {
      const {submitter: state} = prepare()

      expect(state.completed).toEqual(false);
    })

    it('has the error', () => {
      const {submitter: state} = prepare()

      expect(state.error).toBe(error);
    })

    it('has undefined', () => {
      const {submitter: state} = prepare()

      expect(state.progress).toBeUndefined
    })

    it('has called beginSubmit and error but nothing else', () => {
      const {updated} = prepare();


      expect(updated).toHaveBeenCalledTimes(2);
    })

    it('calling reportError twice only fires it once', () => {
      const {submitter: state, updated} = prepare();

      state.reportError(error);

      expect(updated).toHaveBeenCalledTimes(2);
      
    })
  })

  describe("when savedCard and then errored", () => {
    const error = "Error message"

    function prepare(): ReturnType<typeof SetupDonationSubmitter> {
      const mocked = SetupDonationSubmitter();
      mocked.submitter.reportBeginSubmit();
      mocked.submitter.reportSavedCard();
      mocked.submitter.reportError(error)
      return mocked;
    }

    it('is loading', () => {
      const {submitter: state} = prepare()

      expect(state.loading).toBe(false);
    })

    it('has no result', () => {
      const {submitter: state} = prepare()

      expect(state.result).toBeUndefined();
    })

    it('is not completed', () => {
      const {submitter: state} = prepare()

      expect(state.completed).toEqual(false);
    })

    it('has the error', () => {
      const {submitter: state} = prepare()

      expect(state.error).toBe(error);
    })

    it('has undefined', () => {
      const {submitter: state} = prepare()

      expect(state.progress).toBeUndefined
    })

    it('has called beginSubmit and cardsaved and error but nothing else', () => {
      const {updated} = prepare();


      expect(updated).toHaveBeenCalledTimes(3);
    })

    it('calling reportError twice only fires it once', () => {
      const {submitter: state, updated} = prepare();

      state.reportError(error);

      expect(updated).toHaveBeenCalledTimes(3);
    })
  });


  describe("when errored and then re-attempted", () => {
    const error = "Error message";
    
    function prepare(): ReturnType<typeof SetupDonationSubmitter> {
      const mocked = SetupDonationSubmitter();
      mocked.submitter.reportBeginSubmit();
      mocked.submitter.reportSavedCard();
      mocked.submitter.reportError(error);
      mocked.submitter.reportBeginSubmit();
      return mocked;
    }

    it('is loading', () => {
      const {submitter: state} = prepare()
      
      expect(state.loading).toBe(true);
    })

    it('has no result', () => {
      const {submitter: state} = prepare()

      expect(state.result).toBeUndefined();
    })

    it('is not completed', () => {
      const {submitter: state} = prepare()

      expect(state.completed).toEqual(false);
    })

    it('has no error', () => {
      const {submitter: state} = prepare()

      expect(state.error).toBeUndefined();
    })

    it('has 20% progress', () => {
      const {submitter: state} = prepare()

      expect(state.progress).toBe(20);
    })

    it('has called beginSubmit, savedCard and errored', () => {
      const {updated} = prepare();

      expect(updated).toHaveBeenCalledTimes(4);
    });

  })

  describe("when errored and then re-attempted", () => {
    const error = "Error message";
    const donationResult:any = { charge: undefined };
    function prepare(): ReturnType<typeof SetupDonationSubmitter> {
      const mocked = SetupDonationSubmitter(jest.fn());
      mocked.submitter.reportBeginSubmit();
      mocked.submitter.reportSavedCard();
      mocked.submitter.reportError(error);
      mocked.submitter.reportBeginSubmit();
      mocked.submitter.reportSavedCard();
      mocked.submitter.reportCompleted(donationResult);
      return mocked;
    }

    it('is loading', () => {
      const {submitter: state} = prepare()
      
      expect(state.loading).toBe(false);
    })

    it('has no result', () => {
      const {submitter: state} = prepare()

      expect(state.result).toBe(donationResult);
    })

    it('is not completed', () => {
      const {submitter: state} = prepare()

      expect(state.completed).toEqual(true);
    })

    it('has no error', () => {
      const {submitter: state} = prepare()

      expect(state.error).toBeUndefined();
    })

    it('has undefined progress', () => {
      const {submitter: state} = prepare()

      expect(state.progress).toBeUndefined();
    })

    it('has called beginSubmit, savedCard and errored', () => {
      const {updated} = prepare();

      expect(updated).toHaveBeenCalledTimes(6);
    });
  })

  
})