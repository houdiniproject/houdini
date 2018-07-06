// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import ReactInput from './ReactInput'
import {Form} from "mobx-react-form";
import ReactForm from "./ReactForm";
import {mount} from 'enzyme';
import {toJS, observable, action, runInAction} from 'mobx';
import {observer} from 'mobx-react';
import {InputHTMLAttributes} from 'react';



@observer
class TestChange extends React.Component{
  @observable
  remove:boolean
  @observable
  form: Form

  @action.bound
  componentWillMount(){
    this.form = new Form({fields:[{
    name: 'name',
      extra: null}
    ]})
  }



  @action.bound
  onClick(){
    this.remove = true
  }
  render() {
    let reactInput = !this.remove ?  <ReactInput field={this.form.$('name')} label={'label1'} placeholder={"holder"}>
      {this.props.children}
    </ReactInput> : undefined

    return <ReactForm form={this.form}>

      {reactInput}
      <button onClick={() => this.onClick()}/>
    </ReactForm>
  }
}


class WrappedInput extends React.Component<InputHTMLAttributes<HTMLInputElement>>{

  render(){
    let notChildren = {...this.props}
    delete notChildren.children
    return <div>
      <input {...notChildren} />
    </div>
  }
}

describe('ReactInput', () => {

  let form: Form
  beforeEach(() => {
    form = new Form({
      fields: [
        {
          name: 'name',
          extra: null
        }
      ]
    })
  })

  describe('no children passed in', () => {
    test('gets added properly', () => {
      let res = mount(<ReactForm form={form}>
          <ReactInput field={form.$('name')} label={"label"}
                      placeholder={"holder"} value={'snapshot'} aria-required={true}/>

        </ReactForm>)


      //Did the attributes settings work as expected back to the objects
      expect(form.$('name').label).toEqual('label')
      expect(form.$('name').placeholder).toEqual('holder')
      expect(form.$('name').value).toEqual('')

      //is the aria attribute passted through to the input
      let input = res.find('input')
      expect(input.prop('aria-required')).toEqual(true)


      // is the input properly bound?
      input.simulate('change',  {target: { value: 'something' } })
      expect(form.$('name').value).toEqual('something')
    })

    test('gets removed properly', () => {

      let res = mount(<TestChange/>)

      let f = res.find('ReactForm').instance() as ReactForm
      expect(f.form.size).toEqual(1)

      res.find('input').simulate('change',  {target: { value: 'something' } })

      expect(f.form.$('name').value).toEqual('something')

      res.find('button').simulate('click')
      expect(f.form.size).toEqual(1)

      expect(toJS(res.find('form'))).toMatchSnapshot()

      expect(f.form.$('name').label).toEqual('label1')
      expect(f.form.$('name').placeholder).toEqual('holder')
    })
  })

  describe('children passed in', () => {
    test('gets added properly', () => {
      let res = mount(<ReactForm form={form}>
        <ReactInput field={form.$('name')} label={"label"}
                    placeholder={"holder"} value={'snapshot'} aria-required={true}>
          <WrappedInput/>
        </ReactInput>

      </ReactForm>)

      //Did the attributes settings work as expected back to the objects
      expect(form.$('name').label).toEqual('label')
      expect(form.$('name').placeholder).toEqual('holder')
      expect(form.$('name').value).toEqual('')

      //is the aria attribute passted through to the input
      let input = res.find('input')
      expect(input.prop('aria-required')).toEqual(true)


      // is the input properly bound?
      input.simulate('change',  {target: { value: 'something' } })
      expect(form.$('name').value).toEqual('something')
    })

    test('gets removed properly', () => {

      let res = mount(<TestChange>
        <WrappedInput/>
      </TestChange>)
      let f = res.find('ReactForm').instance() as ReactForm
      res.find('input').simulate('change',  {target: { value: 'something' } })

      expect(f.form.$('name').value).toEqual('something')
      expect(f.form.size).toEqual(1)
      res.find('button').simulate('click')
      expect(f.form.size).toEqual(1)

      expect(f.form.$('name').label).toEqual('label1')
      expect(f.form.$('name').placeholder).toEqual('holder')
    })

  })
})