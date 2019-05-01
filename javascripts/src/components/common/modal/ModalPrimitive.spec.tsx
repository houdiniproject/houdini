// License: LGPL-3.0-or-later
import { mount, ReactWrapper } from 'enzyme';
import 'jest';
import { action, observable } from 'mobx';
import { observer } from 'mobx-react';
import * as React from 'react';
import ModalPrimitive from './ModalPrimitive';
jest.mock('lodash', () => ({
  ...(jest as any).requireActual('lodash'),
  uniqueId: () => "1",
}));
import AriaModal = require('react-aria-modal')

@observer
class MountPasser extends React.Component<{children:React.ReactElement<any>}, {}>{
  @observable
  clicked: boolean
  
  @action.bound
  onClick(){
    this.clicked = true;
  }

  render() {
    return React.cloneElement(this.props.children, {...this.props.children.props, mounted:!this.clicked})
  }
}

describe('ModalPrimitive', () => {
  let modal:ReactWrapper
  let push:jest.Mock
  let remove: jest.Mock
  let onEnter: jest.Mock
  let onExit: jest.Mock
  function getAriaModalWrapper() {
    return modal.find('Modal')
  }

  function getAriaModalInstance(): AriaModal
  {
    return getAriaModalWrapper().instance()
  }
  
  describe('Modal with minimal set', () => {  
    beforeEach(() => {
      push = jest.fn(),
      remove = jest.fn()
      let modalManager = {
        push: push,
        remove: remove,
        top: '1'
      }
      modal  = mount(<MountPasser><ModalPrimitive ModalManager={modalManager} titleText={"whee"}>
      <button></button>
      </ModalPrimitive></MountPasser>)
    })

    it('has escapeExit set', () => {
      expect(getAriaModalInstance().props.escapeExits).toBeTruthy()
    })

    it('has underlayClickExits set', () => {
      expect(getAriaModalInstance().props.underlayClickExits).toBeTruthy()
    })

    it('has scrollDisabled set', () => {
      expect(getAriaModalInstance().props.scrollDisabled).toBeTruthy()
    })

    it('has correct Id', () => {
      expect(getAriaModalInstance().props.dialogId).toBe('react-aria-modal-dialog-1')
    })

    it('doesnt have aria-hidden set', () => {
      expect(getAriaModalInstance().props['aria-hidden']).toBeFalsy()
    })

    it('called push', () => {
      expect(push).toBeCalledWith("1")
    })

    it('didnt call remove', () => {
      expect(remove).not.toBeCalled();
    })
  })

  describe('Modal is not top', () => {  
    beforeEach(() => {
      push = jest.fn(),
      remove = jest.fn().mockReturnValue(true)
      onEnter = jest.fn()
      onExit = jest.fn()
      let modalManager = {
        push: push,
        remove: remove,
        top: '2'
      }
      
      modal  = mount(<MountPasser><ModalPrimitive ModalManager={modalManager} titleText={"whee"} onEnter={onEnter} onExit={onExit}>
      <button></button>
      </ModalPrimitive></MountPasser>)
    })

    it('has escapeExit set', () => {
      expect(getAriaModalInstance().props.escapeExits).toBeFalsy()
    })

    it('has underlayClickExits set', () => {
      expect(getAriaModalInstance().props.underlayClickExits).toBeFalsy()
    })

    it('has scrollDisabled set', () => {
      expect(getAriaModalInstance().props.scrollDisabled).toBeFalsy()
    })

    it('has correct Id', () => {
      expect(getAriaModalInstance().props.dialogId).toBe('react-aria-modal-dialog-1')
    })

    it('doesnt have aria-hidden set', () => {
      expect(getAriaModalInstance().props['aria-hidden']).toBeTruthy()
    })

    it('called push', () => {
      expect(push).toBeCalledWith("1")
    })

    it('called onEnter', () => {
      expect(onEnter).toBeCalled()
    })

    it('didnt call remove', () => {
      expect(remove).not.toBeCalled();
    })

    it('fires onExit on an unmount', () => {
      modal.unmount()
      expect(onExit).toBeCalled()
      expect(remove).toBeCalled();
    })
  })

  describe('Modal is unmounted', () => {  
    let called:boolean
    beforeEach(() => {
      called= false
      push = jest.fn(),
      remove = jest.fn(() => {
        if (called){
          return false;
        }
        else {
          called = true;
          return true;
        }
      })
      onExit = jest.fn()
      onEnter = jest.fn()
      let modalManager = {
        push: push,
        remove: remove,
        top: '2'
      }

  
      modal  = mount(<MountPasser><ModalPrimitive ModalManager={modalManager} titleText={"whee"} onEnter={onEnter} onExit={onExit}>
      <button></button>
      </ModalPrimitive></MountPasser>);
      let ariaModal = modal.find('Modal').instance() as AriaModal
      //We don't have a good way of firing onExit so let's do that
      ariaModal.props.onExit()
    })

    it('called onEnter', () => {
      expect(onEnter).toBeCalled()
    })

    it('called push', () => {
      expect(push).toBeCalledWith("1")
    })

    it('called onExit', () => {
      expect(onExit).toHaveBeenCalledTimes(1)
    })

    it('called remove', () => {
      expect(remove).toBeCalledWith("1")
    })

    it('unmounts and is called one time', () => {
      modal.unmount()
      expect(remove).toHaveBeenCalledTimes(2)
      expect(onExit).toHaveBeenCalledTimes(1)
    })
  })

  describe('Modal is not top', () => {  
    beforeEach(() => {
      push = jest.fn(),
      remove = jest.fn()
      onEnter = jest.fn()
      let modalManager = {
        push: push,
        remove: remove,
        top: '2'
      }
      modal  = mount(<ModalPrimitive ModalManager={modalManager} titleText={"whee"} onEnter={onEnter}>
      <button></button>
      </ModalPrimitive>)
    })

    it('has escapeExit set', () => {
      expect(getAriaModalInstance().props.escapeExits).toBeFalsy()
    })

    it('has underlayClickExits set', () => {
      expect(getAriaModalInstance().props.underlayClickExits).toBeFalsy()
    })

    it('has scrollDisabled set', () => {
      expect(getAriaModalInstance().props.scrollDisabled).toBeFalsy()
    })

    it('has correct Id', () => {
      expect(getAriaModalInstance().props.dialogId).toBe('react-aria-modal-dialog-1')
    })

    it('doesnt have aria-hidden set', () => {
      expect(getAriaModalInstance().props['aria-hidden']).toBeTruthy()
    })

    it('called push', () => {
      expect(push).toBeCalledWith("1")
    })

    it('called onEnter', () => {
      expect(onEnter).toBeCalled()
    })

    it('didnt call remove', () => {
      expect(remove).not.toBeCalled();
    })
  })
})