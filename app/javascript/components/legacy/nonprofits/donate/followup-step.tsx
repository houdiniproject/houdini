// License: LGPL-3.0-or-later
// based on app/javascript/legacy/nonprofits/donate/followup-step.js
import React from 'react';
import noop from 'lodash/noop';
declare const I18n: any;
interface FollowupStepProps {
	supporterEmail?: string | null;
	thankYouMessage?: string | null;
	nonprofitName: string;
	showFinishButton: boolean;
	clickFinish: () => void;

}
export default function FollowupStep(props: FollowupStepProps): JSX.Element {

	return (<div className="u-padding--10 u-centered">
		<h6 className={'u-marginTop--15'}>
			{I18n.t('nonprofits.donate.followup.success')}
		</h6>
		{ props.supporterEmail ? <p>{`${I18n.t('nonprofits.donate.followup.receipt_info')} ${props.supporterEmail}`}</p> : ''}
		<p>
			{props.thankYouMessage || `${props.nonprofitName} ${I18n.t('nonprofits.donate.followup.message')}`}
		</p>



		{/* // we're skipping this stuff for now
	// 	, h('div.u-inlineBlock.u-marginRight--10', [
	// 		h('a.button--small.facebook.u-width--full.share-button', {
	// 			props: {
	// 				target: '_blank'
	// 			, href: 'https://www.facebook.com/dialog/feed?app_id='+app.facebook_app_id +"&display=popup&caption=" + encodeURIComponent(app.campaign.name || app.nonprofit.name) + "&link="+window.location.href
	// 			}
	// 		}, [h('i.fa.fa-facebook-square'), ` ${I18n.t('nonprofits.donate.followup.share.facebook')}`] )
	// 	])
	// , h('div.u-inlineBlock.u-marginLeft--10.u-marginBottom--20', [
	// 		h('a.button--small.twitter.u-width--full', {
	// 			props: {
	// 				target: '_blank'
	// 			, href: "https://twitter.com/intent/tweet?url="+window.location.href+"&via=CommitChange&text=Join me in supporting:" + (app.campaign.name || app.nonprofit.name)
	// 			}
	// 		}, [h('i.fa.fa-twitter-square'), ` ${I18n.t('nonprofits.donate.followup.share.twitter')}`] )
	// 	]) */}

		{ props.showFinishButton ?
			<div>
				<button className={'button finish'} onClick={props.clickFinish}>{I18n.t('nonprofits.donate.followup.finish')}</button>
			</div> : ''
		}
	</div>);
}

FollowupStep.defaultProps = {
	clickFinish: noop,
	showFinishButton: false,
} as FollowupStepProps;