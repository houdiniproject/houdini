import * as React from 'react'
import {observer} from "mobx-react";
import * as _ from 'lodash'
import { ReactWrapper, mount } from 'enzyme';
import { when } from 'mobx';
import { resolve } from 'path';
import {mountWithIntl} from "../../../lib/tests/helpers";

@observer
class OuterWrapper<TProps> extends React.Component<TProps & {__childrenCreator: (props:TProps) => React.ReactNode }> {

  render() {
    const innerProps = _.omit(this.props, '__childrenCreator') as
        any
    
    return this.props.__childrenCreator(innerProps)
  }

}

/**
 * Mobx needs an @observer React component which is created inside the mount tag for enzyme to work. We use this tag to
 * create an OuterWrapper component which simply serves this need and passes the given props to
 * the given root component. To use, put your props for the root component you're mounting into props.
 *
 * NOTE: this wraps your root component with an OuterWrapper tag. Can't be avoided.
 * @param {TProps} props the properties from the outer scope that your mounted components will need
 * @param {(props: TProps) => React.ReactNode} rootComponentCreator a function to create your root component for mounting.
 * @returns {ReactWrapper} The wrapper of your mounted component.
 */
export function mountForMobx(props:any,
  rootComponentCreator:(props:any) => any): ReactWrapper {
  
      
      return mount(<OuterWrapper {...props}
        __childrenCreator={rootComponentCreator} />)
}

/**
 * Same as mountForMobx but has support for React-Intl
 * @param {TProps} props
 * @param {(props: TProps) => React.ReactNode} rootComponentCreator
 * @returns {ReactWrapper}
 */
export function mountForMobxWithIntl(props:any,
                                             rootComponentCreator:(props:any) => any): ReactWrapper {
  return mountWithIntl(<OuterWrapper {...props}
                                     __childrenCreator={rootComponentCreator} />)
}


export function waitForMobxCondition(
  finishCondition:() => any,
  effect: () => any,
  whatToDoOnTimeout: () => void = () => expect(false).toBeTruthy()
 ){
   when(finishCondition,
      () => {
        process.nextTick(() => {
          effect()
        })
      },
      {timeout:10000, onError: whatToDoOnTimeout});
 }




 type TriggerCondition = () => any

 export class TriggerAndAction {
   constructor(
     readonly finishCondition:TriggerCondition, 
     readonly action:(done?:Function) => any){}

    async toPromise():Promise<any> {
      return new Promise((resolve, reject) => {
        waitForMobxCondition(
          this.finishCondition,
          () => {
            this.action()
            resolve()
          },
          () => {
            expect(false).toBeTruthy()
            reject()
          }
        )
      })
    }

 }

 interface TriggerAndActionIface {
   finishCondition:TriggerCondition,
   action:(done?:Function) => any
 }


function isFinishAndAction(item: TriggerCondition|TriggerAndActionIface): item is TriggerAndActionIface{
  return !!(item as TriggerAndActionIface).action
}

 export async function runTestsOnConditions(...args:Array<TriggerCondition| TriggerAndAction | TriggerAndActionIface>) {
   let trigAndActions =  args.map((i) => {
     let ret: TriggerAndAction
     if (i instanceof TriggerAndAction)
     {
       ret = i
     }
     if (isFinishAndAction(i)) {
       ret = new TriggerAndAction(i.finishCondition, i.action)
     }
     else {
      ret = new TriggerAndAction(i, () => {})
     }

     return ret
   })

   trigAndActions.forEach( async (i) =>{
    await i.toPromise()
   })
 }