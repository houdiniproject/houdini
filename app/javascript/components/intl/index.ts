// License: LGPL-3.0-or-later
import useHoudiniIntlDefault from '../../hooks/useHoudiniIntl';
import HoudiniIntlProviderDefault from './HoudiniIntl';
export const useHoudiniIntl = useHoudiniIntlDefault;
export const HoudiniIntlProvider = HoudiniIntlProviderDefault;
export type {HoudiniIntlShape, FormatMoneyOptions} from '../../hooks/useHoudiniIntl';
export {createHoudiniIntl} from './HoudiniIntl';
