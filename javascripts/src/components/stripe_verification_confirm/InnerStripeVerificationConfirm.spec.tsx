// License: LGPL-3.0-or-later

import 'jest'
import moment = require('moment-timezone')
import {languageForMoreNeeded, convertDeadlineToLocalizedMoment} from './InnerStripeVerificationConfirm';


describe('convertDeadlineToLocalizedMoment', () => {

  it('returns null if deadline is null', () => {
    expect(convertDeadlineToLocalizedMoment({deadline: null})).toBe(null);
  });

  it('returns Moment of 2020-07-30 21:17:15 +0000 if given 1596143835', () => {
    expect(convertDeadlineToLocalizedMoment({deadline:1596143835})).toEqual(moment(Date.UTC(2020, 6, 30, 21, 17, 15 )));
  });

  it('returns Moment of 2020-07-30 21:17:15 adjusted to Chicago time if given 1596143835 and timezone of America/Chicago', () => {
    expect(convertDeadlineToLocalizedMoment({deadline:1596143835, nonprofitTimezone: 'America/Chicago'})).toEqual(moment(Date.UTC(2020, 6, 30, 21, 17, 15 )).tz('America/Chicago'));
  });
});

describe('languageForMoreNeeded', () => {
  it('return immediately if deadline is null', () => {
    expect(languageForMoreNeeded({deadlineInTimezone: null})).toBe('immediately');
  })

  it('return immediatley if deadline is Moment and in past', () => {
    expect(languageForMoreNeeded({deadlineInTimezone: moment(Date.UTC(2020, 6, 30, 21, 17, 15 )).tz('America/Chicago')})).toBe('immediately');
  })

  it('return formatted if deadline is Moment and in future', () => { 
    const futureDeadline = moment(Date.now()).add( 4, 'minutes');
    
    expect(languageForMoreNeeded({deadlineInTimezone: futureDeadline})).toBe("by " + futureDeadline.format('MMMM D, YYYY') + " at " + futureDeadline.format('h:m A'))
  });
});