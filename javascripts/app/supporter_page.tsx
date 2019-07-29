// License: LGPL-3.0-or-later
// require a root component here. This will be treated as the root of a webpack package
import Root from "../src/components/common/Root"
import CreateOffsitePaymentModal from "../src/components/create_offsite_payment_modal/CreateOffsitePaymentModal"
import {FundraiserInfo} from "../src/components/edit_payment_pane/types"
import EditSupporterModal from "../src/components/edit_supporter_modal/EditSupporterModal"
import CreateSupporterModal from "../src/components/create_supporter_modal/CreateSupporterModal"

import * as ReactDOM from 'react-dom'
import * as React from 'react'


function LoadReactCreateOffsitePaymentModal(element:HTMLElement, campaigns: FundraiserInfo[],
                       events: FundraiserInfo[],
  nonprofitId: number,
  supporterId:number,
  preupdateDonationAction:() => void,
  postUpdateSuccess: () => void,

  //from ModalProps
  onClose: () => void,
  modalActive: boolean,
  nonprofitTimezone?: string) {
  ReactDOM.render(<Root><CreateOffsitePaymentModal campaigns={campaigns}
    events={events} onClose={onClose}
     modalActive={modalActive} nonprofitTimezone={nonprofitTimezone}
    postUpdateSuccess={postUpdateSuccess}
    preupdateDonationAction={preupdateDonationAction} nonprofitId={nonprofitId} supporterId={supporterId}/></Root>, element)
}


(window as any).LoadReactCreateOffsitePaymentModal = LoadReactCreateOffsitePaymentModal



function LoadReactEditSupporterModal(element:HTMLElement,
  nonprofitId: number,
supporterId:number,
//from ModalProps
onClose: (supporterId?:number) => void,
modalActive: boolean
) {
ReactDOM.render(<Root><EditSupporterModal
  nonprofitId={nonprofitId}
  supporterId={supporterId}
  modalActive={modalActive}
  onClose={onClose}

/></Root>, element)
}


(window as any).LoadReactEditSupporterModal = LoadReactEditSupporterModal






function LoadCreateSupporterModal(element:HTMLElement,
  nonprofitId: number,
//from ModalProps
onClose: (supporterId?:number) => void,
modalActive: boolean
) {
ReactDOM.render(<Root><CreateSupporterModal
  nonprofitId={nonprofitId}
  modalActive={modalActive}
  onClose={onClose}

/></Root>, element)
}


(window as any).LoadCreateSupporterModal = LoadCreateSupporterModal

