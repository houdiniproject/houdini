// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import ProgressableButton from './ProgressableButton'
import toJson from 'enzyme-to-json';
import {shallow, mount} from 'enzyme';

describe('ProgressableButton', () => {
  test('Basic title button works', () => {
    let output = shallow(
      <ProgressableButton onClick={() => console.log('alert!')} title={"nothing"}  data-label="button"/>)
    expect(toJson(output)).toMatchSnapshot()
  })

  test('Progress means we change the title, dont disable and do turn on spinner', () => {
    let output = mount(
      <ProgressableButton onClick={() => console.log('alert!')}
                          title={"nothing"}
                          data-label="button"
                          titleOnProgress={"onProgress"}
                          inProgress={true}
                          disableOnProgress={false}

                          />)
    expect(toJson(output)).toMatchSnapshot()
  })

  test('Progress means we change the title, disable and do turn on spinner', () => {
    let output = mount(
      <ProgressableButton onClick={() => console.log('alert!')}
                          title={"nothing"}
                          data-label="button"
                          titleOnProgress={"onProgress"}
                          inProgress={true}
                          disableOnProgress={true}

      />)
    expect(toJson(output)).toMatchSnapshot()
  })


  test('Disabled manually set overrides whether we disable on progress when in progress', () => {
    let output = mount(
      <ProgressableButton onClick={() => console.log('alert!')}
                          title={"nothing"}
                          data-label="button"
                          titleOnProgress={"onProgress"}
                          inProgress={true}
                          disableOnProgress={false}
                          disabled={true}

      />)
    expect(toJson(output)).toMatchSnapshot()
  })


  test('Disabled manually set overrides whether we disable on progress when NOT in progress', () => {
    let output = mount(
      <ProgressableButton onClick={() => console.log('alert!')}
                          title={"nothing"}
                          data-label="button"
                          titleOnProgress={"onProgress"}
                          inProgress={false}
                          disableOnProgress={true}
                          disabled={true}

      />)
    expect(toJson(output)).toMatchSnapshot()
  })


})