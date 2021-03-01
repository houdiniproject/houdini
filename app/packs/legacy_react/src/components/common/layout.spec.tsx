// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import Modal, { ModalProps } from './Modal'
import { shallow, mount, ReactWrapper } from "enzyme";
import toJson from "enzyme-to-json";
import { DefaultCloseButton } from './DefaultCloseButton';
import { Column, Row, ThreeColumnFields, TwoColumnFields } from './layout';

const SimpleCheckerComponent = (props: { className?: string }) => {
  return <div></div>
}

describe('layout', () => {
  describe('Column', () => {
    it('sets proper class without none passed in', () => {
      const column = shallow(<Column colSpan={12} breakSize={'sm'}>
        <SimpleCheckerComponent />
      </Column>)

      expect(column.find(SimpleCheckerComponent).props()['className']).toBe('col-sm-12 ')
    })

    it('sets proper class with one passed in', () => {
      const column = shallow(<Column colSpan={1} breakSize={'lg'}>
        <SimpleCheckerComponent className="another_class" />
      </Column>)

      expect(column.find(SimpleCheckerComponent).props()['className'])
        .toBe('col-lg-1 another_class')
    })

    it('sets proper display name', () => {
      const column = shallow(<Column colSpan={1} breakSize={'lg'}>
        <SimpleCheckerComponent className="another_class" />
      </Column>)
      expect(Column.displayName).toBe('Column')
    })
  })

  describe('Row', () => {
    it('renders single child properly', () => {
      const row = mount(<Row>
        <SimpleCheckerComponent/>
      </Row>)

      expect(toJson(row)).toMatchSnapshot()
    })


    it('renders multiple children properly', () => {
      const row = mount(<Row>
        <SimpleCheckerComponent/>
        <SimpleCheckerComponent/>
      </Row>)

      expect(toJson(row)).toMatchSnapshot()
    })

    it('has correct display name', () => {
      const row = mount(<Row>
        <SimpleCheckerComponent/>
      </Row>)

      expect(Row.displayName).toBe('Row')
    })
  })

  describe('ThreeColumnFields',() => {
    it('renders single child properly', () => {
      const fields = mount(<ThreeColumnFields>
          <SimpleCheckerComponent/>
        </ThreeColumnFields>)

      expect(toJson(fields)).toMatchSnapshot()
    })

    it('renders multiple children properly', () => {
      const fields = mount(<ThreeColumnFields>
          <SimpleCheckerComponent/>
          <SimpleCheckerComponent/>
          <SimpleCheckerComponent/>
        </ThreeColumnFields>)

      expect(toJson(fields)).toMatchSnapshot()
    })
  })

  describe('TwoColumnFields',() => {
    it('renders single child properly', () => {
      const fields = mount(<TwoColumnFields>
          <SimpleCheckerComponent/>
        </TwoColumnFields>)

      expect(toJson(fields)).toMatchSnapshot()
    })

    it('renders multiple children properly', () => {
      const fields = mount(<TwoColumnFields>
          <SimpleCheckerComponent/>
          <SimpleCheckerComponent/>
        </TwoColumnFields>)

      expect(toJson(fields)).toMatchSnapshot()
    })
  })
})