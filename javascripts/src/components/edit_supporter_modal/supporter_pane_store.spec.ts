// License: LGPL-3.0-or-later
import 'jest';
import { Address, PostSupporterSupporterIdAddress, TimeoutError, PutSupporterSupporterIdAddress } from '../../../api';
import * as _ from 'lodash';
import { NotFoundErrorException } from '../../../api/model/NotFoundError';
import { waitForMobxCondition } from '../common/test/react_test_helpers';
import { SupporterEntity } from './supporter_entity';
import { SupporterPaneStore } from './supporter_pane_store';

function createMockStore<T>(type: { new(): T }, mockApi: () => Partial<T>) {
  return mockApi
}

describe('SupporterPaneStore', () => {
 
  function successEntity() {
    return {
      loadSupporter: async() => null as any,
      loadAddresses: async() => null as any
    } as SupporterEntity
  }

  function supporterFailEntity() {
    return {
      loadSupporter: async() => {
        throw new Error()
      } ,
      loadAddresses: async() => null as any
    } as Partial<SupporterEntity> as SupporterEntity
  }

  function addressFailEntity() {
    return {
      loadAddresses: async() => {
        throw new Error()
      } ,
      loadSupporter: async() => null as any
    } as Partial<SupporterEntity> as SupporterEntity
  }

  let store:SupporterPaneStore
  it('loads properly', async (done) => {
    store = new SupporterPaneStore(successEntity())
    await store.attemptInit()
    
    expect(store.loadFailure).toBeFalsy()
    expect(store.loading).toBeFalsy()
    expect(store.loaded).toBeTruthy()
    done()
    
  })

  it('sets loadFailure on supporter load failure', async(done) => {
    store = new SupporterPaneStore(supporterFailEntity())
    await store.attemptInit()
    
    expect(store.loadFailure).toBeTruthy()
    done()
  })

  it('sets loadFailure on address load failure', async(done) => {
    store = new SupporterPaneStore(addressFailEntity())
    await store.attemptInit()
    
    expect(store.loadFailure).toBeTruthy()
    done()
  })
  
})


