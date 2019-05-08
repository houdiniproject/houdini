// License: LGPL-3.0-or-later
// require a root component here. This will be treated as the root of a webpack package
import Root from "../src/components/common/Root"
import CreateSupporterModal from "../src/components/create_supporter_modal/CreateSupporterModal"

import * as ReactDOM from 'react-dom'
import * as React from 'react'

function LoadReactPage(element:HTMLElement,
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


(window as any).LoadCreateSupporterModal = LoadReactPage