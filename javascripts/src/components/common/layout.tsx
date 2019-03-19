// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer} from "mobx-react";
import * as _ from 'lodash'

function arrayify<T>(items: Array<T>|T){
  return items instanceof Array ? items : [items]
}

export const TwoColumnFields = observer((props:{children:Array<React.ReactElement<any>>|React.ReactElement<any>}) => {
    const children = arrayify(props.children)
    return <div className="row">
        {
            children.map((i:React.ReactElement<any>) => {
                let className = "col-sm-6"
                if (_.last(children) !== i){
                    className += " u-paddingRight--10"
                }
                if (i.props['className']){
                    className += i.props['className']
                }

                return React.cloneElement(i, {wrapperClassName: className})
        })}
    </div>
})

export const ThreeColumnFields = observer((props:{children:Array<React.ReactElement<any>>|React.ReactElement<any>}) => {
  const children = arrayify(props.children)
    return <div className="row">
        {
          children.map((i:React.ReactElement<any>) => {
                let className = "col-sm-4"
                if (_.last(children) !== i){
                    className += " u-paddingRight--10"
                }
                if (i.props['className']){
                    className += i.props['className']
                }

                return React.cloneElement(i, {wrapperClassName: className})
            })}
    </div>
})