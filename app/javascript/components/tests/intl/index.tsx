/* eslint-disable @typescript-eslint/no-var-requires */
/* eslint-disable @typescript-eslint/explicit-module-boundary-types */
/* eslint-disable @typescript-eslint/no-explicit-any */
import React from 'react';
import addons from '@storybook/addons';
import omit  from 'lodash/omit';
import { IntlProvider} from '../../intl';
import {convert} from 'dotize';
const messages = require('../../../i18n').default;

export let _config:any = null;

const EVENT_SET_CONFIG_ID = "intl/set_config";
const EVENT_GET_LOCALE_ID = "intl/get_locale";
const EVENT_SET_LOCALE_ID = "intl/set_locale";
class WithIntl extends React.Component<any,any> {
	constructor (props:any) {
		super(props);

		this.state = {
			locale: props.intlConfig.defaultLocale || null,
		};

		this.setLocale = this.setLocale.bind(this);

		const { channel } = this.props;

		// Listen for change of locale
		channel.on(EVENT_SET_LOCALE_ID, this.setLocale);

		// Request the current locale
		channel.emit(EVENT_GET_LOCALE_ID);
	}

	componentWillUnmount () {
		this.props.channel.removeListener(EVENT_SET_LOCALE_ID, this.setLocale);
	}

	render () {
		// If the component is not initialized we don't want to render anything
		if (!this.state.locale) {
			return null;
		}

		const {
			children,
			getMessages,
			getFormats,
			intlConfig,
		} = this.props;

		const { locale } = this.state;
		const messages = convert(getMessages(locale));

		const customProps:any = {
			key: locale,
			locale,
			messages,
		};
			// if getFormats is not defined, we don't want to specify the formats property
		if(getFormats) {
			customProps.formats = getFormats(locale);
		}

		return (
			<IntlProvider {...intlConfig} {...customProps}>
				{children}
			</IntlProvider>
		);
	}

	setLocale (locale:string) {
		this.setState({
			locale: locale,
		});
	}
}


export const setIntlConfig = (config:typeof _config):void => {
	_config = config;

	const channel = addons.getChannel();
	channel.emit(EVENT_SET_CONFIG_ID, {
		locales: config.locales,
		defaultLocale: config.defaultLocale,
	});
};



export const withIntl = (story:any):JSX.Element => {
	const channel = addons.getChannel();

	const intlConfig = omit(_config, ['locales', 'getMessages', 'getFormats']);

	return (
		<WithIntl intlConfig={intlConfig}
			locales={_config.locales}
			getMessages={_config.getMessages}
			getFormats={_config.getFormats}
			channel={channel}>
			{story()}
		</WithIntl>
	);
};

export default function decorate() {
	setIntlConfig({
		locales: Object.keys(messages.translations),
		defaultLocale: messages.defaultLocale,
		// we use this form becuase it allows the story to be viewed in IE11
		getMessages: function(locale:string) { return {...messages.translations[messages.defaultLocale], ...messages.translations[locale]};},
	});
	return withIntl;
}




