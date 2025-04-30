// License: LGPL-3.0-or-later

export const self = jest.fn();
export const top = jest.fn();
export const setLocation = jest.fn();
export const safelyPostMessageToParent = jest.fn();

const mock = jest.fn().mockImplementation(() => {
  return {
    self,
    top,
    setLocation,
    safelyPostMessageToParent,
  };
});

export default mock;