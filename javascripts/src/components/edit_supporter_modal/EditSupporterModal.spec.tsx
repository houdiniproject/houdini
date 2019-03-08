// License: LGPL-3.0-or-later
import * as React from 'react';
import 'jest';
import EditSupporterModal from './EditSupporterModal'
import { ApiManager } from '../../lib/api_manager';
import { Address, SupporterApi, Supporter, PutSupporter, TimeoutError } from '../../../api';
import * as _ from 'lodash';
import { resolveSoa } from 'dns';
import { ReactWrapper } from 'enzyme';
import { mountWithIntl } from '../../lib/tests/helpers';



describe('EditSupporterModal', () => {

  const TIMEOUT_CAUSING_NAME = "TIMEOUT NAME"
  let addresses: Address[] = [{ id: 1 }, { id: 2 }]



  function apiManagerCreator() {
    return createMockApiManager([{
      type: SupporterApi,
      mockApi: () => {
        return {
          updateSupporter:
            jest.fn<JQueryPromise<Supporter>>(
              (supporter_id: number, Supporter: PutSupporter) => {
                return new Promise((resolve, reject) => {
                  if (Supporter.name === TIMEOUT_CAUSING_NAME)
                  {
                    reject(new TimeoutError())
                  }
                  else {
                    return resolve(Supporter)
                  }
                })
              })
        }
      }
    }])()
  }

  describe('change address', () => {
    let modal: ReactWrapper
    let onCloseAction = jest.fn()
    beforeAll(() => {
      const apiManager = apiManagerCreator()
      modal = mountWithIntl(<EditSupporterModal 
        nonprofitId={0} modalActive={}
        onClose={onCloseAction} 
        />)
    })
    
  })
})