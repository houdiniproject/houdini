// License: LGPL-3.0-or-later
// require a root component here. This will be treated as the root of a webpack package
import Root from "../src/components/common/Root"
import EditSupporterModal from "../src/components/edit_supporter_modal/EditSupporterModal"

import * as ReactDOM from 'react-dom'
import * as React from 'react'

function LoadReactPage(element:HTMLElement,
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


(window as any).LoadReactEditSupporterModal = LoadReactPage