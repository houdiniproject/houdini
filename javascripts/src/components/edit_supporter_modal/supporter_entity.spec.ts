// License: LGPL-3.0-or-later
import 'jest';
import { SupporterEntity, fromFormSupporter } from './supporter_entity';
import { Supporter } from '../../../api';


describe('SupporterEntity', () => {
 
  describe('fromFormSupporter', () => {
    it('returns false when s is falsy', () => {
      expect(fromFormSupporter(null)).toBeFalsy()
      expect(fromFormSupporter(undefined)).toBeFalsy()
    })

    it('clones correctly when s has no default_address', () => {
      const input:any = {
        id: "2",
        name: 'come',
        organization: ""
      }

      expect(fromFormSupporter(input)).toEqual({
        id: "2", 
        name: 'come'
      })
    })

    it('clones correctly when s has a default_address.id', () => {
      const input:any = {
        id: "2",
        name: 'come',
        organization: "",
        default_address: {id: "1"}
      }

      expect(fromFormSupporter(input)).toEqual({
        id: "2", 
        name: 'come', 
        default_address: {
          id: "1"
        }})
    })

    it('clones correctly when s has a default_address but no id', () => {
      const input:any = {
        id: "2",
        name: 'come',
        organization: "",
        default_address: {id: ""}
      }

      expect(fromFormSupporter(input)).toEqual({
        id: "2", 
        name: 'come', 
      })
    })
  })
  
})


