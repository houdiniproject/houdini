// License: LGPL-3.0-or-later
import * as React from 'react';
import {observer} from "mobx-react";
import * as _ from 'lodash'
import { ClassNameable } from './fields';

function arrayify<T>(items: T[]|T){
  return items instanceof Array ? items : [items]
}

type ClassNameableChildren = React.ReactElement<ClassNameable>[]|React.ReactElement<ClassNameable>

export const TwoColumnFields: React.StatelessComponent<{children:ClassNameableChildren}> = (props) => {
    const children = arrayify(props.children)
    return <Row>
        {
            children.map((i:React.ReactElement<ClassNameable>) => {
                let className = ""
                if (_.last(children) !== i){
                    className += " u-paddingRight--10"
                }
                if (i.props.className){
                    className += i.props.className
                }
                return <Column colSpan={6} breakSize={'sm'}>
                 {React.cloneElement(i, {className: className})}
                </Column>
        })}
    </Row>
}

TwoColumnFields.displayName = 'TwoColumnFields'

export const ThreeColumnFields: React.StatelessComponent<{children:ClassNameableChildren}> = (props) => {
  const children = arrayify(props.children)
    return <Row>
        {
          children.map((i:React.ReactElement<ClassNameable>) => {
                let className = ""
                if (_.last(children) !== i){
                    className += " u-paddingRight--10"
                }
                if (i.props.className){
                    className += i.props.className
                }
                return <Column colSpan={4} breakSize={'sm'}>
                    {React.cloneElement(i, {className: className})}
                </Column>
            })}
    </Row>
}

ThreeColumnFields.displayName = 'ThreeColumnFields'


export const Row: React.StatelessComponent<{}> = (props:{children:React.ReactElement<any>[]|React.ReactElement<any>}) => {
    return <div className="row">
        {props.children}
    </div>
}

Row.displayName = 'Row'

type ColumnBreakSize = 'xs'| 'sm'|'md'|'lg'
type ColumnSpan = 1|2|3|4|5|6|7|8|9|10|11|12

interface ColumnProps {
    children:React.ReactElement<any>
    colSpan:ColumnSpan,
    breakSize:ColumnBreakSize
}

export const Column: React.StatelessComponent<ColumnProps> = (props) => {
    let className = `col-${props.breakSize}-${props.colSpan} `
    props.children.props
    if (props.children.props.className){
        className += props.children.props['className']
    }

    return React.cloneElement(props.children, {className: className})
}

Column.displayName = 'Column'
