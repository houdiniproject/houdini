// License: LGPL-3.0-or-later
import {Component} from 'react'


export interface MaskedInputProps
{
    mask: Array<any>|Function|Boolean | {mask: Array<any> | Function, pipe: Function}

    guide?: Boolean
    value?: String| Number,
    pipe?: Function,
    placeholderChar?: String,
    keepCharPositions?: Boolean,
    showMask?: Boolean,
    [additionalProps: string] : any
}

export class MaskedInput extends Component<MaskedInputProps, {}> {

}