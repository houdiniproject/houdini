// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import Modal, { ModalProps } from './Modal'
import { shallow, mount, ReactWrapper } from "enzyme";
import toJson from "enzyme-to-json";
import { DefaultCloseButton } from '../DefaultCloseButton';
import { ModalManager } from './modal_manager';
import { Provider } from 'mobx-react';

describe('Modal', () => {
  test('nothing displayed if inactive', () => {
    let modal = shallow(<Modal><div/></Modal>)

    expect(toJson(modal)).toMatchSnapshot()
  })

  describe('active modal displays', () => {
    let onCloseWasCalled = false
    let modal: ReactWrapper
    beforeEach(() => {
      onCloseWasCalled = false;
      let modalManager = new ModalManager();
      modal = mount(<Provider ModalManager={modalManager}><Modal titleText={"title text"}
        focusDialog={true}
        modalActive={true}
        onClose={() => { onCloseWasCalled = true }}
        ><div/></Modal></Provider>)
    })

    it('matches snapshot', () => {
      expect(toJson(modal)).toMatchSnapshot()
    })

    it('closes on modal component close', () => {
      let modalComponent = modal.find('Modal').first().instance() as React.Component<ModalProps, {}> //casting to modal didn't work for reasons?
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
  })


  it('doesnt have a close button if we ask for none', () => {
    let onCloseWasCalled = false
    let modalManager = new ModalManager();
    let modal = mount(<Provider ModalManager={modalManager}>
    <Modal titleText={"title text"}
      focusDialog={true}
      modalActive={true}
      showCloseButton={false}
      onClose={() => { onCloseWasCalled = true }}
    ><div/></Modal></Provider>)
    expect(modal.find('DefaultCloseButton').exists()).toBeFalsy()
  })

})