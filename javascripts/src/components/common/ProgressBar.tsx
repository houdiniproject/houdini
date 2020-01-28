// License: LGPL-3.0-or-later
import * as React from 'react';


export default function ProgressBar({percentage}:{percentage?: number}) {
  const style:any = {}

  if (percentage){
    style['width'] = `${percentage}%`
  }
  return <div className={'progressBar.u-marginY--10'}>
    <div className={'progressBar-fill--striped'} style={style}/>
  </div>
}