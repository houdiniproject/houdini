// License: LGPL-3.0-or-later
const insideAnIframe = jest.fn();
const setLocation = jest.fn();
const notifyParentOfClose = jest.fn()
const notifyParentOfRedirect = jest.fn();


jest.mock('./WidgetWindowWrapper', () => {
  return () => ({
    insideAnIframe,
    setLocation,
    notifyParentOfClose,
    notifyParentOfRedirect
  })
});



import handleWizardFinished  from "./handleWizardFinished";


/** We just need a window object to pass to the second argument for creating our WidgetWindowWrapper */
const fakeWindow = {} as any as Window;

const FAKE_REDIRECT_URL = "https://example.com/redirect/url"

describe(".handleWizardFinished", () => {

  beforeEach(() => {
    jest.resetAllMocks();
  })

  function mockBeingInsideIFrame() {
    insideAnIframe.mockReturnValue(true)
  }

  describe("redirect is not set", () => {

    describe('inside an iframe', () => {
      describe('as an embeddedWidget', () => {
        it('does not call to anywhere', () => {
          mockBeingInsideIFrame()
          handleWizardFinished({ mode: 'embedded' }, fakeWindow);
          expect(notifyParentOfClose).not.toHaveBeenCalled();
          expect(notifyParentOfRedirect).not.toHaveBeenCalled();
          expect(setLocation).not.toHaveBeenCalled();
        });
      });

      describe('not any other embeddedWidget', () => {
        it('does not call to anywhere', () => {
          mockBeingInsideIFrame()
          handleWizardFinished({}, fakeWindow);
          expect(notifyParentOfClose).toHaveBeenCalled();
          expect(notifyParentOfRedirect).not.toHaveBeenCalled();
          expect(setLocation).not.toHaveBeenCalled();
        });
      });
    });

    describe('not inside an iframe', () => {
      it('does not call to anywhere', () => {
        mockBeingInsideIFrame()
        handleWizardFinished({}, fakeWindow);
        expect(notifyParentOfClose).toHaveBeenCalled();
        expect(notifyParentOfRedirect).not.toHaveBeenCalled();
        expect(setLocation).not.toHaveBeenCalled();
      });
    });


  });

  describe("redirect is set", () => {

    describe('inside an iframe', () => {
      describe('as an embeddedWidget', () => {
        it('does not call to anywhere', () => {
          mockBeingInsideIFrame()
          handleWizardFinished({ mode: 'embedded', redirect: FAKE_REDIRECT_URL }, fakeWindow);
          expect(notifyParentOfClose).not.toHaveBeenCalled();
          expect(notifyParentOfRedirect).toHaveBeenCalledWith(FAKE_REDIRECT_URL);
          expect(setLocation).not.toHaveBeenCalled();
        });
      });

      describe('not any other embeddedWidget', () => {
        it('does not call to anywhere', () => {
          mockBeingInsideIFrame()
          handleWizardFinished({ redirect: FAKE_REDIRECT_URL }, fakeWindow);
          expect(notifyParentOfClose).toHaveBeenCalled();
          expect(notifyParentOfRedirect).toHaveBeenCalledWith(FAKE_REDIRECT_URL);
          expect(setLocation).not.toHaveBeenCalled();
        });
      });
    });

    describe('not inside an iframe', () => {
      it('does not call to anywhere', () => {
        handleWizardFinished({ redirect: FAKE_REDIRECT_URL }, fakeWindow);
        expect(notifyParentOfClose).toHaveBeenCalled();
        expect(notifyParentOfRedirect).not.toHaveBeenCalled();
        expect(setLocation).toHaveBeenCalledWith(FAKE_REDIRECT_URL);
      });
    });


  });
});
