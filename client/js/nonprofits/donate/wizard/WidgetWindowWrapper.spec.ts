// License: LGPL-3.0-or-later
const self = jest.fn();
const top = jest.fn();
const postMessageToParent = jest.fn()
const parent = jest.fn();


jest.mock('./WindowWrapper', () => {
  return () => ({
    self,
    top,
    postMessageToParent,
    parent
  })
});



import { handleWizardFinished } from "./utils";
import WidgetWindowWrapper from "./WidgetWindowWrapper";


/** We just need a window object to pass to the second argument for creating our WidgetWindowWrapper */
const fakeWindow = {} as any as Window;

const FAKE_REDIRECT_URL = "https://example.com/redirect/url"
const CLOSE_MESSAGE = "commitchange:close";
const REDIRECT_MESSAGE = `commitchange:redirect:${FAKE_REDIRECT_URL}`;

function mockParentExists() {
  parent.mockReturnValue({})
}

function mockParentDoesNotExist() {
  parent.mockReturnValue(null)
}

describe("WidgetWindowWrapper", () => {

  beforeEach(() => {
    jest.resetAllMocks();
  })

  describe(".insideAnIframe", () => {
    it("false when self and top are the same", () => {
      const sameWindow = {} as any as Window;
      self.mockReturnValue(sameWindow);
      top.mockReturnValue(sameWindow);

      expect(new WidgetWindowWrapper(fakeWindow).insideAnIframe()).toBe(false)
    })

    it("true when self and top are different", () => {
      self.mockReturnValue({});
      top.mockReturnValue({});

      expect(new WidgetWindowWrapper(fakeWindow).insideAnIframe()).toBe(true)
    })
  });

  describe(".notifyParentOfRedirect", () => {
    it("when parent exists message is posted", () => {
      mockParentExists();
      new WidgetWindowWrapper(fakeWindow).notifyParentOfRedirect(FAKE_REDIRECT_URL);
      expect(postMessageToParent).toHaveBeenCalledWith(REDIRECT_MESSAGE, "*")
    });

    it("when parent does not exist message is not posted", () => {
      mockParentDoesNotExist();
      
      new WidgetWindowWrapper(fakeWindow).notifyParentOfRedirect(FAKE_REDIRECT_URL);

      expect(postMessageToParent).not.toHaveBeenCalled();
    });
  });

  describe(".notifyParentOfClose", () => {
    it("when parent exists message is posted", () => {
      mockParentExists();
      new WidgetWindowWrapper(fakeWindow).notifyParentOfClose();

      expect(postMessageToParent).toHaveBeenCalledWith(CLOSE_MESSAGE, "*")
    });

    it("when parent does not exist no message is posted", () => {
      mockParentDoesNotExist();
      
      new WidgetWindowWrapper(fakeWindow).notifyParentOfClose();
      expect(postMessageToParent).not.toHaveBeenCalled();
    });
    
  });

  describe(".safelyPostMessageToParent", () => {
    const SAMPLE_MESSAGE = "sample message"
    const SAMPLE_TARGET = "sample target"
    it("when parent exists the message is posted", () => {
      mockParentExists();

      new WidgetWindowWrapper(fakeWindow).safelyPostMessageToParent(SAMPLE_MESSAGE, SAMPLE_TARGET);

      expect(postMessageToParent).toHaveBeenCalledWith(SAMPLE_MESSAGE, SAMPLE_TARGET);

      
    });

    it("when parent does not exist, no message is posted", () => {
      mockParentDoesNotExist();

      new WidgetWindowWrapper(fakeWindow).safelyPostMessageToParent(SAMPLE_MESSAGE, SAMPLE_TARGET);

      expect(postMessageToParent).not.toHaveBeenCalled();
      
    });
    
  });
});
