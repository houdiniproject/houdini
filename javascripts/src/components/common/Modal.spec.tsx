// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import Modal, {ModalProps} from './Modal'
import {shallow} from "enzyme";
import {toJS} from "mobx";
import toJson from "enzyme-to-json";

describe('Modal', () => {
  test('nothing displayed if inactive', () => {
    let modal = shallow(<Modal childGenerator={() => <div/>}/>)

    expect(toJson(modal)).toMatchSnapshot()
  })

  test('active modal displays', () => {
    let onCloseWasCalled = false
    let modal = shallow(<Modal titleText={"title text"}
                               focusDialog={true}
                               modalActive={true}
                               onClose={() => { onCloseWasCalled = true}}
                               childGenerator={() => <div/>}/>)
    expect(toJson(modal)).toMatchSnapshot()
    let modalComponent = modal.instance() as React.Component<ModalProps, {}> //casting to modal didn't work for reasons?
    modalComponent.props.onClose()
    expect(onCloseWasCalled).toBeTruthy()
  })
})