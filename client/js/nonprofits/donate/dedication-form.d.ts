// License: LGPL-3.0-or-later
import h from 'snabbdom/h';

import type {DedicationData} from './types';

interface ViewState {
  dedicationData$: () => DedicationData | undefined;
  submitDedication$: (form: HTMLFormElement) => void;
}

// A contact info form for a donor to add a dedication in honor/memory of somebody
export function view(state:ViewState): ReturnType<typeof h>;

