// License: LGPL-3.0-or-later
// require a root component here. This will be treated as the root of a webpack package
import Root from "../src/components/common/Root"
import EditPaymentPane, {FundraiserInfo} from "../src/components/edit_payment_pane/EditPaymentPane"

import * as ReactDOM from 'react-dom'
import * as React from 'react'

function LoadReactPage(element:HTMLElement, data:any, campaigns:FundraiserInfo[],
                       events:FundraiserInfo[],
                       onClose:() => void,
                       modalActive:boolean,
                       preupdateDonationAction: () => void,
                       postUpdateSuccess: () => void,
                       nonprofitTimezone?:string

                        ) {
  ReactDOM.render(<Root><EditPaymentPane data={data} campaigns={campaigns}
                                         events={events} onClose={onClose}
                                          modalActive={modalActive} nonprofitTimezone={nonprofitTimezone}
                                         postUpdateSuccess={postUpdateSuccess}
                                         preupdateDonationAction={preupdateDonationAction}
  /></Root>, element)
}


(window as any).LoadReactEditPaymentPane = LoadReactPage