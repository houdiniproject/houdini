// License: LGPL-3.0-or-later
declare module "velocity-react"
import * as React from 'react'
import * as Velocity from 'velocity-animate'
import 'velocity-animate/velocity.ui'

type Animation =  object|string
type TargetQuerySelector = "children" | string
interface VelocityComponentProps
{
  animation: Animation
  runOnMount?: boolean
  targetQuerySelector?: TargetQuerySelector
}


export declare class VelocityComponent extends React.Component<VelocityComponentProps & jquery.velocity.Options, {}>
{
    runAnimation():void
}

interface VelocityTransitionGroupProps {
    enter: Animation
    leave?: Animation
    runOnMount?: boolean
    style?: CSSProperties
}

export declare class VelocityTransitionGroup extends React.Component<VelocityTransitionGroupProps, {}> {
    static disabledForTest: boolean
}


export declare namespace velocityHelpers {
    declare function registerEffect(animation:Animation)
    declare function registerEffect(suffix:string, animation:Animation)
}