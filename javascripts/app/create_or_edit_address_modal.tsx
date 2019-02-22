// License: LGPL-3.0-or-later
// require a root component here. This will be treated as the root of a webpack package
import Root from "../src/components/common/Root"
import CreateOrEditAddressModal from "../src/components/create_or_edit_address_modal/CreateOrEditAddressModal"

import * as ReactDOM from 'react-dom'
import * as React from 'react'

function LoadReactPage(element:HTMLElement,
    nonprofitId: number,
  supporterId:number,
  //from ModalProps
  onClose: () => void,
  modalActive: boolean
  ) {
  ReactDOM.render(<Root><CreateOrEditAddressModal
    nonprofitId={nonprofitId}
    supporterId={supporterId}
    modalActive={modalActive}
    onClose={onClose}

  /></Root>, element)
}


(window as any).LoadReactCreateOrEditAddressModal = LoadReactPage