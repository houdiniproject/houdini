// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import SelectableTableRow from './SelectableTableRow'
import { ReactWrapper, mount } from 'enzyme';
import { connectTableRowSelectHandler, TableRowSelectHandlerContext } from './connect';


class TestReceivedProviderComponent extends React.Component<{m:string} & TableRowSelectHandlerContext, {}>{
  render() {
    return <td></td>;
  }
}

const ReceivedComponent  = connectTableRowSelectHandler(TestReceivedProviderComponent)

describe('SelectableTableRow', () => {
  let providerAndRow: ReactWrapper
  let onSelect: any;
  beforeEach(() => {
    onSelect = jest.fn()
    providerAndRow = mount(<table><tbody><SelectableTableRow onSelect={onSelect}>
      <ReceivedComponent m={"something"}/>
    </SelectableTableRow></tbody></table>)
  })

  function getTr(): ReactWrapper {
    return providerAndRow.find('tr')
  }

  function getProviderComponent() {
    return providerAndRow.find('TestReceivedProviderComponent').instance() as any
  }

  it('processes the click properly', () => {
    getTr().simulate('click')

    expect(onSelect).toBeCalled()
  })

  it('sends the provider down', () => {
    const c = getProviderComponent()
    expect(c.props.selectHandler.onSelect).toBeTruthy()
    expect(c.props.selectHandler.onSelect).toBe(onSelect)
  })
})