// License: LGPL-3.0-or-later

// based on: app/javascript/legacy/nonprofits/donate/page.js
import React, { useCallback, useState } from 'react';
import url from 'url';
import DonateWizard  from './wizard';



interface DonatePageProps {
	nonprofit_id: number;
}

export default function DonatePage(props: DonatePageProps) : JSX.Element {
	const [params, setParams] = useState(url.parse(location.href, true).query);

	// TODO receiveMessage is kind of complex and shouldn't be the first thing to work on


	// const receiveMessage = useCallback((event) => {
	// 	let ps;

	// 	try { ps = JSON.parse(event.data); }
	// 	// eslint-disable-next-line no-empty
	// 	catch (e) { }
	// 	if (ps && ps.sender === 'commitchange') {
	// 		if (ps.command) {
	// 			const event = new CustomEvent('message:' + ps.command, { data: ps });
	// 			container.dispatchEvent(event);
	// 		}
	// 		if (ps.command === 'setDonationParams') {
	// 			setParams(ps)
	// 			// Fetch the gift option data if they passed a gift option id
	// 			if (ps.campaign_id && ps.gift_option_id) {
	// 				requestGiftOptionParams(ps.campaign_id, ps.gift_option_id)
	// 			}
	// 		}
	// 	}
	// }, [container, setParams, requestGiftOptionParams]);



	return (<DonateWizard>
	</DonateWizard>);

}