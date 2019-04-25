// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import Modal, { ModalProps } from './Modal'
import { shallow, mount, ReactWrapper } from "enzyme";
import toJson from "enzyme-to-json";
import { DefaultCloseButton } from '../DefaultCloseButton';

describe('Modal', () => {
  test('nothing displayed if inactive', () => {
    let modal = shallow(<Modal childGenerator={() => <div />} />)

    expect(toJson(modal)).toMatchSnapshot()
  })

  describe('active modal displays', () => {
    let onCloseWasCalled = false
    let modal: ReactWrapper
    beforeEach(() => {
      onCloseWasCalled = false;
      modal = mount(<Modal titleText={"title text"}
        focusDialog={true}
        modalActive={true}
        onClose={() => { onCloseWasCalled = true }}
        childGenerator={() => <div />} />)
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

    it('has no footer', () => {
      expect(modal.find('footer').exists()).toBeFalsy()
    })
  })

  describe('modal button support', () => {
    let modal: ReactWrapper
    beforeEach(() => {
      modal = mount(<Modal titleText={"title text"}
        focusDialog={true}
        modalActive={true}
        onClose={() => { }}
        childGenerator={() => <div />}
        buttons={[<i>something</i>, <i>somethingelse</i>]} />)
    })

    it('has two modal buttons', () => {
      expect(modal.find('i').length).toBe(2)
    })

    it('has a margin right on the first button', () => {
      const firstChild = modal.find('footer').childAt(0)

      expect(firstChild.prop('style')['marginRight']).toBe('10px')
    })

    it('has no margin on the last button', () => {
      const lastChild = modal.find('footer').childAt(1)

      expect(lastChild.prop('style')['marginRight']).toBeFalsy()
    })
  })


  it('doesnt have a close button if we ask for none', () => {
    let onCloseWasCalled = false
    let modal = mount(<Modal titleText={"title text"}
      focusDialog={true}
      modalActive={true}
      showCloseButton={false}
      onClose={() => { onCloseWasCalled = true }}
      childGenerator={() => <div />}
    />)
    expect(modal.find('DefaultCloseButton').exists()).toBeFalsy()
  })

})