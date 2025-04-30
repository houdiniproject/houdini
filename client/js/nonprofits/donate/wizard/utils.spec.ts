// License: LGPL-3.0-or-later
import { handleWizardFinished } from "./utils";

describe(".handleWizardFinished", () => {
  const self = jest.fn();
  const top = jest.fn();
  const setLocation = jest.fn();
  const safelyPostMessageToParent = jest.fn();
  
  const mock = jest.fn().mockImplementation(() => {
    return {
      self,
      top,
      setLocation,
      safelyPostMessageToParent,
    };
  });
  jest.mock('./WindowWrapper', mock);
 

  describe("redirect is not set", () => {
    

    
    describe ('with an embeddedWidget', () => {
      it('does not call to anywhere', () => {
        handleWizardFinished({}, jest.fn() as any);
        expect(setLocation).not.toBeCalled();
        expect(safelyPostMessageToParent).toBeCalledWith('commitchange:close', '*');
      });
    })

    

  });

  describe("redirect is set", () => {

    // describe("and ")
    // jest.mock('./WindowWrapper', mock);

    
    // it('does not call to anywhere', () => {
    //   handleWizardFinished({}, jest.fn() as any);
    //   expect(setLocation).not.toBeCalled();
    //   expect(safelyPostMessageToParent).not.toBeCalled();
    // });

  });
});
