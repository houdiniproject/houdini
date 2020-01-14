// License: LGPL-3.0-or-later
import * as React from 'react';
import {ApiManager as ApiManagerLib } from '../../lib/api_manager';
import { APIS } from '../../lib/apis';
import ApiManagerContext from './api_manager_context';


export interface ApiManagerProps
{
}

export interface ApiManagerState {
  apis:ApiManagerLib
}

class ApiManager extends React.Component<ApiManagerProps,ApiManagerState > {
  constructor(props:ApiManagerProps){
    super(props)
    this.state = { apis: new ApiManagerLib(APIS)
    };
  }

  

  render() {
    return <ApiManagerContext.Provider value={this.state}>
      {this.props.children}
    </ApiManagerContext.Provider>

  }
}

export default ApiManager;



