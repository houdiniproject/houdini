// License: LGPL-3.0-or-later

const splitParam = str =>
  str?.split(/[_;,]/)

module.exports = params => {
  const defaultAmts = '10,25,50,100,250,500,1000'
  // Set defaults
  // const merge = R.merge({
  //   custom_amounts: ''
  // })
  params = {
    ...params,
    custom_amounts: params?.custom_amounts || defaultAmts
  }

  return {
    ...params,
    multiple_designations: splitParam(params?.multiple_designations),
    custom_amounts: splitParam(params?.custom_amounts).map((i) => Number(i)),
    custom_fields: params?.custom_fields?.split(',')?.map(f => {
      const [name, label] = f.split(':').map((i) => i.trim())
      return {name, label: label ? label : name}
    })
  }
}
