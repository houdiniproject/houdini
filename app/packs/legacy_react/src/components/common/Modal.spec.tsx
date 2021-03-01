// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import Modal, {ModalProps} from './Modal'
import {shallow, mount, ReactWrapper} from "enzyme";
import toJson from "enzyme-to-json";
import { DefaultCloseButton } from './DefaultCloseButton';

describe('Modal', () => {
  test('nothing displayed if inactive', () => {
    let modal = shallow(<Modal childGenerator={() => <div/>}/>)

    expect(toJson(modal)).toMatchSnapshot()
  })

  describe('active modal displays', () => {
    let onCloseWasCalled = false
    let modal:ReactWrapper
    beforeEach(() => {
      onCloseWasCalled = false;
      modal = mount(<Modal titleText={"title text"}
      focusDialog={true}
      modalActive={true}
      onClose={() => { onCloseWasCalled = true}}
      childGenerator={() => <div/>}/>)
    })

    it('matches snapshot', () => {
      expect(toJson(modal)).toMatchSnapshot()
    })

    it('closes on modal component close', () => {
      let modalComponent = modal.instance() as React.Component<ModalProps, {}> //casting to modal didn't work for reasons?
      modalComponent.props.onClose()
      expect(onCloseWasCalled).toBeTruthy()
    })

    it('closes on closeButtonClick', () => {
      let closeButton = modal.find('DefaultCloseButton')
      let instanceButton = closeButton.instance() as DefaultCloseButton
      instanceButton.props.onClick();
      expect(onCloseWasCalled).toBeTruthy()
    })
  })


  it('doesnt have a close button if we ask for none', () => {
    let onCloseWasCalled = false
    let modal = mount(<Modal titleText={"title text"}
                               focusDialog={true}
                               modalActive={true}
                               showCloseButton={false}
                               onClose={() => { onCloseWasCalled = true}}
                               childGenerator={() => <div/>}
                                />)
    expect(modal.find('DefaultCloseButton').exists()).toBeFalsy()
  })
  
})