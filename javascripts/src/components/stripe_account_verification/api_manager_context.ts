import * as React from 'react'
import { ApiManager } from '../../lib/api_manager';

export interface ApiManagerContextData {
    apis:ApiManager
}


const ApiManagerContext = React.createContext<ApiManagerContextData>({apis:null});

export default ApiManagerContext;