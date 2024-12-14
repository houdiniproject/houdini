// License: LGPL-3.0-or-later
import * as React from 'react';
import ProgressableButton from './ProgressableButton'
import {render, screen} from '@testing-library/react'
import userEvent from '@testing-library/user-event'

describe('ProgressableButton', () => {
  test('Basic title button works', async () => {
    const clicked = jest.fn()
    let output = render(
      <ProgressableButton onClick={clicked} buttonText={"nothing"} data-label="button"/>)

    userEvent.click(screen.getByText("nothing"))
    expect(clicked).toBeCalled();

    expect(output.baseElement).toMatchSnapshot()


  })

  test('Progress means we change the title, dont disable and do turn on spinner', () => {
    const clicked = jest.fn()
    let output = render(
      <ProgressableButton onClick={clicked}
                          buttonText={"nothing"}
                          data-label="button"
                          buttonTextOnProgress={"onProgress"}
                          inProgress={true}
                          disableOnProgress={false}

                          />)
    expect(output.baseElement).toMatchSnapshot()
  })

  test('Title is kept on progress if no titleOnProgress is set', () => {
    let output = render(
      <ProgressableButton onClick={() => {}}
                          buttonText={"nothing"}
                          data-label="button"
                          inProgress={true}

      />)
    expect(output.baseElement).toMatchSnapshot()
  })

  test('Progress means we change the title, disable and do turn on spinner', () => {
    let output = render(
      <ProgressableButton onClick={() => console.log('alert!')}
                          buttonText={"nothing"}
                          data-label="button"
                          buttonTextOnProgress={"onProgress"}
                          inProgress={true}
                          disableOnProgress={true}

      />)
      expect(output.baseElement).toMatchSnapshot()
  })


  test('Disabled manually set overrides whether we disable on progress when in progress', () => {
    let output = render(
      <ProgressableButton onClick={() => console.log('alert!')}
                          buttonText={"nothing"}
                          data-label="button"
                          buttonTextOnProgress={"onProgress"}
                          inProgress={true}
                          disableOnProgress={false}
                          disabled={true}

      />)
      expect(output.baseElement).toMatchSnapshot()
  })


  test('Disabled manually set overrides whether we disable on progress when NOT in progress', () => {
    let output = render(
      <ProgressableButton onClick={() => console.log('alert!')}
                          buttonText={"nothing"}
                          data-label="button"
                          buttonTextOnProgress={"onProgress"}
                          inProgress={false}
                          disableOnProgress={true}
                          disabled={true}

      />)
      expect(output.baseElement).toMatchSnapshot()
  })


})