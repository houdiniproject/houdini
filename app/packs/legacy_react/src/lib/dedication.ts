// License: LGPL-3.0-or-later
export interface Dedication {
  type?:'honor'|'memory',
  supporter_id?: number,
  name?:string
  contact?: {
    email?: string,
    phone?:string
    address?:string
  }
  note?:string
}

export function parseDedication(dedication?:string) : Dedication {
  if (!dedication || dedication == "")
    return {}
  return JSON.parse(dedication)
}

export function serializeDedication(dedication:Dedication) : string {
  return JSON.stringify(dedication)
}




