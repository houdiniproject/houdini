// License: LGPL-3.0-or-later
import * as Moment from 'moment';
import { extendMoment } from 'moment-range';
const moment = extendMoment(Moment);

// returns an array of moments
// timeSpan is one of 'day, 'week', 'month', 'year' (see moment.js docs)

export function dateRange(startDate:moment.MomentInput,
	endDate: moment.MomentInput,
	timeSpan:'day'|'week'|'month'|'year'): moment.Moment[] {
	return Array.from(moment.range(moment(startDate), moment(endDate)).by(timeSpan));
}


