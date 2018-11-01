import {Component} from "react";

export interface WrapperProps {
  onChange?: Function<string>
  letterNavigation?: boolean
  activeTabId?: string
  tag?: string

  [prop: string]: any
}



interface TabListProps {
  tag?: string

  [prop: string]: any
}



interface TabProps {
  id: string
  active?: boolean
  letterNavigationText?: string
  tag?: string

  [prop: string]: any
}



interface TabPanelProps {
  tabId: string
  active?: boolean
  tag?: string

  [prop: string]: any
}




export class TabPanel extends Component<TabPanelProps, {}> {
}
export class Tab extends Component<TabProps, {}> {
}

export class TabList extends Component<TabListProps, {}> {
}

export class Wrapper<T> extends Component<WrapperProps & T, {}> {

}
