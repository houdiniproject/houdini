// License: LGPL-3.0-or-later
import { Address, PostSupporterSupporterIdAddress, PutSupporterSupporterIdAddress, TimeoutError, NotFoundErrorException } from "../../../../api";
import _ = require("lodash");
import { SupporterEntity } from "../supporter_entity";

let supporters: number[] = [1]
let addresses: Address[] = [{ id: 1 }, { id: 2 }]
export const TIMEOUT_CAUSING_ID = 999999
export const TIMEOUT_CAUSING_STREET = 'time outer'

function createMockStore<T>(type: { new(): T }, mockApi: () => Partial<T>) {
    return mockApi
}
function mockStoreCreator() {
    let timeoutCalledOnce = false
    return createMockStore(SupporterEntity, () => {
        return {
            deleteAddress:
                jest.fn<JQueryPromise<Address>>(
                    (crm_address_id: number) => {
                        return new Promise((resolve, reject) => {
                            if (crm_address_id === TIMEOUT_CAUSING_ID &&    !timeoutCalledOnce)
                            {
                                timeoutCalledOnce = true
                                reject(new TimeoutError())
                            }
                            else {
                                const address = _.find(addresses, (i) => i.id === crm_address_id)
                                if (!address) {
                                    reject(new NotFoundErrorException({}))
                                }
                                else {
                                    resolve(address)
                                }
                            }
                        })
                    }),
            createAddress:
                jest.fn<JQueryPromise<Address>>(
                    (address: PostSupporterSupporterIdAddress) => {
                        return new Promise((resolve, reject) => {
                            if (address.address === TIMEOUT_CAUSING_STREET &&    !timeoutCalledOnce)
                            {
                                timeoutCalledOnce = true
                                reject(new TimeoutError())
                            }

                            else {
                                resolve(address)
                            }
                        })
                    }),

            updateAddress:
                jest.fn<JQueryPromise<Address>>(
                    (crm_address_id: number, putCommand: PutSupporterSupporterIdAddress) => {
                        return new Promise((resolve, reject) => {
                            if (putCommand.address === TIMEOUT_CAUSING_STREET &&    !timeoutCalledOnce)
                            {
                                timeoutCalledOnce = true
                                reject(new TimeoutError())
                            }
                            else {
                                const address = _.find(addresses, (i) => i.id === crm_address_id)
                                if (!address) {
                                    reject(new NotFoundErrorException({}))
                                }

                                else {
                                    resolve({ ...putCommand, ...{ id: crm_address_id } })
                                }
                            }
                        })
                    })
        }
    })()
}

export function supporterEntity() {
    return mockStoreCreator()
}