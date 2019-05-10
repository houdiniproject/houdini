// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import Modal, { ModalProps } from './Modal'
import { shallow, mount, ReactWrapper } from "enzyme";
import toJson from "enzyme-to-json";
import { DefaultCloseButton } from '../DefaultCloseButton';
import { ModalManager } from './modal_manager';
import { Provider, observer } from 'mobx-react';
import { observable, action } from 'mobx';
jest.mock('lodash', () => ({
  ...(jest as any).requireActual('lodash'),
  uniqueId: () => "1",
}));
import AriaModal = require('react-aria-modal')
import ModalBody from './ModalBody';
import { ModalManagerProvider, connectModalManager, ModalManagerContextProps } from './connect_modal_manager';
import { Transition } from 'react-transition-group';
import { ModalContextProps, connectModal } from './connect';
jest.useFakeTimers()
@observer
class MountPasser extends React.Component<{ children: React.ReactElement<any> }, {}>{
  @observable
  clicked: boolean

  @action.bound
  onClick() {
    this.clicked = true;
  }

  render() {
    return React.cloneElement(this.props.children, { ...this.props.children.props, modalActive: !this.clicked })
  }
}

describe('Modal', () => {
  let modal: ReactWrapper
  let push: jest.Mock
  let remove: jest.Mock

  function getAriaModalWrapper() {
    return modal.find('Modal')
  }

  function getAriaModalInstance(): AriaModal {
    return getAriaModalWrapper().instance()
  }

  function getMainTransition(): Transition {
    return modal.find(Transition).first().instance() as any
  }

  function getCloseButton(): ReactWrapper {
    return modal.find('DefaultCloseButton')
  }

  function verifyTransitionProperties() {
    it('Transition has mountOnEnter set (if it isnt the initial transition wont happen)', () => {
      expect(getMainTransition().props.mountOnEnter).toBe(true)
    })

    it('Transition has unmountOnExit set (if it isnt the child modal will be kept forever)', () => {
      expect(getMainTransition().props.unmountOnExit).toBe(true)
    })

    it('Transition has unmountOnEnter set (if it isnt the child modal will be mounted early)', () => {
      expect(getMainTransition().props.mountOnEnter).toBe(true)
    })
  }

  describe('active modal displays', () => {

    let onCloseWasCalled = false
    beforeEach(() => {
      onCloseWasCalled = false;
      push = jest.fn(),
        remove = jest.fn()
      let modalManager = {
        push: push,
        remove: remove,
        top: '1'
      }
      modal = mount(<ModalManagerProvider value={modalManager}>
        <MountPasser><Modal titleText={"whee"} onClose={() => { onCloseWasCalled = true }} modalActive={true}>
          <ModalBody>
            <button></button></ModalBody>
        </Modal></MountPasser></ModalManagerProvider>)
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

    it('closes on modal component close', () => {
      let modalComponent = modal.find('HoudiniModal').first().instance() as React.Component<ModalProps, {}> //casting to modal didn't work for reasons?
      modalComponent.props.onClose()
      expect(onCloseWasCalled).toBeTruthy()
    })

    it('closes on closeButtonClick', () => {
      let closeButton = modal.find('DefaultCloseButton')
      let instanceButton = closeButton.instance() as DefaultCloseButton
      instanceButton.props.onClick();
      expect(onCloseWasCalled).toBeTruthy()
    })

    it('has no footer', () => {
      expect(modal.find('footer').exists()).toBeFalsy()
    })


    verifyTransitionProperties()
  })

  interface Props {
    result: () => boolean |Promise<boolean>

  }
  class InnerCanCloseSetter extends React.Component<Props & ModalContextProps> {

    componentWillMount() {
      this.props.modal.setCanClose(this.props.result)
    }

    render() {
      return <br />
    }
  }

  const CanCloseSetting = connectModal(InnerCanCloseSetter)

  describe('canClose is falsey', () => {
    let onClose: jest.Mock
    beforeEach(() => {
      onClose = jest.fn()
      push = jest.fn(),
        remove = jest.fn()
      let modalManager = {
        push: push,
        remove: remove,
        top: '1'
      }
      it('canClose as function', () => {


        modal = mount(<ModalManagerProvider value={modalManager}>
          <MountPasser><Modal titleText={"whee"} onClose={onClose} modalActive={true}>
            <ModalBody>
              <CanCloseSetting result={() => false} />
              <button></button></ModalBody>
          </Modal></MountPasser></ModalManagerProvider>)

        getCloseButton().simulate('click')
        expect(onClose).not.toBeCalled()
      })

      it('canClose as Promise function', async (done) => {
        let canClose = jest.fn(async () => await false )

        modal = mount(<ModalManagerProvider value={modalManager}>
          <MountPasser><Modal titleText={"whee"} onClose={onClose} modalActive={true}>
            <ModalBody>
              <CanCloseSetting result={canClose} />
              <button></button></ModalBody>
          </Modal></MountPasser></ModalManagerProvider>)

        let closeButton = getCloseButton().instance() as any
        closeButton.props.onClick()

        expect(canClose).toBeCalled()
        expect(onClose).not.toBeCalled()
        done()
      })
    })
  })

  describe('handleClose is properly called', () => {
    let onClose: jest.Mock
    let onExited: jest.Mock
    let canClose: jest.Mock
    beforeEach(() => {
      onClose = jest.fn()
      push = jest.fn()
      remove = jest.fn()
      onExited = jest.fn()
      

      let modalManager = {
        push: push,
        remove: remove,
        top: '1'
      }
      it('canClose as function', () => {

        canClose = jest.fn(() => true)
        modal = mount(<ModalManagerProvider value={modalManager}>
          <MountPasser><Modal titleText={"whee"} onClose={onClose} onExited={onExited} modalActive={true}>
            <ModalBody>
              <CanCloseSetting result={canClose} />
              <button></button></ModalBody>
          </Modal></MountPasser></ModalManagerProvider>)

        getCloseButton().simulate('click')
        expect(onClose).not.toBeCalled()
        expect(canClose).toBeCalled()
        expect(onExited).toBeCalled()
      })

      it('canClose as Promise function', async (done) => {
        let canClose = jest.fn(async () => await false )

        modal = mount(<ModalManagerProvider value={modalManager}>
          <MountPasser><Modal titleText={"whee"} onClose={onClose} onExited={onExited} modalActive={true}>
            <ModalBody>
              <CanCloseSetting result={canClose} />
              <button></button></ModalBody>
          </Modal></MountPasser></ModalManagerProvider>)
        let closeButton = getCloseButton().instance() as any
        await closeButton.props.onClick()

        expect(onClose).not.toBeCalled()
        expect(canClose).toBeCalled()
        expect(onExited).toBeCalled()
        done()
      })
    })
  })


  it('doesnt have a close button if we ask for none', () => {
    let onCloseWasCalled = false
    let modalManager = new ModalManager();
    let modal = mount(<ModalManagerProvider value={modalManager}>
      <MountPasser><Modal titleText={"whee"} onClose={() => { onCloseWasCalled = true }} modalActive={true} showCloseButton={false}>
        <ModalBody>
          <button></button></ModalBody>
      </Modal></MountPasser></ModalManagerProvider>)
    expect(modal.find('DefaultCloseButton').exists()).toBeFalsy()
  })


  describe('Modal is not top', () => {
    let onClose: jest.Mock
    beforeEach(() => {
      push = jest.fn(),
        remove = jest.fn().mockReturnValue(true)
      onClose = jest.fn()
      let modalManager = {
        push: push,
        remove: remove,
        top: '2'
      }

      modal = modal = mount(<ModalManagerProvider value={modalManager}>
        <MountPasser><Modal titleText={"whee"} modalActive={true} onClose={onClose}>
          <ModalBody>
            <button></button></ModalBody>
        </Modal></MountPasser></ModalManagerProvider>)
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

    it('didnt call remove', () => {
      expect(remove).not.toBeCalled();
    })

    it('remove is called', () => {
      modal.unmount()
      expect(remove).toBeCalled();
    })

    verifyTransitionProperties()
  })

  describe('Modal is unmounted', () => {
    let called: boolean
    let onClose: jest.Mock
    let onExited: jest.Mock
    beforeEach(() => {
      called = false
      push = jest.fn(),
      onClose = jest.fn()
      onExited = jest.fn()
      remove = jest.fn(() => {
        if (called) {
          return false;
        }
        else {
          called = true;
          return true;
        }
      })

      let modalManager = {
        push: push,
        remove: remove,
        top: '2'
      }

      modal = mount(<ModalManagerProvider value={modalManager}>
        <MountPasser><Modal titleText={"whee"} onClose={onClose} onExited={onExited}>
          <ModalBody>
            <button></button></ModalBody>
        </Modal></MountPasser></ModalManagerProvider>)

      //close the modal!
      let clicker = modal.find('MountPasser').instance() as any
      clicker.onClick()
      modal.update()
      jest.runAllTimers() // this is to make sure the transition ACTUALLY finishes and onExited is called.
    })

    it('called push', () => {
      expect(push).toBeCalledWith("1")
    })

    it('called remove', () => {
      expect(remove).toBeCalledWith("1")
      expect(onExited).toHaveBeenCalledTimes(1)
    })

    it('unmounts and is called one time', () => {
      modal.unmount()
      expect(remove).toHaveBeenCalledTimes(2)
      expect(onExited).toHaveBeenCalledTimes(1)
    })

    verifyTransitionProperties()

  })
})