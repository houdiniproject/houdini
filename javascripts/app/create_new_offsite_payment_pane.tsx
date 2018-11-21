// License: LGPL-3.0-or-later
// require a root component here. This will be treated as the root of a webpack package
import Root from "../src/components/common/Root"
import CreateOffsitePaymentPane from "../src/components/create_offsite_payment_pane/CreateOffsitePaymentPane"

import * as ReactDOM from 'react-dom'
import * as React from 'react'

export interface FundraiserInfo {
  id: number
  name: string
}

function LoadReactPage(element:HTMLElement, campaigns: FundraiserInfo[],
                       events: FundraiserInfo[],
  nonprofitId: number,
  supporterId:number,
  preupdateDonationAction:() => void,
  postUpdateSuccess: () => void,

  //from ModalProps
  onClose: () => void,
  modalActive: boolean,
  nonprofitTimezone?: string) {
  ReactDOM.render(<Root><CreateOffsitePaymentPane campaigns={campaigns}
    events={events} onClose={onClose}
     modalActive={modalActive} nonprofitTimezone={nonprofitTimezone}
    postUpdateSuccess={postUpdateSuccess}
    preupdateDonationAction={preupdateDonationAction} nonprofitId={nonprofitId} supporterId={supporterId}/></Root>, element)
}


(window as any).LoadReactCreateOffsiteDonationPane = LoadReactPage