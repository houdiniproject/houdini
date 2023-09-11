// License: LGPL-3.0-or-later
import serialize from "form-serialize"
import {evolve as Revolve, toPairs as RtoPairs} from 'ramda';

export const formatFormData = (form: HTMLFormElement) => {
  const data = serialize(form, {hash: true})
  return Revolve({customFields: RtoPairs}, data)
}