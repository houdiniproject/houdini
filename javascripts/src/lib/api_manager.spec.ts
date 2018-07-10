// License: LGPL-3.0-or-later
import {ApiManager, ApiMissingException} from "./api_manager";
import 'jest';

describe('ApiManager', () => {

    class A{}
    class B{}
    class C {}
    var manager: ApiManager = null
    describe('simple non-intercepted API', () => {
        beforeEach(() => {
             manager = new ApiManager([A, B])})

        test('it errors when API is missing', () => {
            expect(() =>{
                let c = manager.get(C)
                }
            ).toThrow(ApiMissingException)
        })

        test('it gets API of type A', () => {
            let a = manager.get(A)
            expect(a).toBeInstanceOf(A)
            
        })
    })

    describe('handle interceptor', () => {
        let interceptorValue0:boolean
        let interceptor0 = () => {interceptorValue0 = true}
        let interceptorValue1:boolean
        let interceptor1 = () => {interceptorValue1 = true}
        class A {
            defaultExtraJQueryAjaxSettings?: JQuery.AjaxSettings
        }
        class B { 
            defaultExtraJQueryAjaxSettings?: JQuery.AjaxSettings
        }
        class C{}
        beforeEach(() => {

          interceptorValue0 = false
          interceptorValue1 = false

        })


          test('returns A with no interceptor', () => {
            manager = new ApiManager([A, B])
            let a = manager.get(A)

            expect(a).toBeInstanceOf(A)
            expect(a.defaultExtraJQueryAjaxSettings).toBeUndefined()
            expect(interceptorValue0).toBe(false)
            expect(interceptorValue1).toBe(false)
          })


        test('returns B with proper interceptor0', () => {
            manager = new ApiManager([A, B], interceptor0)
            let b = manager.get(B)
            expect(b).toBeInstanceOf(B)
            b.defaultExtraJQueryAjaxSettings.beforeSend(null, null)
          expect(interceptorValue0).toBe(true)
          expect(interceptorValue1).toBe(false)
        })

      test('returns A with two proper interceptors', () => {
        manager = new ApiManager([A, B], interceptor1, interceptor0)
        let a = manager.get(A)
        expect(a).toBeInstanceOf(A)
        a.defaultExtraJQueryAjaxSettings.beforeSend(null, null)
        expect(interceptorValue0).toBe(true)
        expect(interceptorValue1).toBe(true)
      })

        test('returns error on invalid class', () => {
            expect(() =>{
                let c = manager.get(C)
                }
            ).toThrow(ApiMissingException)
        })
    })
})