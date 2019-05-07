import { ReactWrapper } from "enzyme";

export function simulateChange(wrapper:ReactWrapper, value:any) {
    wrapper.simulate('change', {target: {name: wrapper.prop('name') || wrapper.prop('id'), value: value}})
}