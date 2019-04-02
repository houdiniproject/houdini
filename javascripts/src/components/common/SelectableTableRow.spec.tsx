// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import SelectableTableRow from './SelectableTableRow'
import { ReactWrapper, mount } from 'enzyme';
import { inject } from 'mobx-react';

@inject('SelectHandler')
class TestReceivedProviderComponent extends React.Component<{SelectHandler?:any}, {}>{
  render() {
    return <td></td>;
  }
}

describe('SelectableTableRow', () => {
  let providerAndRow: ReactWrapper
  let onSelect:any;
  beforeEach(() => {
    onSelect = jest.fn()
    providerAndRow = mount(<table><tbody><SelectableTableRow onSelect={onSelect}>
      <TestReceivedProviderComponent/>
    </SelectableTableRow></tbody></table>)
  })

  function getTr() : ReactWrapper{
    return providerAndRow.find('tr')
  }

  function getProviderComponent() : TestReceivedProviderComponent{
    return providerAndRow.find('TestReceivedProviderComponent').instance() as any
  }

  it('processes the click properly', () => {
    getTr().simulate('click')

    expect(onSelect).toBeCalled()
  })

  it('sends the provider down', () => {
    const c = getProviderComponent()
    expect(c.props.SelectHandler).toBeTruthy()
    expect(c.props.SelectHandler['onSelect']).toBe(onSelect)

  })
})