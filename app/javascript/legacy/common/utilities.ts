// License: LGPL-3.0-or-later
// Utilities!
// XXX remove this whole file and split into modules with specific concerns
// eslint-disable-next-line @typescript-eslint/no-var-requires
const phoneFormatter = require('phone-formatter');
import format from './format';


function isStringArray(testVar: unknown): testVar is string[] {
	return testVar instanceof Array;
}

function isObjectWithErrors(testVar: unknown): testVar is { errors: Record<string, string[]> } {
	return Object.prototype.hasOwnProperty.call(testVar, 'errors');
}

function isObjectWithError(testVar: unknown): testVar is { error: string } {
	return Object.prototype.hasOwnProperty.call(testVar, 'error');
}

const utils = {
	print_error: function (response?: {
		responseJSON?:
		string[] |
		{ errors?: Record<string, unknown> } |
		{ error?: string };
		status: number;
	}): string {
		const msg = 'Sorry! We encountered an error.';
		if (!response) return msg;
		if (response.status === 500) return msg;
		else if (response.status === 404) return "404 - Not found";
		else if (response.status === 422 || response.status === 401) {
			if (!response.responseJSON) return msg;

			const json = response.responseJSON;
			if (isStringArray(json)) return json[0];

			else if (isObjectWithErrors(json))
				for (const key in json.errors)
					return key + ' ' + json.errors[key][0];

			else if (isObjectWithError(json)) return json.error;

			else return msg;
		}
	},

	// Retrieve a URL parameter
	// XXX remove
	get_param: function (name: string): string | undefined {
		return new URLSearchParams(location.search).get(name) || undefined;
	},

	// XXX remove. Depended on only by 'change_url_param'
	update_param: function (key: string, value: string, url?: string): string {
		if (!url) url = window.location.href;
		const urlObj = new URL(url);
		urlObj.searchParams.set(key, value);
		return urlObj.toString();
	},

	// XXX remove
	change_url_param: function (key: string, value: string) {
		if (!history || !history.replaceState) return;
		history.replaceState({}, "", utils.update_param(key, value));
	},

	// for doing an action after the user pauses for a second after an event
	// XXX remove
	delay: (function () {
		let timer = 0;
		return function (ms: number, callback: () => void) {
			clearTimeout(timer);
			timer = setTimeout(callback, ms) as unknown as number;
		};
	})(),

	number_with_commas: function (n: number | string): string {
		return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	},

	dollars_to_cents: format.dollarsToCents,

	cents_to_dollars: format.centsToDollars,

	toFormData: function (form_el: HTMLElement): FormData {
		const form_data = new FormData();
		$(form_el).find('input, select, textarea').each(function (this: HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement, _index: number) {
			if (!this.name) return;
			if (this instanceof HTMLInputElement && this.files && this.files[0])
				form_data.append(this.name, this.files[0]);
			else if (this instanceof HTMLInputElement && this.getAttribute("type") === "checkbox")
				form_data.append(this.name, String(this.checked));
			else if (this.value)
				form_data.append(this.name, this.value);
		});
		return form_data;
	},

	mergeFormData: function (formData: FormData, obj: Record<string, string>): FormData {
		for (const key in obj) formData.append(key, obj[key]);
		return formData;
	},

	address_with_commas: function (street: string, city: string, state: string): string {
		const address = [street, city, state];
		const pretty_print_add = [];
		for (let i = 0; i < address.length; i += 1) {
			if (address[i] !== '' && address[i] != null) pretty_print_add.push(address[i]);
		}
		return pretty_print_add.join(', ');
	},

	pretty_phone: function (phone?: number | string): string | false {
		if (!phone) { return false; }

		// first remove any non-digit characters globally
		// and get length of phone number
		const clean = String(phone).replace(/\D/g, '');
		const len = clean.length;

		const format = "(NNN) NNN-NNNN";

		// then format based on length
		if (len === 10) {
			return phoneFormatter.format(clean, format);
		}
		if (len > 10) {
			const first = clean.substring(0, len - 10);
			const last10 = clean.substring(len - 10);
			return `+${first} ${phoneFormatter.format(last10, format)}`;
		}

		// if number is less than 10, don't apply any formatting
		// and just return it
		return clean;
	},
};

module.exports = utils;