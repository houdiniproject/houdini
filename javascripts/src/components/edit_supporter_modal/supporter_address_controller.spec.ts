// License: LGPL-3.0-or-later
import 'jest';
import { SupporterAddressController } from './supporter_address_controller'
import { createMockApiManager, createMockApi } from '../../lib/tests/helpers';
import { SupporterApi, Supporter, PutSupporter, TimeoutError } from '../../../api';
import { resolve } from 'url';

describe('SupporterAddressStore', () => {
  const TIMEOUT_CAUSING_ID = 99999
  const TIMEOUT_CAUSING_NAME = 'eimtout name'
  const supporter = { name: 'nnan' }

  function apiManagerCreator() {
    const mockapi = createMockApi(SupporterApi, () => {
      return {
        getSupporter: jest.fn<JQueryPromise<Supporter>>(
          (supporter_id: number) => {
            return new Promise((resolve, reject) => {
              resolve(supporter);
            })
          }
        ),
        updateSupporter: jest.fn<JQueryPromise<Supporter>>(
          (supporter_id: number, Supporter: PutSupporter) => {
            return new Promise((resolve, reject) => {
              if (Supporter.name === TIMEOUT_CAUSING_NAME) {
                reject(new TimeoutError())
              }
              else {
                return resolve(Supporter)
              }
            })
          })
      }
    });
    return createMockApiManager(mockapi)()
  }


  






})