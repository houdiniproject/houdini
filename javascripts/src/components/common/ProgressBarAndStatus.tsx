// License: LGPL-3.0-or-later
import * as React from 'react';
import ProgressBar from './ProgressBar';


export default function ProgressBarAndStatus({ percentage, status }: { percentage?: number, status?: string }) {

  return <div className='u-centered'>
    <ProgressBar percentage={percentage} />
    <p className='status.u-marginTop--10'>{status}</p>
  </div>
}