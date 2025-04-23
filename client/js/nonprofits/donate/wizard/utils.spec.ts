// License: LGPL-3.0-or-later
import { handleWizardFinished } from "./utils";

describe(".handleWizardFinished", () => {

  function prepareWindow({hasParent}:{hasParent:boolean})  {
    
    jest.spyOn()
    jest.spyOn(window.document, 'location', 'set')
    jest.spyOn(window.top)

    return jest.fn(() => {
      document: jest.fn()
      parent: hasParent
    })
  }

  describe("redirect is not set", () => {
    
  });
});
