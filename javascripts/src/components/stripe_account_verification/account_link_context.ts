import * as React from 'react'

export interface AccountLinkContextData {
    gettingAccountLink:boolean
    error?:string
    accountLink?:string
    getAccountLink?: () => void
}


const AccountLinkContext = React.createContext<AccountLinkContextData>({gettingAccountLink:false});

export default AccountLinkContext;